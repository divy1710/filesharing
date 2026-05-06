/// ===================================================================
/// SHARED FILES SCREEN - Shows only shared files
/// ===================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/file_provider.dart';
import '../utils/constants.dart';
import '../widgets/file_card.dart';
import 'file_detail_screen.dart';

/// SharedFilesScreen - Stateless widget (no local state needed)
/// Displays files that have been marked as "shared"
class SharedFilesScreen extends StatelessWidget {
  const SharedFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FileProvider>(builder: (context, provider, _) {
      final sharedFiles = provider.sharedFiles;
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Shared Files', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0, backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        ),
        body: sharedFiles.isEmpty
            ? Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.people_outline, size: 80, color: AppColors.textHint.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('No shared files', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  const Text('Share files from the file details screen', style: TextStyle(fontSize: 14, color: AppColors.textHint)),
                ]),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sharedFiles.length,
                itemBuilder: (_, i) {
                  final file = sharedFiles[i];
                  return FileCard(
                    file: file,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FileDetailScreen(fileId: file.id))),
                  );
                },
              ),
      );
    });
  }
}
