import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/plate_country.dart';
import '../../services/plate_recognition_service.dart';
import '../../widgets/scanner_overlay_painter.dart';

class LicensePlateScannerScreen extends StatefulWidget {
  const LicensePlateScannerScreen({Key? key}) : super(key: key);

  @override
  State<LicensePlateScannerScreen> createState() => _LicensePlateScannerScreenState();
}

class _LicensePlateScannerScreenState extends State<LicensePlateScannerScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String? _errorText;
  bool _isProcessing = false;
  String _detectedText = '';
  final ImagePicker _imagePicker = ImagePicker();
  final PlateRecognitionService _recognitionService = PlateRecognitionService();
  Rect? _scanArea;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorText = 'Không tìm thấy camera nào trên thiết bị. ';
        });
        return;
      }

      final backCamera = cameras. firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      if (mounted) setState(() {});
    } on CameraException catch (e) {
      setState(() {
        _errorText = 'Lỗi Camera: ${e.code} ${e.description}';
      });
    } catch (e) {
      setState(() {
        _errorText = 'Lỗi khi khởi tạo camera: $e';
      });
    }
  }

  void _calculateScanArea(Size screenSize) {
    final scanWidth = screenSize.width * 0.85;
    final scanHeight = screenSize.height * 0.3;
    final left = (screenSize.width - scanWidth) / 2;
    final top = (screenSize.height - scanHeight) / 2;
    
    _scanArea = Rect. fromLTWH(left, top, scanWidth, scanHeight);
  }

  Future<void> _captureAndProcessImage() async {
    if (_controller == null || !_controller! .value.isInitialized) {
      return;
    }

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _detectedText = 'Đang nhận diện... ';
    });

    try {
      final XFile picture = await _controller!.takePicture();
      
      final detectedPlate = await _recognitionService.recognizeFromImage(
        picture. path,
        PlateCountry.auto,
      );
      
      try {
        await File(picture.path).delete();
      } catch (e) {
        debugPrint('Không thể xóa file: $e');
      }
      
      if (mounted) {
        if (detectedPlate. isNotEmpty) {
          setState(() {
            _detectedText = detectedPlate;
          });
          _showEditDialog(detectedPlate);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không phát hiện biển số xe'),
              duration: Duration(seconds: 2),
            ),
          );
          setState(() {
            _detectedText = '';
          });
        }
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi:  $e')),
        );
        setState(() {
          _detectedText = '';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _isProcessing = true;
      _detectedText = 'Đang xử lý...';
    });

    try {
      final XFile?  image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        final detectedPlate = await _recognitionService.recognizeFromImage(
          image.path,
          PlateCountry.auto,
        );
        
        if (mounted) {
          if (detectedPlate.isNotEmpty) {
            setState(() {
              _detectedText = detectedPlate;
            });
            _showEditDialog(detectedPlate);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không phát hiện biển số xe'),
                duration: Duration(seconds: 2),
              ),
            );
            setState(() {
              _detectedText = '';
            });
          }
        }
      } else {
        setState(() {
          _detectedText = '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
        setState(() {
          _detectedText = '';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showEditDialog(String detectedPlate) {
    final TextEditingController controller = TextEditingController(text: detectedPlate);
    
    showDialog(
      context:  context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            const Expanded(child: Text('Xác nhận biển số xe')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biển số đã phát hiện:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height:  12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Nhập biển số xe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue. shade200, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:  BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue. shade200, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius. circular(12),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.blue.shade50,
                prefixIcon: Icon(Icons.directions_car, color: Colors.blue.shade700),
              ),
              style:  const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization. characters,
              autofocus: true,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors. amber.shade900),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hỗ trợ:  Việt Nam 🇻🇳, Pháp 🇫🇷, Cameroon 🇨🇲',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors. amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton. icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                _detectedText = '';
              });
            },
            icon: const Icon(Icons.close),
            label: const Text('Hủy'),
          ),
          ElevatedButton. icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors. white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              final plateNumber = controller.text.trim().toUpperCase();
              if (plateNumber.isNotEmpty) {
                Navigator.pop(dialogContext);
                Navigator.pop(context, plateNumber);
              } else {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập biển số xe')),
                );
              }
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?. dispose();
    _recognitionService.dispose();
    super.dispose();
  }

  Widget _buildCameraPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Container();
    }

    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorText != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height:  16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorText!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (_controller == null || _initializeControllerFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scanArea == null) {
              _calculateScanArea(MediaQuery.of(context).size);
            }
          });

          return Stack(
            fit:  StackFit.expand,
            children: [
              _buildCameraPreview(),
              
              CustomPaint(
                painter: ScannerOverlayPainter(),
                child: Container(),
              ),
              
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets. all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                      const SizedBox(height: 8),
                      const Text(
                        'Đặt biển số xe vào trong khung',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tự động nhận diện:  Việt Nam 🇻🇳, Pháp 🇫🇷, Cameroon 🇨🇲',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (_detectedText.isNotEmpty)
                Positioned(
                  bottom: 180,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: _detectedText.contains('Đang') ? Colors.orange : Colors.green,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius:  10,
                          offset:  Offset(0, 4),
                        ),
                      ],
                    ),
                    child:  Column(
                      children: [
                        Icon(
                          _detectedText.contains('Đang') ? Icons.search :  Icons.check_circle,
                          color:  Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _detectedText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      heroTag: 'gallery',
                      onPressed: _isProcessing ? null : _pickImageFromGallery,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.photo_library, color: Colors.blue),
                    ),
                    
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FloatingActionButton. large(
                        heroTag: 'capture',
                        onPressed: _isProcessing ? null : _captureAndProcessImage,
                        backgroundColor: Colors.white,
                        child: _isProcessing
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.camera_alt, size: 40, color: Colors.red),
                      ),
                    ),
                    
                    FloatingActionButton(
                      heroTag: 'flash',
                      onPressed: () async {
                        if (_controller != null) {
                          final currentFlashMode = _controller!.value. flashMode;
                          await _controller!.setFlashMode(
                            currentFlashMode == FlashMode.off 
                                ? FlashMode. torch 
                                : FlashMode.off
                          );
                          setState(() {});
                        }
                      },
                      backgroundColor: Colors. white,
                      child: Icon(
                        _controller?. value.flashMode == FlashMode.torch
                            ? Icons.flash_on
                            : Icons.flash_off,
                        color:  Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Center(
            child:  Column(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Lỗi khi khởi tạo camera: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét biển số xe'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }
}