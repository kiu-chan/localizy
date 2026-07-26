import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:localizy/features/ocr/domain/cameroon_plate_parser.dart';
import 'package:localizy/features/ocr/domain/plate_scan_roi.dart';
import 'package:path_provider/path_provider.dart';

/// Nhận dạng biển số xe Cameroun (🇨🇲) từ ảnh bằng ML Kit OCR.
///
/// Định dạng: `<2 chữ vùng> <3-4 số> <1-2 chữ sê-ri>` — ví dụ `LT 1234 A`.
///
/// Chiến lược để tăng độ chính xác:
/// 1. Cắt ảnh về đúng khung ngắm (nếu có) → bỏ hết chữ nền như biển hiệu,
///    quảng cáo; ảnh nhỏ hơn nên OCR cũng nhanh hơn nhiều.
/// 2. Chuyển xám + tăng tương phản, phóng to nếu vùng cắt quá nhỏ.
/// 3. Thu thập **nhiều ứng viên** rồi chấm điểm thay vì lấy kết quả khớp đầu tiên.
/// 4. Sửa nhầm lẫn ký tự theo vị trí (O↔0, I↔1, S↔5, B↔8...) — biết vị trí nào
///    là chữ, vị trí nào là số nên sửa được chắc chắn.
class PlateRecognitionService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Chiều rộng tối thiểu đưa vào OCR — nhỏ hơn thì phóng to lên.
  static const int _minOcrWidth = 900;

  /// Chiều rộng tối đa của ảnh full-frame — lớn hơn không giúp OCR tốt hơn
  /// mà chỉ làm chậm.
  static const int _maxOcrWidth = 1600;

  /// [roi] là khung ngắm trên màn hình lúc chụp; truyền `null` cho ảnh chọn từ
  /// thư viện (không biết người dùng đã ngắm ở đâu).
  Future<String> recognizeFromImage(String imagePath, {PlateScanRoi? roi}) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        _log('Không thể decode ảnh');
        return '';
      }

      // Áp dụng EXIF orientation trước
      final oriented = img.bakeOrientation(decoded);
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/plate_scan.jpg';

      // Ưu tiên vùng ngắm, sau đó mới tới toàn ảnh.
      final sources = <img.Image>[];
      final cropped = roi == null ? null : _cropToRoi(oriented, roi);
      if (cropped != null) sources.add(_enhance(cropped));
      sources.add(_enhance(_fitForOcr(oriented)));

      PlateCandidate? best;
      try {
        for (var s = 0; s < sources.length; s++) {
          for (final angle in const [0, 90, 270, 180]) {
            final candidate = await _runOcr(sources[s], angle, tempPath);
            if (candidate == null) continue;

            _log('Ứng viên (nguồn $s, góc $angle°): '
                '${candidate.plate} — điểm ${candidate.score}');
            if (best == null || candidate.score > best.score) best = candidate;
            if (best.score >= CameroonPlateParser.confidentScore) {
              _log('✓ Biển số: ${best.plate}');
              return best.plate;
            }
          }
        }
      } finally {
        try { await File(tempPath).delete(); } catch (_) {}
      }

      if (best == null) {
        _log('✗ Không tìm thấy biển số');
        return '';
      }
      _log('✓ Biển số (điểm ${best.score}): ${best.plate}');
      return best.plate;
    } catch (e) {
      _log('Lỗi nhận diện text: $e');
      return '';
    }
  }

  // ---------------------------------------------------------------- ảnh vào

  /// Cắt ảnh theo khung ngắm, chừa thêm lề để sai số ánh xạ không cắt mất biển.
  img.Image? _cropToRoi(img.Image src, PlateScanRoi roi) {
    final iw = src.width.toDouble();
    final ih = src.height.toDouble();

    // Preview hiển thị kiểu "cover": tìm phần ảnh thực sự nhìn thấy trên màn hình.
    final double visibleW, visibleH;
    if (iw / ih > roi.viewportAspect) {
      visibleH = ih;
      visibleW = ih * roi.viewportAspect;
    } else {
      visibleW = iw;
      visibleH = iw / roi.viewportAspect;
    }
    final offsetX = (iw - visibleW) / 2;
    final offsetY = (ih - visibleH) / 2;

    // Lề dư: rộng thêm 10% bề ngang, 35% bề dọc của khung.
    final padX = roi.width * 0.10;
    final padY = roi.height * 0.35;

    final left = (offsetX + (roi.left - padX) * visibleW).clamp(0.0, iw);
    final right = (offsetX + (roi.right + padX) * visibleW).clamp(0.0, iw);
    final top = (offsetY + (roi.top - padY) * visibleH).clamp(0.0, ih);
    final bottom = (offsetY + (roi.bottom + padY) * visibleH).clamp(0.0, ih);

    final width = (right - left).round();
    final height = (bottom - top).round();
    if (width < 120 || height < 60) return null;

    final crop = img.copyCrop(
      src,
      x: left.round(),
      y: top.round(),
      width: width,
      height: height,
    );
    _log('Cắt khung ngắm: ${crop.width}x${crop.height} (ảnh gốc ${src.width}x${src.height})');
    return _fitForOcr(crop);
  }

  /// Đưa ảnh về khoảng kích thước ML Kit đọc tốt nhất.
  img.Image _fitForOcr(img.Image src) {
    if (src.width < _minOcrWidth) {
      return img.copyResize(
        src,
        width: _minOcrWidth,
        maintainAspect: true,
        interpolation: img.Interpolation.cubic,
      );
    }
    if (src.width > _maxOcrWidth) {
      return img.copyResize(
        src,
        width: _maxOcrWidth,
        maintainAspect: true,
        interpolation: img.Interpolation.average,
      );
    }
    return src;
  }

  /// Chuyển xám + tăng tương phản để chữ trên biển tách khỏi nền.
  img.Image _enhance(img.Image src) {
    final gray = img.grayscale(src.clone());
    return img.adjustColor(gray, contrast: 1.25);
  }

  Future<PlateCandidate?> _runOcr(img.Image source, int angle, String tempPath) async {
    final rotated = angle == 0 ? source : img.copyRotate(source, angle: angle);
    await File(tempPath).writeAsBytes(img.encodeJpg(rotated, quality: 92));

    final recognized = await _textRecognizer.processImage(
      InputImage.fromFilePath(tempPath),
    );
    if (recognized.blocks.isEmpty) return null;

    return _bestCandidate(recognized);
  }

  // ------------------------------------------------------------ phân tích text

  PlateCandidate? _bestCandidate(RecognizedText recognized) {
    PlateCandidate? best;

    void consider(String text) {
      final candidate = CameroonPlateParser.best(text);
      if (candidate != null && (best == null || candidate.score > best!.score)) {
        best = candidate;
      }
    }

    for (final block in recognized.blocks) {
      final lines = block.lines.map((l) => l.text.trim()).where((t) => t.isNotEmpty).toList();

      for (final line in lines) {
        consider(line);
      }
      // Biển vuông / 2 hàng: ML Kit tách thành nhiều dòng, ghép lại thử.
      for (var i = 0; i + 1 < lines.length; i++) {
        consider('${lines[i]} ${lines[i + 1]}');
      }
      if (lines.length > 2) consider(lines.join(' '));
    }

    // Chốt hạ: không khớp pattern nào thì lấy chuỗi trông giống biển số nhất.
    if (best == null) {
      for (final block in recognized.blocks) {
        final near = CameroonPlateParser.nearMatch(block.text);
        if (near != null) {
          best = near;
          break;
        }
      }
    }

    return best;
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[PlateOCR] $message');
  }

  void dispose() {
    _textRecognizer.close();
  }
}
