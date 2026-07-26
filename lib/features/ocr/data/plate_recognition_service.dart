import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Nhận dạng biển số xe Cameroun (🇨🇲) từ ảnh bằng ML Kit OCR.
///
/// Định dạng hỗ trợ: `<2 chữ vùng> <3-4 số> <1-2 chữ sê-ri>`,
/// ví dụ `LT 1234 A`, `CE-456-AB`, `NW1234AB`.
class PlateRecognitionService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String> recognizeFromImage(String imagePath) async {
    try {
      debugPrint('=== Nhận diện text từ ảnh ===');

      final bytes = await File(imagePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        debugPrint('Không thể decode ảnh');
        return '';
      }

      // Áp dụng EXIF orientation trước
      final oriented = img.bakeOrientation(decoded);
      final tempDir = await getTemporaryDirectory();

      // Thử OCR ở 4 góc xoay
      for (final angle in [0, 90, 270, 180]) {
        final rotated = angle == 0 ? oriented : img.copyRotate(oriented, angle: angle);
        final tempPath = '${tempDir.path}/plate_scan_$angle.jpg';
        await File(tempPath).writeAsBytes(img.encodeJpg(rotated, quality: 90));

        try {
          final inputImage = InputImage.fromFilePath(tempPath);
          final recognizedText = await _textRecognizer.processImage(inputImage);

          debugPrint('Góc $angle° - Số blocks: ${recognizedText.blocks.length}');

          final plate = _extractLicensePlate(recognizedText);
          if (plate.isNotEmpty) {
            debugPrint('✓ Biển số phát hiện ở góc $angle°: $plate');
            return plate;
          }
        } finally {
          try { await File(tempPath).delete(); } catch (_) {}
        }
      }

      debugPrint('✗ Không tìm thấy biển số');
      return '';
    } catch (e) {
      debugPrint('Lỗi nhận diện text: $e');
      return '';
    }
  }

  String _extractLicensePlate(RecognizedText recognizedText) {
    final blocks = <String>[];
    for (final block in recognizedText.blocks) {
      final blockText = block.text.trim();
      if (blockText.isNotEmpty) {
        blocks.add(blockText);
        debugPrint('Checking block: "$blockText"');
      }
    }

    debugPrint('=== Tìm biển số Cameroun ===');
    for (final blockText in blocks) {
      // Chỉ xử lý text có chữ IN HOA
      if (!_hasUppercaseLetters(blockText)) continue;

      final plate = _tryExtractFromBlock(blockText);
      if (plate.isNotEmpty) {
        debugPrint('✓ Tìm thấy biển số CM: $plate');
        return plate;
      }
    }

    // Không khớp pattern chính xác → lấy text gần giống (chỉ IN HOA)
    final nearMatch = _findNearMatchPlate(blocks);
    if (nearMatch.isNotEmpty) {
      debugPrint('✓ Tìm thấy gần giống: $nearMatch');
      return nearMatch;
    }

    return '';
  }

  /// Thử từng dòng của block, sau đó thử cả block đã gộp dòng —
  /// biển vuông thường bị ML Kit tách thành 2 dòng.
  String _tryExtractFromBlock(String blockText) {
    final lines = blockText
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (final line in lines) {
      final plate = _tryExtractCameroonPlate(line);
      if (plate.isNotEmpty) return plate;
    }

    return _tryExtractCameroonPlate(blockText.replaceAll('\n', ' '));
  }

  String _tryExtractCameroonPlate(String text) {
    final patterns = [
      // LT 1234 A / LT-1234-AB
      RegExp(r'([A-Z]{2})[-\s]+(\d{3,4})[-\s]+([A-Z]{1,2})\b', caseSensitive: false),
      // LT1234A
      RegExp(r'([A-Z]{2})(\d{3,4})([A-Z]{1,2})\b', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final region = match.group(1)!.toUpperCase();
        final numbers = match.group(2)!;
        final series = match.group(3)!.toUpperCase();
        return '$region $numbers $series';
      }
    }
    return '';
  }

  // Kiểm tra text có chữ IN HOA không
  bool _hasUppercaseLetters(String text) {
    return RegExp(r'[A-Z]').hasMatch(text);
  }

  // Tìm text gần giống biển số (chỉ IN HOA)
  String _findNearMatchPlate(List<String> lines) {
    for (final line in lines) {
      // Chỉ xử lý text có chữ IN HOA
      if (!_hasUppercaseLetters(line)) continue;

      // Loại bỏ ký tự đặc biệt, giữ số và chữ IN HOA
      final cleaned = line.replaceAll(RegExp(r'[^0-9A-Z\-]'), '');

      // Điều kiện: 4-12 ký tự, có cả số và chữ, chỉ chữ IN HOA
      if (cleaned.length >= 4 && cleaned.length <= 12) {
        final hasNumber = RegExp(r'\d').hasMatch(cleaned);
        final hasUpperLetter = RegExp(r'[A-Z]').hasMatch(cleaned);
        final hasLowerLetter = RegExp(r'[a-z]').hasMatch(line);

        // Chỉ chấp nhận nếu có số, có chữ IN HOA, KHÔNG có chữ thường
        if (hasNumber && hasUpperLetter && !hasLowerLetter) {
          debugPrint('Near match found: $cleaned from "$line"');
          return cleaned;
        }
      }
    }
    return '';
  }

  void dispose() {
    _textRecognizer.close();
  }
}
