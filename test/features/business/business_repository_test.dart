import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:localizy/core/network/api_exception.dart';
import 'package:localizy/features/business/data/business_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  late MockApiClient client;
  late BusinessRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = BusinessRepository(client);
  });

  group('getMySubAccounts', () {
    test('parse danh sách, đọc name→fullName và mặc định isActive=true',
        () async {
      when(() => client.getJson('api/business/sub-accounts')).thenAnswer(
        (_) async => {
          'items': [
            {'id': '1', 'name': 'Alice', 'email': 'a@x.com'},
            {'id': '2', 'fullName': 'Bob', 'email': 'b@x.com', 'isActive': false},
          ],
        },
      );

      final result = await repo.getMySubAccounts();

      expect(result.length, 2);
      expect(result[0].fullName, 'Alice');
      expect(result[0].isActive, isTrue);
      expect(result[1].fullName, 'Bob');
      expect(result[1].isActive, isFalse);
    });
  });

  group('createSubAccount', () {
    test('201 → trả SubAccount đã parse', () async {
      when(() => client.postJson(any(), any())).thenAnswer(
        (_) async => jsonResponse(
            jsonEncode({'id': '9', 'name': 'New', 'email': 'n@x.com'}), 201),
      );

      final created = await repo.createSubAccount(
        email: 'n@x.com',
        fullName: 'New',
        password: 'secret1',
      );

      expect(created.id, '9');
      expect(created.fullName, 'New');
      verify(() => client.postJson('api/business/sub-accounts', any()))
          .called(1);
    });

    test('lỗi → ApiException với message từ server', () async {
      when(() => client.postJson(any(), any())).thenAnswer(
        (_) async =>
            jsonResponse(jsonEncode({'message': 'Email đã tồn tại'}), 409),
      );

      expect(
        () => repo.createSubAccount(
            email: 'dup@x.com', fullName: 'Dup', password: 'secret1'),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', 'Email đã tồn tại')
            .having((e) => e.statusCode, 'statusCode', 409)),
      );
    });
  });

  group('updateSubAccount', () {
    test('200 → trả SubAccount cập nhật', () async {
      when(() => client.putJson(any(), any())).thenAnswer(
        (_) async => jsonResponse(
            jsonEncode({'id': '1', 'name': 'Alice 2', 'phone': '123'}), 200),
      );

      final updated = await repo.updateSubAccount(id: '1', name: 'Alice 2');

      expect(updated.fullName, 'Alice 2');
      expect(updated.phone, '123');
      verify(() => client.putJson('api/business/sub-accounts/1', any()))
          .called(1);
    });
  });

  group('getDashboard', () {
    test('parse thống kê + hoạt động gần đây', () async {
      when(() => client.getJson('api/business/dashboard')).thenAnswer(
        (_) async => {
          'totalLocations': 4,
          'subAccountCount': 2,
          'recentActivities': [
            {
              'type': 'LocationAdded',
              'title': 'Thêm địa điểm',
              'subtitle': 'Zone A',
              'timestamp': '2024-01-01T10:00:00Z',
            },
          ],
        },
      );

      final dashboard = await repo.getDashboard();

      expect(dashboard.totalLocations, 4);
      expect(dashboard.subAccountCount, 2);
      expect(dashboard.recentActivities.single.title, 'Thêm địa điểm');
    });
  });
}
