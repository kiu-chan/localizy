import 'package:flutter/material.dart';

/// Snapshot dữ liệu form khi người dùng chuyển sang chế độ chọn tọa độ trên bản đồ
class FormSnapshot {
  final String name;
  final String fullAddress;
  final String cityId;

  const FormSnapshot({
    required this.name,
    required this.fullAddress,
    required this.cityId,
  });
}

/// Màu badge theo status địa chỉ
Color addressStatusColor(String status) {
  switch (status) {
    case 'Reviewed':
      return Colors.green;
    case 'Rejected':
      return Colors.red;
    default:
      return Colors.orange;
  }
}
