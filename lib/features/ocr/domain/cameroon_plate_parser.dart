/// Một biển số ứng viên kèm điểm tin cậy — điểm càng cao càng đáng tin.
class PlateCandidate {
  final String plate;
  final int score;

  const PlateCandidate(this.plate, this.score);

  @override
  String toString() => '$plate ($score)';
}

/// Bóc biển số Cameroun ra khỏi chuỗi text thô mà OCR trả về.
///
/// Định dạng: `<2 chữ mã vùng> <3-4 số> <1-2 chữ sê-ri>`, ví dụ `LT 1234 A`.
///
/// Vì biết trước vị trí nào là chữ và vị trí nào là số, parser tự sửa được các
/// nhầm lẫn kinh điển của OCR (O↔0, I↔1, S↔5, B↔8...). Kết quả có sửa ký tự bị
/// chấm điểm thấp hơn kết quả khớp nguyên bản, nên khi có nhiều ứng viên thì
/// bản đọc "sạch" luôn được ưu tiên.
abstract final class CameroonPlateParser {
  /// Mã vùng hợp lệ (10 vùng hành chính + biển quốc gia `CM`).
  static const Set<String> regionCodes = {
    'AD', 'CE', 'EN', 'ES', 'LT', 'NO', 'NW', 'OU', 'SU', 'SW', 'CM',
  };

  /// Điểm của một ứng viên khớp chuẩn và đúng mã vùng — đủ tin để dừng tìm.
  static const int confidentScore = 7;

  static final RegExp _plate =
      RegExp(r'([A-Z0-9]{2})[-\s]?([A-Z0-9]{3,4})[-\s]?([A-Z0-9]{1,2})(?![A-Z0-9])');

  static const Map<String, String> _digitToLetter = {
    '0': 'O', '1': 'I', '2': 'Z', '4': 'A', '5': 'S', '6': 'G', '8': 'B',
  };

  static const Map<String, String> _letterToDigit = {
    'O': '0', 'Q': '0', 'D': '0', 'I': '1', 'L': '1', 'Z': '2', 'A': '4',
    'S': '5', 'G': '6', 'T': '7', 'B': '8',
  };

  /// Tất cả đoạn trông giống biển số trong [text], kèm điểm.
  static List<PlateCandidate> parse(String text) {
    final normalized = normalize(text);
    if (normalized.length < 5) return const [];

    final results = <PlateCandidate>[];
    for (final match in _plate.allMatches(normalized)) {
      final rawRegion = match.group(1)!;
      final rawDigits = match.group(2)!;
      final rawSeries = match.group(3)!;

      final region = _toLetters(rawRegion);
      final digits = _toDigits(rawDigits);
      final series = _toLetters(rawSeries);

      if (!RegExp(r'^[A-Z]{2}$').hasMatch(region)) continue;
      if (!RegExp(r'^\d{3,4}$').hasMatch(digits)) continue;
      if (!RegExp(r'^[A-Z]{1,2}$').hasMatch(series)) continue;

      final isExact =
          region == rawRegion && digits == rawDigits && series == rawSeries;

      var score = 2;
      if (isExact) score += 4;
      if (regionCodes.contains(region)) score += 3;
      if (digits.length == 4) score += 1;

      results.add(PlateCandidate('$region $digits $series', score));
    }
    return results;
  }

  /// Ứng viên điểm cao nhất trong [text], `null` nếu không có.
  static PlateCandidate? best(String text) {
    PlateCandidate? best;
    for (final candidate in parse(text)) {
      if (best == null || candidate.score > best.score) best = candidate;
    }
    return best;
  }

  /// Chốt hạ khi không đoạn nào khớp định dạng: lấy chuỗi IN HOA có cả chữ lẫn
  /// số. Điểm 1 — thấp hơn mọi ứng viên đúng dạng.
  static PlateCandidate? nearMatch(String text) {
    for (final line in text.split('\n')) {
      if (RegExp(r'[a-z]').hasMatch(line)) continue;

      final cleaned = line.replaceAll(RegExp(r'[^0-9A-Z]'), '');
      if (cleaned.length < 5 || cleaned.length > 10) continue;

      final letters = RegExp(r'[A-Z]').allMatches(cleaned).length;
      final numbers = RegExp(r'\d').allMatches(cleaned).length;
      if (letters >= 2 && numbers >= 3) return PlateCandidate(cleaned, 1);
    }
    return null;
  }

  /// Viết hoa, bỏ ký tự lạ, và bỏ tiền tố quốc gia `CM` ở dải xanh bên trái
  /// biển — nếu giữ lại nó sẽ bị hiểu nhầm thành mã vùng.
  static String normalize(String text) {
    final out = text
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9\s-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return out.replaceFirst(RegExp(r'^(CM|CAM|CMR)\s+(?=[A-Z0-9]{2}\b)'), '');
  }

  static String _toLetters(String raw) =>
      raw.split('').map((c) => _digitToLetter[c] ?? c).join();

  static String _toDigits(String raw) =>
      raw.split('').map((c) => _letterToDigit[c] ?? c).join();
}
