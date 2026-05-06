/// ===================================================================
/// SYNC STATUS BAR WIDGET - Shows online/offline status and sync info
/// ===================================================================
/// A Stateless widget that displays connectivity status and allows
/// toggling between online/offline modes (simulated).
/// ===================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/file_provider.dart';
import '../utils/constants.dart';

class SyncStatusBar extends StatelessWidget {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FileProvider>(builder: (context, provider, _) {
      final isOnline = provider.isOnline;
      final statusText = provider.syncStatusText;

      return GestureDetector(
        onTap: () => provider.toggleOnlineStatus(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: isOnline ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
          child: Row(
            children: [
              // Connectivity indicator dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? AppColors.success : AppColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              // Status icon
              Icon(
                isOnline ? Icons.cloud_done : Icons.cloud_off,
                size: 18,
                color: isOnline ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 8),
              // Status text
              Expanded(
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isOnline ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
              // Toggle button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.success : AppColors.warning,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOnline ? 'Go Offline' : 'Go Online',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
