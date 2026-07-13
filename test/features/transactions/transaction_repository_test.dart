import 'package:flutter_test/flutter_test.dart';
import 'package:localizy/features/transactions/data/transaction_repository.dart';
import 'package:localizy/features/transactions/domain/history_entry.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  late MockApiClient client;
  late TransactionRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = TransactionRepository(client);
  });

  // Một zone mẫu để join.
  final zonesJson = [
    {
      'id': 'zone-1',
      'code': 'Z1',
      'name': 'Zone One',
      'latitude': 10.5,
      'longitude': 20.5,
      'availableSpots': 3,
      'totalParkingSpots': 10,
      'pricePerHour': 5000,
    },
  ];

  void stubZones() {
    when(() => client.getJson('api/addresses/parking-zones'))
        .thenAnswer((_) async => zonesJson);
  }

  group('getParkingHistory', () {
    test('ánh xạ trạng thái vé: cancelled→failed, active/expired→success', () async {
      stubZones();
      when(() => client.getJson('api/parking/my-tickets')).thenAnswer(
        (_) async => {
          'items': [
            {'ticketCode': 'T-A', 'addressId': 'zone-1', 'status': 'cancelled'},
            {'ticketCode': 'T-B', 'addressId': 'zone-1', 'status': 'active'},
            {'ticketCode': 'T-C', 'addressId': 'zone-1', 'status': 'expired'},
            {'ticketCode': 'T-D', 'addressId': 'zone-1', 'status': 'pending'},
          ],
        },
      );

      final result = await repo.getParkingHistory();

      expect(result.map((e) => e.status).toList(),
          ['failed', 'success', 'success', 'pending']);
    });

    test('join zone: location, tọa độ và pricePerHour lấy từ zone', () async {
      stubZones();
      when(() => client.getJson('api/parking/my-tickets')).thenAnswer(
        (_) async => [
          {
            'ticketCode': 'T-A',
            'addressId': 'zone-1',
            'status': 'active',
            'amount': 15000,
          },
        ],
      );

      final entry = (await repo.getParkingHistory()).single;

      expect(entry.id, 'T-A');
      expect(entry.type, HistoryType.parking);
      expect(entry.location, 'Z1 - Zone One');
      expect(entry.latitude, 10.5);
      expect(entry.longitude, 20.5);
      expect(entry.pricePerHour, 5000);
      expect(entry.amount, 15000);
    });

    test('zone không khớp addressId → fallback dùng addressId làm location',
        () async {
      stubZones();
      when(() => client.getJson('api/parking/my-tickets')).thenAnswer(
        (_) async => [
          {'ticketCode': 'T-X', 'addressId': 'unknown', 'status': 'active'},
        ],
      );

      final entry = (await repo.getParkingHistory()).single;

      expect(entry.location, 'unknown');
      expect(entry.latitude, isNull);
      expect(entry.zoneId, 'unknown');
    });
  });

  group('getAllHistory', () {
    test('parking join zone; verification parse tọa độ từ chuỗi location',
        () async {
      stubZones();
      when(() => client.getJson('api/transactions/my-transactions')).thenAnswer(
        (_) async => [
          {
            'id': 'p1',
            'type': 'parking',
            'location': 'zone-1',
            'amount': 1000,
            'status': 'Success',
          },
          {
            'id': 'v1',
            'type': 'verification',
            'location': 'Lat: 15.75, Lng: 25.25',
            'amount': 2000,
            'status': 'Pending',
          },
        ],
      );

      final result = await repo.getAllHistory();

      final parking = result.firstWhere((e) => e.id == 'p1');
      expect(parking.location, 'Z1 - Zone One');
      expect(parking.latitude, 10.5);
      expect(parking.status, 'success'); // đã lowercase

      final verification = result.firstWhere((e) => e.id == 'v1');
      expect(verification.type, HistoryType.verification);
      expect(verification.latitude, 15.75);
      expect(verification.longitude, 25.25);
    });
  });

  group('getValidationHistory', () {
    test('mở gói items từ PagedResult', () async {
      when(() => client.getJson('api/validations/my-validations')).thenAnswer(
        (_) async => {
          'items': [
            {'id': 'val-1', 'status': 'Pending'},
            {'id': 'val-2', 'status': 'Approved'},
          ],
        },
      );

      final result = await repo.getValidationHistory();
      expect(result.length, 2);
    });
  });
}
