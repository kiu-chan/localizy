import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Render [receipt] ra ảnh PNG (ngoài màn hình) rồi mở share sheet.
Future<void> shareReceiptImage(
  BuildContext context, {
  required Widget receipt,
  required String fileName,
  required String shareText,
}) async {
  final bytes = await _captureWidgetAsImage(context, receipt);
  if (bytes == null) return;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path)], text: shareText),
  );
}

/// Chèn widget vào Overlay ngoài vùng nhìn thấy, chờ 1 frame rồi chụp
/// qua RepaintBoundary — cách duy nhất chụp widget chưa gắn vào cây UI.
Future<Uint8List?> _captureWidgetAsImage(
    BuildContext context, Widget widget) async {
  final key = GlobalKey();
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -10000,
      top: 0,
      child: Material(
        child: RepaintBoundary(
          key: key,
          child: Directionality(
            textDirection: ui.TextDirection.ltr,
            child: widget,
          ),
        ),
      ),
    ),
  );
  Overlay.of(context).insert(entry);
  await WidgetsBinding.instance.endOfFrame;
  await Future.delayed(const Duration(milliseconds: 80));
  try {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  } catch (e) {
    return null;
  } finally {
    entry.remove();
  }
}
