import 'package:flutter_test/flutter_test.dart';
import 'package:localizy/features/transactions/domain/history_entry.dart';

void main() {
  group('HistoryType.from', () {
    test('ánh xạ chuỗi biết trước', () {
      expect(HistoryType.from('parking'), HistoryType.parking);
      expect(HistoryType.from('verification'), HistoryType.verification);
    });

    test('chuỗi lạ → other', () {
      expect(HistoryType.from('foo'), HistoryType.other);
      expect(HistoryType.from(''), HistoryType.other);
    });
  });

  group('HistoryEntry.hasCoordinates', () {
    HistoryEntry entry({double? lat, double? lng}) => HistoryEntry(
          id: '1',
          type: HistoryType.parking,
          title: 't',
          location: 'l',
          amount: 0,
          status: 'success',
          paymentMethod: 'cash',
          date: DateTime(2024),
          latitude: lat,
          longitude: lng,
        );

    test('true khi có cả lat và lng', () {
      expect(entry(lat: 1, lng: 2).hasCoordinates, isTrue);
    });

    test('false khi thiếu một trong hai', () {
      expect(entry(lat: 1).hasCoordinates, isFalse);
      expect(entry(lng: 2).hasCoordinates, isFalse);
      expect(entry().hasCoordinates, isFalse);
    });
  });
}
