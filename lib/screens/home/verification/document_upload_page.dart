import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DocumentUploadPage extends StatefulWidget {
  final File? initialIdDocument;
  final File?  initialAddressProof;
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
  File?  _idDocument;
  File?  _addressProof;
  final ImagePicker _picker = ImagePicker();
  
  String _selectedIdType = 'cmnd';

  @override
  void initState() {
    super.initState();
    _idDocument = widget.initialIdDocument;
    _addressProof = widget.initialAddressProof;
    _selectedIdType = widget. initialIdType;
  }

  Future<void> _pickImage(String documentType) async {
    try {
      final XFile? pickedFile = await showModalBottomSheet<XFile>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child:  Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title:  const Text('Chọn từ thư viện'),
                  onTap: () async {
                    final file = await _picker.pickImage(source: ImageSource.gallery);
                    if (context.mounted) {
                      Navigator.pop(context, file);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title:  const Text('Chụp ảnh'),
                  onTap: () async {
                    final file = await _picker.pickImage(source: ImageSource.camera);
                    if (context. mounted) {
                      Navigator. pop(context, file);
                    }
                  },
                ),
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
          SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
        );
      }
    }
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

  bool _canProceed() {
    return _idDocument != null && _addressProof != null;
  }

  void _proceedToNextStep() {
    if (_canProceed()) {
      if (widget.onDocumentsUploaded != null) {
        widget.onDocumentsUploaded! (_idDocument!, _addressProof!, _selectedIdType);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding:  const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // Introduction
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius:  BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons. info_outline,
                    color: Colors.blue.shade700,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Vui lòng tải lên các tài liệu cần thiết để xác minh địa chỉ của bạn',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // ID Document Section
          Text(
            '1. Giấy tờ tùy thân',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          
          const SizedBox(height:  12),
          
          // ID Type Selection
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Loại giấy tờ: ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildRadioOption(
                        value: 'cmnd',
                        label: 'CMND/CCCD',
                        groupValue: _selectedIdType,
                        onChanged: (value) {
                          setState(() {
                            _selectedIdType = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRadioOption(
                        value: 'passport',
                        label: 'Hộ chiếu',
                        groupValue: _selectedIdType,
                        onChanged: (value) {
                          setState(() {
                            _selectedIdType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // ID Document Upload
          _buildDocumentUploadCard(
            title: _selectedIdType == 'cmnd' ? 'CMND/CCCD' : 'Hộ chiếu',
            description: 'Chụp rõ ràng cả 2 mặt của giấy tờ',
            icon: Icons.credit_card,
            color: Colors.blue,
            document: _idDocument,
            onUpload: () => _pickImage('id'),
            onRemove: () => _removeImage('id'),
          ),
          
          const SizedBox(height: 24),
          
          // Address Proof Section
          Text(
            '2. Giấy tờ chứng minh địa chỉ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          
          const SizedBox(height: 12),
          
          _buildDocumentUploadCard(
            title: 'Giấy tờ chứng minh địa chỉ',
            description: 'Hóa đơn điện nước, hợp đồng thuê nhà, giấy đăng ký tạm trú, v.v.',
            icon: Icons.receipt_long,
            color: Colors.orange,
            document: _addressProof,
            onUpload:  () => _pickImage('address'),
            onRemove: () => _removeImage('address'),
          ),
          
          const SizedBox(height: 24),
          
          // Important Notes
          Card(
            elevation: 2,
            color: Colors.amber.shade50,
            shape: RoundedRectangleBorder(
              borderRadius:  BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment. start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Lưu ý quan trọng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildNoteItem('Ảnh phải rõ ràng, không bị mờ hoặc che khuất'),
                  _buildNoteItem('Thông tin trên giấy tờ phải còn hiệu lực'),
                  _buildNoteItem('Địa chỉ trên giấy tờ phải khớp với vị trí xác minh'),
                  _buildNoteItem('Định dạng hỗ trợ: JPG, PNG'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Continue Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _canProceed() ? _proceedToNextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors. grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tiếp tục',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String label,
    required String groupValue,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: groupValue == value ? Colors.green.shade700 : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        title: Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        activeColor: Colors.green.shade700,
      ),
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required File?  document,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color. withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width:  12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style:  TextStyle(
                          fontSize: 12,
                          color: Colors. grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (document == null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton. icon(
                  onPressed:  onUpload,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Tải lên tài liệu'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: color),
                    foregroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border. all(color: Colors.green.shade300),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image. file(
                        document,
                        height: 200,
                        width: double. infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color:  Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Đã tải lên',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton. icon(
                          onPressed:  onRemove,
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text('Xóa'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16),
          ),
          Expanded(
            child: Text(
              text,
              style:  const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}