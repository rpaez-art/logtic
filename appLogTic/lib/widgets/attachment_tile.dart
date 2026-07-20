import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../models/odoo_models.dart';
import '../services/api/retrofit_client.dart';

/// A tile showing a single attachment/document with file icon or image thumbnail.
/// Features elegant card design with soft shadows and elevation animation on tap.
class AttachmentTile extends StatefulWidget {
  final AttachmentData attachment;

  const AttachmentTile({super.key, required this.attachment});

  @override
  State<AttachmentTile> createState() => _AttachmentTileState();
}

class _AttachmentTileState extends State<AttachmentTile> {
  double _elevation = 0.5;
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final bool isImageAttachment = attachment.isImage() &&
        (attachment.downloadUrl != null && attachment.downloadUrl!.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: _elevation,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _isDownloading ? null : () => _openAttachment(context),
          onHighlightChanged: (highlighted) {
            setState(() => _elevation = highlighted ? 3.0 : 0.5);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gray200.withValues(alpha: 0.8)),
            ),
            child: Row(
              children: [
                // Thumbnail preview for images, file icon otherwise
                isImageAttachment
                    ? _buildImageThumbnail()
                    : _buildFileIcon(),
                const SizedBox(width: 12),
                // Name and size
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _buildTypeChip(),
                          const SizedBox(width: 6),
                          Text(
                            attachment.formattedFileSize(),
                            style: const TextStyle(fontSize: 10, color: AppColors.gray500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // View/Download button or Progress Indicator
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _getFileColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _isDownloading
                      ? Padding(
                          padding: const EdgeInsets.all(7),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _getFileColor(),
                          ),
                        )
                      : Icon(
                          isImageAttachment ? Icons.zoom_in : Icons.open_in_new,
                          size: 16,
                          color: _getFileColor(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AttachmentData get attachment => widget.attachment;

  /// Small type badge
  Widget _buildTypeChip() {
    final color = _getFileColor();
    final label = attachment.getExtension();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  /// Builds a small image thumbnail preview from the download URL (with session auth)
  Widget _buildImageThumbnail() {
    final sessionId = CookieManager().getSessionId();
    final headers = sessionId != null && sessionId.isNotEmpty
        ? {'Cookie': 'session_id=$sessionId'}
        : <String, String>{};

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.network(
          attachment.downloadUrl!,
          headers: headers,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            final total = loadingProgress.expectedTotalBytes;
            final progress = total != null
                ? loadingProgress.cumulativeBytesLoaded / total
                : null;
            return Container(
              color: AppColors.gray100,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: progress,
                    color: AppColors.accentDark,
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.accentDark.withValues(alpha: 0.08),
              child: const Icon(Icons.broken_image, size: 22, color: AppColors.gray400),
            );
          },
        ),
      ),
    );
  }

  /// Builds the file type icon for non-image attachments
  Widget _buildFileIcon() {
    IconData iconData;
    if (attachment.isPdf()) {
      iconData = Icons.picture_as_pdf;
    } else {
      iconData = Icons.insert_drive_file;
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getFileColor().withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(iconData, size: 26, color: _getFileColor()),
      ),
    );
  }

  Color _getFileColor() {
    if (attachment.isImage()) return AppColors.accentDark;
    if (attachment.isPdf()) return const Color(0xFFE53935);
    if (attachment.mimetype?.contains('spreadsheet') == true ||
        attachment.mimetype?.contains('excel') == true) {
      return const Color(0xFF2E7D32);
    }
    if (attachment.mimetype?.contains('document') == true ||
        attachment.mimetype?.contains('word') == true) {
      return const Color(0xFF1565C0);
    }
    return AppColors.gray600;
  }

  Future<void> _openAttachment(BuildContext context) async {
    final url = attachment.downloadUrl;
    if (url == null || url.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL de descarga no disponible')),
        );
      }
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final client = RetrofitClient();
      final bytes = await client.downloadAttachmentBytes(
        attachment.id,
        downloadUrl: attachment.downloadUrl,
      );

      if (bytes != null && bytes.isNotEmpty) {
        final tempDir = await getTemporaryDirectory();
        final fileName = attachment.filename != null && attachment.filename!.isNotEmpty
            ? attachment.filename!
            : attachment.name;
        
        final safeFileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
        final file = File('${tempDir.path}/$safeFileName');
        await file.writeAsBytes(bytes);

        final openResult = await OpenFile.open(file.path);
        if (openResult.type != ResultType.done && context.mounted) {
          // If native open was not handled, try external launcher fallback
          await _fallbackLaunchUrl(context, url);
        }
      } else if (context.mounted) {
        await _fallbackLaunchUrl(context, url);
      }
    } catch (e) {
      if (context.mounted) {
        await _fallbackLaunchUrl(context, url);
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _fallbackLaunchUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el documento')),
      );
    }
  }
}

/// Groups attachments by type and displays them in labeled sections.
///
/// Sections: Imágenes, PDFs, Documentos
class AttachmentsGrouped extends StatelessWidget {
  final List<AttachmentData> attachments;

  const AttachmentsGrouped({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    final images = <AttachmentData>[];
    final pdfs = <AttachmentData>[];
    final docs = <AttachmentData>[];

    for (final att in attachments) {
      if (att.isImage() && att.downloadUrl != null && att.downloadUrl!.isNotEmpty) {
        images.add(att);
      } else if (att.isPdf()) {
        pdfs.add(att);
      } else {
        docs.add(att);
      }
    }

    final sections = <_AttachmentGroup>[];

    if (images.isNotEmpty) {
      sections.add(_AttachmentGroup(
        icon: Icons.image,
        title: 'Imágenes',
        count: images.length,
        color: AppColors.accentDark,
        items: images,
      ));
    }
    if (pdfs.isNotEmpty) {
      sections.add(_AttachmentGroup(
        icon: Icons.picture_as_pdf,
        title: 'PDFs',
        count: pdfs.length,
        color: const Color(0xFFE53935),
        items: pdfs,
      ));
    }
    if (docs.isNotEmpty) {
      sections.add(_AttachmentGroup(
        icon: Icons.insert_drive_file,
        title: 'Documentos',
        count: docs.length,
        color: AppColors.gray600,
        items: docs,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((section) => _buildSection(section)).toList(),
    );
  }

  Widget _buildSection(_AttachmentGroup section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6),
            child: Row(
              children: [
                Icon(section.icon, size: 16, color: section.color),
                const SizedBox(width: 6),
                Text(
                  section.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: section.color,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: section.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${section.count}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: section.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Items
          ...section.items.map((att) => AttachmentTile(attachment: att)),
        ],
      ),
    );
  }
}

class _AttachmentGroup {
  final IconData icon;
  final String title;
  final int count;
  final Color color;
  final List<AttachmentData> items;

  const _AttachmentGroup({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    required this.items,
  });
}
