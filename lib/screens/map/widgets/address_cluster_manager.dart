import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart' as cluster;
import 'package:localizy/api/address_api.dart';

/// Model cho Cluster - implement ClusterItem
class AddressClusterItem with cluster.ClusterItem {
  final AddressCoordinate address;
  final LatLng _location;

  AddressClusterItem({required this.address})
      : _location = LatLng(address.lat, address.lng);

  @override
  LatLng get location => _location;
}

/// Callback khi tap vào một địa chỉ
typedef OnAddressTapped = void Function(AddressCoordinate address);

/// Callback khi tap vào cluster (nhóm điểm)
typedef OnClusterTapped = void Function(LatLng position, double currentZoom);

/// Callback khi markers được cập nhật
typedef OnMarkersUpdated = void Function(Set<Marker> markers);

/// Quản lý clustering các điểm địa chỉ trên bản đồ
class AddressClusterManager {
  late cluster.ClusterManager<AddressClusterItem> _clusterManager;
  List<AddressClusterItem> _clusterItems = [];
  double _currentZoom;
  
  final OnMarkersUpdated onMarkersUpdated;
  final OnAddressTapped? onAddressTapped;
  final OnClusterTapped? onClusterTapped;

  // Cấu hình cluster icon
  final double iconDisplaySize;
  final Color clusterColor;

  AddressClusterManager({
    required this.onMarkersUpdated,
    this.onAddressTapped,
    this.onClusterTapped,
    this.iconDisplaySize = 25,
    this.clusterColor = const Color(0xFF43A047),
    double initialZoom = 14.0,
  }) : _currentZoom = initialZoom {
    _initClusterManager();
  }

  /// Khởi tạo cluster manager
  void _initClusterManager() {
    _clusterManager = cluster.ClusterManager<AddressClusterItem>(
      _clusterItems,
      onMarkersUpdated,
      markerBuilder: _markerBuilder,
      levels: const [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
        11, 12, 13, 14, 15, 16, 17, 18, 19, 20
      ],
      extraPercent: 0.3,
      stopClusteringZoom: 18.0,
    );
  }

  /// Builder cho marker
  Future<Marker> _markerBuilder(cluster.Cluster<AddressClusterItem> clusterData) async {
    final isCluster = clusterData.isMultiple;
    final clusterSize = clusterData.count;

    return Marker(
      markerId: MarkerId(clusterData.getId()),
      position: clusterData.location,
      icon: await _getClusterIcon(clusterSize, isCluster),
      infoWindow: isCluster
          ? InfoWindow(title: '$clusterSize addresses')
          : InfoWindow(title: clusterData.items.first.address.code.isNotEmpty
              ? clusterData.items.first.address.code
              : clusterData.items.first.address.id),
      onTap: () {
        if (isCluster) {
          onClusterTapped?.call(clusterData.location, _currentZoom);
        } else {
          onAddressTapped?.call(clusterData.items.first.address);
        }
      },
    );
  }

  /// Tạo icon cho cluster
  Future<BitmapDescriptor> _getClusterIcon(int clusterSize, bool isCluster) async {
    if (!isCluster) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }

    // Vẽ ở độ phân giải cao (100px), hiển thị iconDisplaySize để sắc nét
    const int canvasSize = 100;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final center = Offset(canvasSize / 2, canvasSize / 2);
    final radius = (canvasSize / 2) - 6.0;

    // Vẽ nền
    final bgPaint = Paint()..color = clusterColor;
    canvas.drawCircle(center, radius, bgPaint);

    // Vẽ viền trắng dày
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius - 4, borderPaint);

    // Vẽ số
    String text = clusterSize > 99 ? '99+' : clusterSize.toString();

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 36,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final image = await pictureRecorder.endRecording().toImage(canvasSize, canvasSize);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(
      data!.buffer.asUint8List(),
      width: iconDisplaySize,
      height: iconDisplaySize,
    );
  }

  /// Thiết lập map ID khi map được tạo
  void setMapId(int mapId) {
    _clusterManager.setMapId(mapId);
  }

  /// Cập nhật danh sách địa chỉ
  void setAddresses(List<AddressCoordinate> addresses) {
    _clusterItems = addresses
        .map((a) => AddressClusterItem(address: a))
        .toList();
    _clusterManager.setItems(_clusterItems);
  }

  /// Xử lý khi camera di chuyển
  void onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
    _clusterManager.onCameraMove(position);
  }

  /// Cập nhật map khi camera dừng
  void updateMap() {
    _clusterManager.updateMap();
  }

  /// Lấy zoom hiện tại
  double get currentZoom => _currentZoom;

  /// Cập nhật zoom
  set currentZoom(double zoom) {
    _currentZoom = zoom;
  }
}