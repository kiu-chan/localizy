import 'package:flutter_test/flutter_test.dart';
import 'package:localizy/features/ocr/domain/cameroon_plate_parser.dart';

void main() {
  group('CameroonPlateParser.best', () {
    test('đọc được các cách viết thường gặp', () {
      const inputs = {
        'LT 1234 A': 'LT 1234 A',
        'LT-1234-A': 'LT 1234 A',
        'LT1234A': 'LT 1234 A',
        'CE 456 AB': 'CE 456 AB',
        'nw 1234 ab': 'NW 1234 AB',
      };

      inputs.forEach((raw, expected) {
        expect(CameroonPlateParser.best(raw)?.plate, expected, reason: raw);
      });
    });

    test('bỏ qua ký tự rác quanh biển số', () {
      expect(
        CameroonPlateParser.best('* LT 1234 A *')?.plate,
        'LT 1234 A',
      );
    });

    test('bỏ tiền tố quốc gia CM ở dải xanh bên trái', () {
      expect(CameroonPlateParser.best('CM LT 1234 A')?.plate, 'LT 1234 A');
    });

    test('sửa nhầm lẫn ký tự theo vị trí', () {
      // Mã vùng bị đọc thành số, phần số bị đọc thành chữ.
      expect(CameroonPlateParser.best('1T 1Z34 A')?.plate, 'IT 1234 A');
      expect(CameroonPlateParser.best('LT I234 A')?.plate, 'LT 1234 A');
      expect(CameroonPlateParser.best('L7 12E4 A'), isNull);
    });

    test('ưu tiên bản đọc sạch và đúng mã vùng', () {
      final exactKnownRegion = CameroonPlateParser.best('LT 1234 A')!;
      final exactUnknownRegion = CameroonPlateParser.best('XY 1234 A')!;
      final corrected = CameroonPlateParser.best('LT I234 A')!;

      expect(exactKnownRegion.score, greaterThan(exactUnknownRegion.score));
      expect(exactKnownRegion.score, greaterThan(corrected.score));
      expect(exactKnownRegion.score,
          greaterThanOrEqualTo(CameroonPlateParser.confidentScore));
    });

    test('chọn ứng viên tốt nhất khi text có nhiều đoạn giống biển số', () {
      // "AB 999 Z" không phải mã vùng hợp lệ, "LT 1234 A" thì có.
      final best = CameroonPlateParser.best('AB 999 Z ... LT 1234 A');
      expect(best?.plate, 'LT 1234 A');
    });

    test('không bịa biển số từ text không liên quan', () {
      expect(CameroonPlateParser.best('PARKING GRATUIT'), isNull);
      expect(CameroonPlateParser.best(''), isNull);
      expect(CameroonPlateParser.best('12'), isNull);
    });
  });

  group('CameroonPlateParser.nearMatch', () {
    test('chấp nhận chuỗi IN HOA có cả chữ lẫn số, điểm thấp', () {
      final near = CameroonPlateParser.nearMatch('LT12X4A');
      expect(near?.plate, 'LT12X4A');
      expect(near!.score, lessThan(CameroonPlateParser.confidentScore));
    });

    test('bỏ qua text có chữ thường hoặc quá ngắn', () {
      expect(CameroonPlateParser.nearMatch('Parking 12'), isNull);
      expect(CameroonPlateParser.nearMatch('AB12'), isNull);
    });
  });
}
