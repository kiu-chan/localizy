import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/models/plate_country.dart';
import '../../services/plate_recognition_service.dart';
import 'widgets/scanner_camera_view.dart';
import 'widgets/scanner_captured_image_view.dart';
import 'widgets/scanner_help_bottom_sheet.dart';

class LicensePlateScannerScreen extends StatefulWidget {
  const LicensePlateScannerScreen({super.key});

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
  bool _isSetupCameraCalled = false;
  String? _capturedImagePath;
  bool _isGalleryImage = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isSetupCameraCalled) {
      _isSetupCameraCalled = true;
      _setupCamera();
    }
  }

  Future<void> _setupCamera() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() { _errorText = l10n.noCameraFound; });
        return;
      }
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _controller = CameraController(
        backCamera, ResolutionPreset.high,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      await _controller!.setFlashMode(FlashMode.off);
      if (mounted) setState(() {});
    } on CameraException catch (e) {
      if (mounted) setState(() { _errorText = '${l10n.cameraError}: ${e.code} ${e.description}'; });
    } catch (e) {
      if (mounted) setState(() { _errorText = '${l10n.errorInitializingCamera}: $e'; });
    }
  }

  void _retake() {
    if (_capturedImagePath != null && !_isGalleryImage) {
      try { File(_capturedImagePath!).deleteSync(); } catch (_) {}
    }
    setState(() {
      _capturedImagePath = null;
      _detectedText = '';
      _isGalleryImage = false;
    });
  }

  Future<void> _captureAndProcessImage() async {
    final l10n = AppLocalizations.of(context)!;
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isProcessing) return;

    setState(() { _isProcessing = true; });
    try {
      final XFile picture = await _controller!.takePicture();

      if (mounted) {
        setState(() { _capturedImagePath = picture.path; _isProcessing = false; });
        await WidgetsBinding.instance.endOfFrame;
      }
      if (mounted) setState(() { _isProcessing = true; _detectedText = l10n.recognizing; });

      final detectedPlate = await _recognitionService.recognizeFromImage(picture.path, PlateCountry.auto);

      if (mounted) {
        if (detectedPlate.isNotEmpty) {
          setState(() { _detectedText = detectedPlate; });
          _showEditDialog(detectedPlate);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noLicensePlateDetected), duration: const Duration(seconds: 2)),
          );
          setState(() { _detectedText = ''; });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
        setState(() { _detectedText = ''; _capturedImagePath = null; });
      }
    } finally {
      if (mounted) setState(() { _isProcessing = false; });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      if (mounted) {
        setState(() { _capturedImagePath = image.path; _isGalleryImage = true; _isProcessing = false; });
        await WidgetsBinding.instance.endOfFrame;
      }
      if (mounted) setState(() { _isProcessing = true; _detectedText = l10n.processing; });

      final detectedPlate = await _recognitionService.recognizeFromImage(image.path, PlateCountry.auto);

      if (mounted) {
        if (detectedPlate.isNotEmpty) {
          setState(() { _detectedText = detectedPlate; });
          _showEditDialog(detectedPlate);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noLicensePlateDetected), duration: const Duration(seconds: 2)),
          );
          setState(() { _detectedText = ''; });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
        setState(() { _detectedText = ''; _capturedImagePath = null; _isGalleryImage = false; });
      }
    } finally {
      if (mounted) setState(() { _isProcessing = false; });
    }
  }

  void _showEditDialog(String detectedPlate) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: detectedPlate);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.confirmLicensePlate)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.detectedLicensePlate, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: l10n.enterLicensePlate,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade200, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade200, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.blue.shade50,
                prefixIcon: Icon(Icons.directions_car, color: Colors.blue.shade700),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              autofocus: true,
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () { Navigator.pop(dialogContext); _retake(); },
            icon: const Icon(Icons.close),
            label: Text(l10n.cancel),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              final plateNumber = controller.text.trim().toUpperCase();
              if (plateNumber.isNotEmpty) {
                Navigator.pop(dialogContext);
                Navigator.pop(context, plateNumber);
              } else {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(l10n.pleaseEnterLicensePlate)),
                );
              }
            },
            icon: const Icon(Icons.check_circle),
            label: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _recognitionService.dispose();
    if (_capturedImagePath != null && !_isGalleryImage) {
      try { File(_capturedImagePath!).deleteSync(); } catch (_) {}
    }
    super.dispose();
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;

    if (_errorText != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_errorText!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
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
          if (_capturedImagePath != null) {
            return ScannerCapturedImageView(
              imagePath: _capturedImagePath!,
              isProcessing: _isProcessing,
              detectedText: _detectedText,
              onRetake: _retake,
            );
          }
          return ScannerCameraView(
            controller: _controller!,
            isProcessing: _isProcessing,
            detectedText: _detectedText,
            onCapture: _captureAndProcessImage,
            onGallery: _pickImageFromGallery,
            onHelp: () => ScannerHelpBottomSheet.show(context),
            onFlashToggle: () async {
              if (_controller != null) {
                final mode = _controller!.value.flashMode;
                await _controller!.setFlashMode(
                  mode == FlashMode.off ? FlashMode.torch : FlashMode.off,
                );
                setState(() {});
              }
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${l10n.errorInitializingCamera}: ${snapshot.error}',
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.licensePlateScanner),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }
}
