/// ===================================================================
/// FILE CARD WIDGET - Reusable card displaying file summary
/// ===================================================================
/// A Stateless widget used in file lists to show file info at a glance.
/// Shows file icon, name, type, version, share status, and sync indicator.
/// ===================================================================
import 'package:flutter/material.dart';
import '../models/file_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class FileCard extends StatelessWidget {
  final FileItem file;
  final VoidCallback onTap;

  const FileCard({super.key, required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: file.isShared
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // File type icon with colored background
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: FileTypeIcons.getColor(file.fileType).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                FileTypeIcons.getIcon(file.fileType),
                color: FileTypeIcons.getColor(file.fileType),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // File info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          file.fileName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Share indicator badge
                      if (file.isShared)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people,
                                  size: 12, color: AppColors.primary),
                              SizedBox(width: 3),
                              Text('Shared',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Bottom row: type, version, time
                  Row(
                    children: [
                      _chip(file.fileType,
                          FileTypeIcons.getColor(file.fileType)),
                      const SizedBox(width: 6),
                      _chip('v${file.currentVersion}',
                          AppColors.textSecondary),
                      const Spacer(),
                      // Sync status indicator
                      if (file.hasPendingSync)
                        const Icon(Icons.sync,
                            size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        getRelativeTime(file.updatedAt),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }

  /// Build a small info chip
  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
