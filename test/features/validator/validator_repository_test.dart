import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:localizy/core/network/api_exception.dart';
import 'package:localizy/features/validator/data/validator_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  setUpAll(() {
    // any() cho tham số body kiểu Object cần fallback đã đăng ký.
    registerFallbackValue(<String, dynamic>{});
  });

  late MockApiClient client;
  late ValidatorRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = ValidatorRepository(client);
  });

  group('getMyAssignments', () {
    test('mở gói items và parse assignment', () async {
      when(() => client.getJson('api/validations/my-assignments')).thenAnswer(
        (_) async => {
          'items': [
            {'id': 'a1', 'requestId': 'R1', 'status': 'Assigned'},
            {'id': 'a2', 'requestId': 'R2', 'status': 'Scheduled'},
          ],
        },
      );

      final result = await repo.getMyAssignments();

      expect(result.length, 2);
      expect(result.first.id, 'a1');
      expect(result.first.isAssigned, isTrue);
      expect(result[1].isScheduled, isTrue);
    });

    test('nhận List thuần (không bọc items)', () async {
      when(() => client.getJson('api/validations/my-assignments'))
          .thenAnswer((_) async => [
                {'id': 'a1', 'status': 'Verified'},
              ]);

      final result = await repo.getMyAssignments();
      expect(result.single.status, 'Verified');
    });
  });

  group('confirmAppointment', () {
    test('200 → trả assignment đã parse', () async {
      when(() => client.postJson(any(), any())).thenAnswer(
        (_) async => jsonResponse(
            jsonEncode({'id': 'a1', 'status': 'Scheduled'}), 200),
      );

      final updated = await repo.confirmAppointment('a1');

      expect(updated.id, 'a1');
      expect(updated.isScheduled, isTrue);
      verify(() => client.postJson(
          'api/validations/a1/confirm-appointment', any())).called(1);
    });

    test('lỗi → ném ApiException với message từ server', () async {
      when(() => client.postJson(any(), any())).thenAnswer(
        (_) async => jsonResponse(
            jsonEncode({'message': 'Không thể xác nhận'}), 400),
      );

      expect(
        () => repo.confirmAppointment('a1'),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', 'Không thể xác nhận')
            .having((e) => e.statusCode, 'statusCode', 400)),
      );
    });
  });

  group('rejectValidation', () {
    test('200 → hoàn tất, không ném', () async {
      when(() => client.postJson(any(), any()))
          .thenAnswer((_) async => jsonResponse('', 200));

      await expectLater(repo.rejectValidation('a1', 'lý do'), completes);
    });

    test('lỗi 500 không có message → ApiException fallback', () async {
      when(() => client.postJson(any(), any()))
          .thenAnswer((_) async => jsonResponse('', 500));

      expect(
        () => repo.rejectValidation('a1', 'lý do'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 500)),
      );
    });
  });
}
