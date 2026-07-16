/// Cấu hình website public từ GET /api/settings/website-config.
class WebsiteConfig {
  const WebsiteConfig({
    required this.contact,
    required this.legal,
  });

  final ContactInfo contact;
  final LegalInfo legal;

  factory WebsiteConfig.fromJson(Map<String, dynamic> json) => WebsiteConfig(
        contact: ContactInfo.fromJson(
            (json['contact'] as Map<String, dynamic>?) ?? const {}),
        legal: LegalInfo.fromJson(
            (json['legal'] as Map<String, dynamic>?) ?? const {}),
      );
}

class ContactInfo {
  const ContactInfo({
    required this.email,
    required this.phone,
    required this.address,
  });

  final String email;
  final String phone;
  final String address;

  factory ContactInfo.fromJson(Map<String, dynamic> json) => ContactInfo(
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
      );
}

class LegalInfo {
  const LegalInfo({
    required this.termsOfUse,
    required this.privacyPolicy,
  });

  final String termsOfUse;
  final String privacyPolicy;

  factory LegalInfo.fromJson(Map<String, dynamic> json) => LegalInfo(
        termsOfUse: json['termsOfUse']?.toString() ?? '',
        privacyPolicy: json['privacyPolicy']?.toString() ?? '',
      );
}
