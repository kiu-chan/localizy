import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:image_picker/image_picker.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/features/ocr/domain/plate_country.dart';
import '../../data/plate_recognition_service.dart';
import '../widgets/plate_confirm_dialog.dart';
import '../widgets/scanner_camera_view.dart';
import '../widgets/scanner_captured_image_view.dart';
import '../widgets/scanner_help_bottom_sheet.dart';

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

      if (mounted) await _handleDetection(detectedPlate);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
        setState(() { _detectedText = ''; _capturedImagePath = null; });
      }
    } finally {
      if (mounted) setState(() { _isProcessing = false; });
    }
  }

  /// Hiển thị kết quả OCR: mở popup xác nhận nếu đọc được biển số,
  /// báo snackbar nếu không.
  Future<void> _handleDetection(String detectedPlate) async {
    final l10n = AppLocalizations.of(context)!;

    if (detectedPlate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noLicensePlateDetected), duration: const Duration(seconds: 2)),
      );
      setState(() { _detectedText = ''; });
      return;
    }

    setState(() { _detectedText = detectedPlate; _isProcessing = false; });
    final confirmed = await PlateConfirmDialog.show(context, detectedPlate);
    if (!mounted) return;
    if (confirmed == null) {
      _retake();
    } else {
      Navigator.pop(context, confirmed);
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

      if (mounted) await _handleDetection(detectedPlate);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
        setState(() { _detectedText = ''; _capturedImagePath = null; _isGalleryImage = false; });
      }
    } finally {
      if (mounted) setState(() { _isProcessing = false; });
    }
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

    if (_errorText != null) return _buildError(_errorText!);

    if (_controller == null || _initializeControllerFuture == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
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
          return _buildError('${l10n.errorInitializingCamera}: ${snapshot.error}');
        } else {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
      },
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_rounded, size: 56, color: Colors.white.withValues(alpha: 0.7)),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(
          l10n.licensePlateScanner,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () => ScannerHelpBottomSheet.show(context),
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: l10n.scannerHelpTitle,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(),
    );
  }
}
