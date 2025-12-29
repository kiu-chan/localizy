import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';
import 'package:localizy/models/plate_country.dart';

class PlateRecognitionService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String> recognizeFromImage(String imagePath, PlateCountry country) async {
    try {
      debugPrint('=== Nhận diện text từ ảnh ===');
      
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      debugPrint('Số blocks: ${recognizedText.blocks.length}');
      
      String detectedPlate = _extractLicensePlate(recognizedText, country);
      
      if (detectedPlate.isNotEmpty) {
        debugPrint('✓ Biển số phát hiện: $detectedPlate');
      } else {
        debugPrint('✗ Không tìm thấy biển số');
      }
      
      return detectedPlate;
    } catch (e) {
      debugPrint('Lỗi nhận diện text: $e');
      return '';
    }
  }

  String _extractLicensePlate(RecognizedText recognizedText, PlateCountry country) {
    List<String> allLines = [];
    
    for (var block in recognizedText.blocks) {
      String blockText = block.text. trim();
      if (blockText.isNotEmpty) {
        allLines.add(blockText);
        debugPrint('Checking block: "$blockText"');
      }
    }
    
    String fullText = recognizedText.text;
    
    if (country == PlateCountry.auto) {
      debugPrint('=== Auto detect country ===');
      
      for (var blockText in allLines) {
        // Chỉ xử lý text có chữ IN HOA
        if (! _hasUppercaseLetters(blockText)) {
          continue;
        }
        
        String vnPlate = _tryExtractVietnameseFromBlock(blockText);
        if (vnPlate.isNotEmpty) {
          debugPrint('✓ Tìm thấy VN trong block: $vnPlate');
          return '🇻🇳 $vnPlate';
        }
        
        String frPlate = _tryExtractFrenchFromBlock(blockText);
        if (frPlate. isNotEmpty) {
          debugPrint('✓ Tìm thấy FR trong block: $frPlate');
          return '🇫🇷 $frPlate';
        }
        
        String cmPlate = _tryExtractCameroonFromBlock(blockText);
        if (cmPlate. isNotEmpty) {
          debugPrint('✓ Tìm thấy CM trong block: $cmPlate');
          return '🇨🇲 $cmPlate';
        }
      }
      
      String vnPlate = _extractVietnamesePlate(allLines, fullText);
      if (vnPlate.isNotEmpty) {
        return '🇻🇳 $vnPlate';
      }
      
      String frPlate = _extractFrenchPlate(allLines, fullText);
      if (frPlate.isNotEmpty) {
        return '🇫🇷 $frPlate';
      }
      
      String cmPlate = _extractCameroonPlate(allLines, fullText);
      if (cmPlate.isNotEmpty) {
        return '🇨🇲 $cmPlate';
      }
      
      // Nếu không tìm thấy pattern chính xác, lấy text gần giống (chỉ IN HOA)
      String nearMatch = _findNearMatchPlate(allLines);
      if (nearMatch.isNotEmpty) {
        debugPrint('✓ Tìm thấy gần giống: $nearMatch');
        return nearMatch;
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
    for (var line in lines) {
      // Chỉ xử lý text có chữ IN HOA
      if (!_hasUppercaseLetters(line)) {
        continue;
      }
      
      // Loại bỏ ký tự đặc biệt, giữ số và chữ IN HOA
      String cleaned = line.replaceAll(RegExp(r'[^0-9A-Z\-]'), '');
      
      // Điều kiện: 4-12 ký tự, có cả số và chữ, chỉ chữ IN HOA
      if (cleaned.length >= 4 && cleaned.length <= 12) {
        bool hasNumber = RegExp(r'\d').hasMatch(cleaned);
        bool hasUpperLetter = RegExp(r'[A-Z]').hasMatch(cleaned);
        bool hasLowerLetter = RegExp(r'[a-z]').hasMatch(line);
        
        // Chỉ chấp nhận nếu có số, có chữ IN HOA, KHÔNG có chữ thường
        if (hasNumber && hasUpperLetter && !hasLowerLetter) {
          debugPrint('Near match found: $cleaned from "$line"');
          return cleaned;
        }
      }
    }
    return '';
  }

  String _tryExtractVietnameseFromBlock(String blockText) {
    List<String> lines = blockText. split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    if (lines.length >= 2) {
      for (int i = 0; i < lines.length - 1; i++) {
        String line1 = lines[i]. replaceAll(RegExp(r'[^0-9A-Za-z-.]'), '').toUpperCase();
        String line2 = lines[i + 1].replaceAll(RegExp(r'[^0-9A-Za-z-.]'), '').toUpperCase();
        
        if (_isVietnameseTwoLinePlate(line1, line2)) {
          return _formatVietnameseTwoLinePlate(line1, line2);
        }
      }
    }
    
    for (var line in lines) {
      String plate = _tryExtractVietnameseSingleLine(line);
      if (plate.isNotEmpty) return plate;
    }
    
    return _tryExtractVietnameseSingleLine(blockText);
  }

  String _tryExtractFrenchFromBlock(String blockText) {
    List<String> lines = blockText.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    for (var line in lines) {
      String plate = _tryExtractFrenchPlate(line);
      if (plate.isNotEmpty) return plate;
    }
    
    return _tryExtractFrenchPlate(blockText);
  }

  String _tryExtractCameroonFromBlock(String blockText) {
    List<String> lines = blockText.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    for (var line in lines) {
      String plate = _tryExtractCameroonPlate(line);
      if (plate.isNotEmpty) return plate;
    }
    
    return _tryExtractCameroonPlate(blockText);
  }

  String _extractVietnamesePlate(List<String> lines, String fullText) {
    debugPrint('=== Tìm biển số Việt Nam ===');
    
    for (var line in lines) {
      // Chỉ xử lý line có chữ IN HOA
      if (!_hasUppercaseLetters(line)) {
        continue;
      }
      
      List<String> subLines = line.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      
      if (subLines.length >= 2) {
        for (int i = 0; i < subLines.length - 1; i++) {
          String line1 = subLines[i]. replaceAll(RegExp(r'[^0-9A-Za-z-.]'), '').toUpperCase();
          String line2 = subLines[i + 1].replaceAll(RegExp(r'[^0-9A-Za-z-.]'), '').toUpperCase();
          
          if (_isVietnameseTwoLinePlate(line1, line2)) {
            return _formatVietnameseTwoLinePlate(line1, line2);
          }
        }
      }
      
      String plate = _tryExtractVietnameseSingleLine(line);
      if (plate.isNotEmpty) return plate;
    }
    
    return '';
  }

  bool _isVietnameseTwoLinePlate(String line1, String line2) {
    String clean1 = line1.replaceAll(RegExp(r'[^0-9A-Z]'), '');
    String clean2 = line2.replaceAll(RegExp(r'[^0-9]'), '');
    
    debugPrint('Check VN 2 lines: "$clean1" + "$clean2"');
    
    if (clean1.length >= 3 && clean1.length <= 6) {
      if (RegExp(r'^\d{2}[A-Z]').hasMatch(clean1)) {
        if (clean2.length >= 4 && clean2.length <= 6 && RegExp(r'^\d+$').hasMatch(clean2)) {
          debugPrint('✓ Match VN 2 lines');
          return true;
        }
      }
    }
    
    return false;
  }

  String _formatVietnameseTwoLinePlate(String line1, String line2) {
    String clean1 = line1.replaceAll(RegExp(r'[^0-9A-Z]'), '');
    String clean2 = line2.replaceAll(RegExp(r'[^0-9]'), '');
    return '$clean1-$clean2';
  }

  String _tryExtractVietnameseSingleLine(String text) {
    final patterns = [
      // 29A12345
      RegExp(r'(\d{2}[A-Z]{1,2}\d{4,5})', caseSensitive: false),
      // 29 A 12345
      RegExp(r'(\d{2})\s*([A-Z]{1,2})\s*(\d{4,5})', caseSensitive: false),
      // 29-A-12345
      RegExp(r'(\d{2})[-\s]*([A-Z]{1,2})[-\s]*(\d{4,5})', caseSensitive: false),
      // H242-GP (format ngắn hơn:  1-4 chữ + số + 1-3 chữ)
      RegExp(r'([A-Z]{1,4})(\d{2,4})[-\s]*([A-Z]{1,3})', caseSensitive: false),
    ];

    for (var i = 0; i < patterns. length; i++) {
      final match = patterns[i].firstMatch(text);
      if (match != null) {
        String plate = match.group(0)!. replaceAll(RegExp(r'[^0-9A-Z\-]'), '').toUpperCase();
        
        if (i == 3) {
          // Pattern đặc biệt cho H242-GP
          debugPrint('✓ Match special pattern: $plate');
          return plate;
        }
        
        if (_isValidVietnamesePlate(plate. replaceAll('-', ''))) {
          return _formatVietnamesePlate(plate.replaceAll('-', ''));
        }
      }
    }
    return '';
  }

  bool _isValidVietnamesePlate(String plate) {
    if (plate.length < 7 || plate.length > 10) return false;
    return RegExp(r'^\d{2}[A-Z]{1,2}\d{4,5}$').hasMatch(plate);
  }

  String _formatVietnamesePlate(String plate) {
    if (plate.length >= 7) {
      int letterStart = 2;
      int letterEnd = letterStart;
      
      while (letterEnd < plate.length && RegExp(r'[A-Z]').hasMatch(plate[letterEnd])) {
        letterEnd++;
      }
      
      if (letterEnd > letterStart && letterEnd < plate.length) {
        String number1 = plate.substring(0, letterStart);
        String letters = plate.substring(letterStart, letterEnd);
        String number2 = plate.substring(letterEnd);
        return '$number1$letters-$number2';
      }
    }
    return plate;
  }

  String _extractFrenchPlate(List<String> lines, String fullText) {
    debugPrint('=== Tìm biển số Pháp ===');
    
    for (var line in lines) {
      // Chỉ xử lý line có chữ IN HOA
      if (!_hasUppercaseLetters(line)) {
        continue;
      }
      
      String plate = _tryExtractFrenchPlate(line);
      if (plate.isNotEmpty) return plate;
    }
    
    return '';
  }

  String _tryExtractFrenchPlate(String text) {
    final patterns = [
      // AA-123-BB
      RegExp(r'([A-Z]{2})[-\s]*(\d{3})[-\s]*([A-Z]{2})', caseSensitive: false),
      // AA123BB
      RegExp(r'([A-Z]{2})(\d{3})([A-Z]{2})', caseSensitive: false),
      // 1234 ABC 12
      RegExp(r'(\d{3,4})\s+([A-Z]{2,3})\s+(\d{2})', caseSensitive: false),
    ];

    for (var i = 0; i < patterns.length; i++) {
      final match = patterns[i].firstMatch(text);
      if (match != null) {
        if (i <= 1) {
          String letters1 = match.group(1)!.toUpperCase();
          String numbers = match.group(2)!;
          String letters2 = match.group(3)!.toUpperCase();
          
          if (_isValidFrenchPlate(letters1, numbers, letters2)) {
            return '$letters1-$numbers-$letters2';
          }
        } else {
          String numbers1 = match.group(1)!;
          String letters = match.group(2)!.toUpperCase();
          String numbers2 = match.group(3)!;
          return '$numbers1 $letters $numbers2';
        }
      }
    }
    return '';
  }

  bool _isValidFrenchPlate(String letters1, String numbers, String letters2) {
    final invalidLetters = ['I', 'O', 'U'];
    
    for (var letter in invalidLetters) {
      if (letters1.contains(letter) || letters2.contains(letter)) {
        return false;
      }
    }
    
    return letters1.length == 2 && numbers.length == 3 && letters2.length == 2;
  }

  String _extractCameroonPlate(List<String> lines, String fullText) {
    debugPrint('=== Tìm biển số Cameroon ===');
    
    for (var line in lines) {
      // Chỉ xử lý line có chữ IN HOA
      if (!_hasUppercaseLetters(line)) {
        continue;
      }
      
      String plate = _tryExtractCameroonPlate(line);
      if (plate.isNotEmpty) return plate;
    }
    
    return '';
  }

  String _tryExtractCameroonPlate(String text) {
    final patterns = [
      // LT 1234 A
      RegExp(r'([A-Z]{2})\s+(\d{4})\s+([A-Z])', caseSensitive: false),
      // LT-1234-A
      RegExp(r'([A-Z]{2})[-\s]+(\d{4})[-\s]+([A-Z])', caseSensitive: false),
      // LT1234A
      RegExp(r'([A-Z]{2})(\d{4})([A-Z])', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String letters1 = match.group(1)!.toUpperCase();
        String numbers = match.group(2)!;
        String letter2 = match.group(3)!.toUpperCase();
        
        if (_isValidCameroonPlate(letters1, numbers, letter2)) {
          return '$letters1 $numbers $letter2';
        }
      }
    }
    return '';
  }

  bool _isValidCameroonPlate(String letters1, String numbers, String letter2) {
    return letters1.length == 2 && numbers.length == 4 && letter2.length == 1;
  }

  void dispose() {
    _textRecognizer. close();
  }
}