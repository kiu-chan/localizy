enum PlateCountry {
  vietnam,
  france,
  cameroon,
  auto,
}

extension PlateCountryExtension on PlateCountry {
  String get displayName {
    switch (this) {
      case PlateCountry.vietnam:
        return '🇻🇳 Việt Nam';
      case PlateCountry.france:
        return '🇫🇷 Pháp';
      case PlateCountry.cameroon:
        return '🇨🇲 Cameroon';
      case PlateCountry. auto:
        return '🌍 Tự động';
    }
  }

  String get flag {
    switch (this) {
      case PlateCountry. vietnam:
        return '🇻🇳';
      case PlateCountry.france:
        return '🇫🇷';
      case PlateCountry.cameroon:
        return '🇨🇲';
      case PlateCountry. auto:
        return '';
    }
  }
}