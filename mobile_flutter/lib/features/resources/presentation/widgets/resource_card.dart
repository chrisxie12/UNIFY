import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/community_resource_model.dart';

class ResourceCard extends ConsumerWidget {
  final CommunityResourceModel resource;
  final VoidCallback? onDownload;

  const ResourceCard({
    super.key,
    required this.resource,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      color: Colors.white,
      child: InkWell(
        onTap: onDownload,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _fileIconColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _fileIcon(),
                  color: _fileIconColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          resource.uploaderName ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (resource.uploaderName != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          DateFormat('MMM d, yyyy').format(resource.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            resource.fileType.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.download_outlined,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Text(
                          '${resource.downloadCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF0066FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download_rounded, size: 20),
                  color: const Color(0xFF0066FF),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _fileIcon() {
    switch (resource.fileType) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'docx':
      case 'doc':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      case 'video':
      case 'mp4':
        return Icons.videocam;
      case 'audio':
      case 'mp3':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _fileIconColor() {
    switch (resource.fileType) {
      case 'pdf':
        return Colors.red;
      case 'docx':
      case 'doc':
        return const Color(0xFF0066FF);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFFF6B35);
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.green;
      case 'zip':
      case 'rar':
        return Colors.amber.shade700;
      case 'video':
      case 'mp4':
        return Colors.purple;
      case 'audio':
      case 'mp3':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
