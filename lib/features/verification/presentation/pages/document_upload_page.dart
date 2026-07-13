import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localizy/core/theme/app_colors.dart';
import 'package:localizy/features/verification/presentation/widgets/verification_ui.dart';
import 'package:localizy/l10n/app_localizations.dart';

class DocumentUploadPage extends StatefulWidget {
  final File? initialIdDocument;
  final File? initialAddressProof;
  final String initialIdType;
  final Function(File, File, String)? onDocumentsUploaded;

  const DocumentUploadPage({
    super.key,
    this.initialIdDocument,
    this.initialAddressProof,
    this.initialIdType = 'cmnd',
    this.onDocumentsUploaded,
  });

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  File? _idDocument;
  File? _addressProof;
  final ImagePicker _picker = ImagePicker();

  String _selectedIdType = 'cmnd';

  @override
  void initState() {
    super.initState();
    _idDocument = widget.initialIdDocument;
    _addressProof = widget.initialAddressProof;
    _selectedIdType = widget.initialIdType;
  }

  Future<void> _pickImage(String documentType) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final XFile? pickedFile = await showModalBottomSheet<XFile>(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext sheetContext) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _buildSourceTile(
                  icon: Icons.photo_library_outlined,
                  label: localizations.chooseFromGallery,
                  source: ImageSource.gallery,
                  sheetContext: sheetContext,
                ),
                _buildSourceTile(
                  icon: Icons.camera_alt_outlined,
                  label: localizations.takePhoto,
                  source: ImageSource.camera,
                  sheetContext: sheetContext,
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );

      if (pickedFile != null) {
        setState(() {
          if (documentType == 'id') {
            _idDocument = File(pickedFile.path);
          } else {
            _addressProof = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.errorSelectingImage}: $e')),
        );
      }
    }
  }

  Widget _buildSourceTile({
    required IconData icon,
    required String label,
    required ImageSource source,
    required BuildContext sheetContext,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.ink,
        ),
      ),
      onTap: () async {
        final file = await _picker.pickImage(source: source);
        if (sheetContext.mounted) {
          Navigator.pop(sheetContext, file);
        }
      },
    );
  }

  void _removeImage(String documentType) {
    setState(() {
      if (documentType == 'id') {
        _idDocument = null;
      } else {
        _addressProof = null;
      }
    });
  }

  bool _canProceed() => _idDocument != null && _addressProof != null;

  void _proceedToNextStep() {
    if (_canProceed()) {
      widget.onDocumentsUploaded
          ?.call(_idDocument!, _addressProof!, _selectedIdType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VerificationInfoBanner(
                    text: localizations.documentUploadIntro),
                const SizedBox(height: 24),
                VerificationSectionTitle(localizations.idDocumentSection),
                const SizedBox(height: 12),
                _buildIdTypeSelector(localizations),
                const SizedBox(height: 12),
                _buildDocumentUploadCard(
                  title: _selectedIdType == 'cmnd'
                      ? localizations.idCardCCCD
                      : localizations.passport,
                  description: localizations.idDocumentDescription,
                  icon: Icons.credit_card,
                  document: _idDocument,
                  onUpload: () => _pickImage('id'),
                  onRemove: () => _removeImage('id'),
                ),
                const SizedBox(height: 24),
                VerificationSectionTitle(localizations.addressProofSection),
                const SizedBox(height: 12),
                _buildDocumentUploadCard(
                  title: localizations.addressProofTitle,
                  description: localizations.addressProofDescription,
                  icon: Icons.receipt_long,
                  document: _addressProof,
                  onUpload: () => _pickImage('address'),
                  onRemove: () => _removeImage('address'),
                ),
                const SizedBox(height: 24),
                VerificationNotesCard(
                  title: localizations.importantNotesTitle,
                  notes: [
                    localizations.noteImageMustBeClear,
                    localizations.noteDocumentMustBeValid,
                    localizations.noteAddressMustMatch,
                    localizations.noteSupportedFormats,
                  ],
                ),
              ],
            ),
          ),
        ),
        _buildBottomBar(localizations),
      ],
    );
  }

  Widget _buildIdTypeSelector(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.documentType,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.fill,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSegment(
                  value: 'cmnd',
                  label: localizations.idCardCCCD,
                  icon: Icons.credit_card,
                ),
              ),
              Expanded(
                child: _buildSegment(
                  value: 'passport',
                  label: localizations.passport,
                  icon: Icons.book_outlined,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegment({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedIdType == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedIdType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected ? AppShadows.cardList : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.muted,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String description,
    required IconData icon,
    required File? document,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    final localizations = AppLocalizations.of(context)!;
    final hasDocument = document != null;

    return Container(
      decoration: verificationCardDecoration(
        borderColor: hasDocument ? AppColors.success.withValues(alpha: 0.4) : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasDocument) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 22),
              ],
            ],
          ),
          const SizedBox(height: 14),
          if (hasDocument)
            _buildPreview(document, onUpload, onRemove, localizations)
          else
            _buildDropZone(onUpload, localizations.uploadDocument),
        ],
      ),
    );
  }

  Widget _buildDropZone(VoidCallback onUpload, String label) {
    return InkWell(
      onTap: onUpload,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_upload_outlined,
                color: AppColors.primary, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(
    File document,
    VoidCallback onChange,
    VoidCallback onRemove,
    AppLocalizations localizations,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Image.file(
            document,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                _buildPreviewAction(
                  icon: Icons.autorenew,
                  tooltip: localizations.tapToChange,
                  onTap: onChange,
                ),
                const SizedBox(width: 8),
                _buildPreviewAction(
                  icon: Icons.delete_outline,
                  tooltip: localizations.delete,
                  color: AppColors.danger,
                  onTap: onRemove,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = AppColors.ink,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(AppLocalizations localizations) {
    final canProceed = _canProceed();
    final uploadedCount =
        [_idDocument, _addressProof].where((f) => f != null).length;

    return VerificationBottomBar(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  canProceed ? Icons.check_circle : Icons.description_outlined,
                  size: 16,
                  color: canProceed ? AppColors.success : AppColors.muted,
                ),
                const SizedBox(width: 6),
                Text(
                  '$uploadedCount/2',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: canProceed ? AppColors.success : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: VerificationPrimaryButton(
              label: localizations.continueButton,
              icon: Icons.arrow_forward,
              onPressed: canProceed ? _proceedToNextStep : null,
            ),
          ),
        ],
      ),
    );
  }
}
