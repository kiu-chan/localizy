import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localizy/features/auth/presentation/widgets/auth_emblem.dart';
import 'package:lottie/lottie.dart';

void main() {
  for (final kind in AuthEmblemKind.values) {
    testWidgets('hoạt ảnh ${kind.name} nạp được từ assets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: AuthEmblem(kind: kind)))),
      );
      // Lottie giải mã JSON bất đồng bộ.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LottieBuilder), findsOneWidget);
      // Rơi vào icon dự phòng nghĩa là sai đường dẫn asset hoặc file hỏng.
      expect(find.byIcon(kind.fallbackIcon), findsNothing);

      // Đọc thẳng file để chắc chắn JSON parse được, không chỉ là chưa lỗi.
      final composition =
          await tester.runAsync(() => AssetLottie(kind.asset).load());
      expect(composition!.duration, greaterThan(Duration.zero));
    });
  }
}
