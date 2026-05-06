
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/file_provider.dart';
import '../models/file_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/download_helper.dart';

class FileDetailScreen extends StatefulWidget {
  final String fileId;
  const FileDetailScreen({super.key, required this.fileId});
  @override
  State<FileDetailScreen> createState() => _FileDetailScreenState();
}

class _FileDetailScreenState extends State<FileDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _versionDescController = TextEditingController();
  final _commentTextController = TextEditingController();
  final _commentAuthorController = TextEditingController();

  // State variables for picking a new file for the version
  String? _pickedFileName;
  String? _pickedFilePath;
  int? _pickedFileSize;
  String? _pickedFileExt;
  Uint8List? _pickedFileBytes;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _versionDescController.dispose();
    _commentTextController.dispose();
    _commentAuthorController.dispose();
    super.dispose();
  }

  /// Open file picker to select a new version file
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        String? safePath;
        if (!kIsWeb) {
          safePath = file.path;
        }
        setState(() {
          _pickedFileName = file.name;
          _pickedFilePath = safePath ?? file.name;
          _pickedFileSize = file.size;
          _pickedFileExt = file.extension;
          _pickedFileBytes = file.bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file picker: $e'), backgroundColor: AppColors.warning),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FileProvider>(builder: (context, provider, _) {
      final file = provider.getFileById(widget.fileId);
      if (file == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('File Not Found')),
          body: const Center(child: Text('This file no longer exists.')),
        );
      }
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(file.fileName, style: const TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0, backgroundColor: AppColors.primary, foregroundColor: Colors.white,
          actions: [
            // Download file
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                final bytes = provider.getFileBytes(file.id);
                if (bytes != null) {
                  // Extension from file type
                  final ext = file.fileType.toLowerCase();
                  final downloadName = '${file.fileName}.$ext';
                  downloadFileBytes(bytes, downloadName, context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('No file data available. Pick a file first when uploading.'),
                    backgroundColor: AppColors.warning,
                  ));
                }
              },
              tooltip: 'Download file',
            ),
            // Share/unshare toggle
            IconButton(
              icon: Icon(file.isShared ? Icons.people : Icons.person_add),
              onPressed: () {
                provider.toggleShareStatus(file.id);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(file.isShared ? 'File shared!' : 'File unshared'),
                  backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
                ));
              },
              tooltip: file.isShared ? 'Unshare' : 'Share',
            ),
            // Delete file
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, provider, file),
              tooltip: 'Delete file',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(icon: Icon(Icons.info_outline), text: 'Info'),
              Tab(icon: Icon(Icons.history), text: 'Versions'),
              Tab(icon: Icon(Icons.comment), text: 'Comments'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildInfoTab(file),
            _buildVersionsTab(file, provider),
            _buildCommentsTab(file, provider),
          ],
        ),
      );
    });
  }
  /// Format file size to human-readable string
  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Info tab — shows file metadata
  Widget _buildInfoTab(FileItem file) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // File icon card
        Container(
          width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [FileTypeIcons.getColor(file.fileType), FileTypeIcons.getColor(file.fileType).withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            Icon(FileTypeIcons.getIcon(file.fileType), size: 60, color: Colors.white),
            const SizedBox(height: 12),
            Text(file.fileName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(file.fileType, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 20),
        // Details card
        _infoCard('Description', file.description, Icons.description),
        if (file.filePath != null)
          _infoCard('File Path', file.filePath!, Icons.folder_open),
        if (file.fileSize != null)
          _infoCard('File Size', _formatSize(file.fileSize!), Icons.data_usage),
        _infoCard('Created', formatDateTime(file.createdAt), Icons.calendar_today),
        _infoCard('Last Updated', formatDateTime(file.updatedAt), Icons.update),
        _infoCard('Current Version', 'v${file.currentVersion}', Icons.tag),
        _infoCard('Status', file.isShared ? 'Shared' : 'Personal', file.isShared ? Icons.people : Icons.person),
        _infoCard('Sync Status', file.hasPendingSync ? 'Pending sync' : 'Synced', file.hasPendingSync ? Icons.sync_problem : Icons.cloud_done),
        _infoCard('Comments', '${file.comments.length}', Icons.comment),
      ]),
    );
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary, fontSize: 13)),
        const Spacer(),
        Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.end)),
      ]),
    );
  }

  /// Versions tab — shows version history and add new version
  Widget _buildVersionsTab(FileItem file, FileProvider provider) {
    return Column(children: [
      // Add new version
      Container(
        margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Create New Version', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          TextField(
            controller: _versionDescController,
            decoration: InputDecoration(
              hintText: 'Describe changes...',
              filled: true, fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          // Option to upload an updated file
          Row(
            children: [
              Expanded(
                child: Text(
                  _pickedFileName ?? 'No new file selected (metadata update only)',
                  style: TextStyle(
                    fontSize: 13,
                    color: _pickedFileName != null ? AppColors.textPrimary : AppColors.textHint,
                    fontStyle: _pickedFileName == null ? FontStyle.italic : FontStyle.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_pickedFileName != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _pickedFileName = null;
                      _pickedFilePath = null;
                      _pickedFileSize = null;
                      _pickedFileExt = null;
                      _pickedFileBytes = null;
                    });
                  },
                ),
              TextButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Pick File'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final error = provider.updateFile(
                  fileId: file.id,
                  newDescription: _versionDescController.text,
                  filePath: _pickedFilePath,
                  fileSize: _pickedFileSize,
                  fileExt: _pickedFileExt,
                  fileBytes: _pickedFileBytes,
                );
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppColors.error));
                } else {
                  _versionDescController.clear();
                  setState(() {
                    _pickedFileName = null;
                    _pickedFilePath = null;
                    _pickedFileSize = null;
                    _pickedFileExt = null;
                    _pickedFileBytes = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New version created! ✓'), backgroundColor: AppColors.success),
                  );
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Version'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ]),
      ),
      // Version list
      Expanded(
        child: file.versions.isEmpty
            ? const Center(child: Text('No versions yet'))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: file.versions.length,
                itemBuilder: (_, i) {
                  final version = file.versions[file.versions.length - 1 - i]; // newest first
                  final isLatest = i == 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isLatest ? AppColors.primaryLight.withOpacity(0.1) : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isLatest ? AppColors.primary.withOpacity(0.3) : AppColors.border),
                    ),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: isLatest ? AppColors.primary : AppColors.textHint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text('v${version.versionNumber}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(version.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(formatDateTime(version.timestamp),
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            if (version.fileSize != null)
                              Text(' • Updated (${_formatFileSize(version.fileSize!)})',
                                  style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ])),
                      if (isLatest) Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(8)),
                        child: const Text('Latest', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  );
                },
              ),
      ),
    ]);
  }

  /// Comments tab — shows comment thread and add new comment
  Widget _buildCommentsTab(FileItem file, FileProvider provider) {
    return Column(children: [
      // Add comment form
      Container(
        margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Add Comment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          TextField(
            controller: _commentAuthorController,
            decoration: InputDecoration(
              hintText: 'Your name',
              prefixIcon: const Icon(Icons.person, size: 20),
              filled: true, fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentTextController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Write a comment...',
              filled: true, fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final error = provider.addComment(
                  fileId: file.id,
                  author: _commentAuthorController.text,
                  text: _commentTextController.text,
                );
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppColors.error));
                } else {
                  _commentTextController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comment added! ✓'), backgroundColor: AppColors.success),
                  );
                }
              },
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Post Comment'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ]),
      ),
      // Comments list
      Expanded(
        child: file.comments.isEmpty
            ? const Center(child: Text('No comments yet. Start the discussion!', style: TextStyle(color: AppColors.textHint)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: file.comments.length,
                itemBuilder: (_, i) {
                  final comment = file.comments[file.comments.length - 1 - i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        CircleAvatar(
                          radius: 16, backgroundColor: AppColors.primaryLight,
                          child: Text(comment.author.isNotEmpty ? comment.author[0].toUpperCase() : '?',
                              style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        const SizedBox(width: 10),
                        Text(comment.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Spacer(),
                        Text(getRelativeTime(comment.timestamp), style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                      ]),
                      const SizedBox(height: 8),
                      Text(comment.text, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                    ]),
                  );
                },
              ),
      ),
    ]);
  }

  /// Show delete confirmation dialog
  void _confirmDelete(BuildContext context, FileProvider provider, FileItem file) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete File?'),
        content: Text('Are you sure you want to delete "${file.fileName}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.deleteFile(file.id);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to list
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
