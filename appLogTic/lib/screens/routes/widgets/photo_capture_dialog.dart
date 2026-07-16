import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/theme.dart';
import '../../../utils/pair.dart';
import '../../../providers/odoo_provider.dart';

class PhotoCaptureDialog extends StatefulWidget {
  final String partnerName;
  final OdooProvider odoo;
  final int lineId;
  final Pair<double?, double?> currentLocation;

  const PhotoCaptureDialog({
    super.key,
    required this.partnerName,
    required this.odoo,
    required this.lineId,
    required this.currentLocation,
  });

  @override
  State<PhotoCaptureDialog> createState() => _PhotoCaptureDialogState();
}

class _PhotoCaptureDialogState extends State<PhotoCaptureDialog> {
  File? _capturedImage;
  String? _imageBase64;
  final _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _showSourceSelector = true;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        _processImage(File(photo.path));
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _processImage(File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _processImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64Str = base64Encode(bytes);
      setState(() {
        _capturedImage = file;
        _imageBase64 = base64Str;
        _showSourceSelector = false;
      });
    } catch (e) {
      debugPrint('Error processing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📸 Foto de Entrega',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      Text(
                        widget.partnerName,
                        style: const TextStyle(fontSize: 14, color: AppColors.gray600),
                      ),
                    ],
                  ),
                ),
                if (!widget.odoo.isUploadingImage)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.gray600),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            if (_showSourceSelector && _capturedImage == null)
              Column(
                children: [
                  const Text('Selecciona cómo tomar la foto:'),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _SourceButton(
                        icon: Icons.camera_alt,
                        label: 'Cámara',
                        color: AppColors.primary,
                        onTap: _takePhoto,
                      ),
                      _SourceButton(
                        icon: Icons.photo_library,
                        label: 'Galería',
                        color: AppColors.accent,
                        onTap: _pickFromGallery,
                      ),
                    ],
                  ),
                ],
              )
            else
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.gray100,
                    ),
                    child: _capturedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(_capturedImage!, fit: BoxFit.cover),
                          )
                        : const Center(child: Icon(Icons.image, size: 48, color: AppColors.gray400)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas (opcional)',
                      hintText: 'Ej: Entregado en recepción',
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.odoo.isUploadingImage ? null : () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.odoo.isUploadingImage || _imageBase64 == null
                              ? null
                              : () {
                                  widget.odoo.completeLineWithImage(
                                    lineId: widget.lineId,
                                    imageBase64: _imageBase64 ?? '',
                                    latitude: widget.currentLocation.first,
                                    longitude: widget.currentLocation.second,
                                    notes: _notesController.text.isNotEmpty ? _notesController.text : null,
                                    onComplete: (success) {
                                      if (success) {
                                        Navigator.pop(context);
                                        widget.odoo.clearUploadState();
                                      }
                                    },
                                  );
                                },
                          icon: widget.odoo.isUploadingImage
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.cloud_upload, size: 18),
                          label: Text(widget.odoo.isUploadingImage ? 'Subiendo...' : 'Enviar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: color),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}