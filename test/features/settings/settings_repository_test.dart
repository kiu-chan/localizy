import 'package:flutter_test/flutter_test.dart';
import 'package:localizy/features/settings/data/settings_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  late MockApiClient client;
  late SettingsRepository repository;

  setUp(() {
    client = MockApiClient();
    repository = SettingsRepository(client);
  });

  group('getWebsiteConfig', () {
    test('parse đầy đủ contact và legal', () async {
      when(() => client.getJson('api/settings/website-config'))
          .thenAnswer((_) async => {
                'contact': {
                  'email': 'contact@citea.fr',
                  'phone': '+33 1 23 45 67 89',
                  'address': 'Paris, France',
                },
                'legal': {
                  'termsOfUse': 'Điều khoản sử dụng...',
                  'privacyPolicy': 'Chính sách bảo mật...',
                },
              });

      final config = await repository.getWebsiteConfig();

      expect(config.contact.email, 'contact@citea.fr');
      expect(config.contact.phone, '+33 1 23 45 67 89');
      expect(config.contact.address, 'Paris, France');
      expect(config.legal.termsOfUse, 'Điều khoản sử dụng...');
      expect(config.legal.privacyPolicy, 'Chính sách bảo mật...');
    });

    test('thiếu section / field null → chuỗi rỗng, không crash', () async {
      when(() => client.getJson('api/settings/website-config'))
          .thenAnswer((_) async => {
                'contact': {'email': null},
              });

      final config = await repository.getWebsiteConfig();

      expect(config.contact.email, '');
      expect(config.contact.phone, '');
      expect(config.legal.termsOfUse, '');
      expect(config.legal.privacyPolicy, '');
    });
  });
}
