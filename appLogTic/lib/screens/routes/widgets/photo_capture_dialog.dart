import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
  String? _localError;

  @override
  void initState() {
    super.initState();
    widget.odoo.clearUploadState();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    setState(() => _localError = null);
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (photo != null) {
        _processImage(File(photo.path));
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      setState(() => _localError = 'Error al abrir la cámara: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _localError = null);
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (image != null) {
        _processImage(File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      setState(() => _localError = 'Error al abrir la galería: $e');
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
        _localError = null;
      });
    } catch (e) {
      debugPrint('Error processing image: $e');
      setState(() => _localError = 'Error al procesar la imagen: $e');
    }
  }

  void _completeWithoutPhoto() {
    final odoo = context.read<OdooProvider>();
    odoo.notifyLineCompleted(
      widget.lineId,
      widget.currentLocation.first,
      widget.currentLocation.second,
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entrega completada exitosamente'),
        backgroundColor: AppColors.statusCompletedLight,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final odoo = context.watch<OdooProvider>();
    final isUploading = odoo.isUploadingImage;
    final errorToShow = _localError ?? (odoo.uploadImageError.isNotEmpty ? odoo.uploadImageError : null);

    return AlertDialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.camera_alt, color: AppColors.primary, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Foto de Entrega',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.partnerName,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.gray400 : AppColors.gray600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!isUploading)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Error banner if any
              if (errorToShow != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorToShow,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              if (_showSourceSelector && _capturedImage == null) ...[
                Text(
                  'Selecciona cómo tomar la foto de comprobante:',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.gray300 : AppColors.gray700,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SourceButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Cámara',
                      color: AppColors.primary,
                      onTap: _takePhoto,
                    ),
                    _SourceButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Galería',
                      color: AppColors.secondary,
                      onTap: _pickFromGallery,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: isUploading ? null : _completeWithoutPhoto,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Completar entrega sin foto'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.gray600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ] else ...[
                // Image preview
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isDark ? AppColors.corpDarkGray : AppColors.gray100,
                        border: Border.all(
                          color: isDark ? AppColors.gray700 : AppColors.gray300,
                        ),
                      ),
                      child: _capturedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(_capturedImage!, fit: BoxFit.cover),
                            )
                          : const Center(child: Icon(Icons.image, size: 48, color: AppColors.gray400)),
                    ),
                    if (!isUploading)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.black.withValues(alpha: 0.6),
                          child: IconButton(
                            icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.white),
                            padding: EdgeInsets.zero,
                            tooltip: 'Cambiar foto',
                            onPressed: () {
                              setState(() {
                                _capturedImage = null;
                                _imageBase64 = null;
                                _showSourceSelector = true;
                              });
                            },
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  enabled: !isUploading,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    hintText: 'Ej: Entregado a recepción / firmado',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isUploading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isUploading || _imageBase64 == null
                            ? null
                            : () {
                                odoo.completeLineWithImage(
                                  lineId: widget.lineId,
                                  imageBase64: _imageBase64 ?? '',
                                  latitude: widget.currentLocation.first,
                                  longitude: widget.currentLocation.second,
                                  notes: _notesController.text.trim().isNotEmpty
                                      ? _notesController.text.trim()
                                      : null,
                                  onComplete: (success) {
                                    if (success && mounted) {
                                      Navigator.pop(context);
                                      odoo.clearUploadState();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Entrega completada exitosamente con comprobante'),
                                          backgroundColor: AppColors.statusCompletedLight,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                        icon: isUploading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                              )
                            : const Icon(Icons.check_circle_rounded, size: 18),
                        label: Text(isUploading ? 'Enviando...' : 'Finalizar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusCompleted,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}