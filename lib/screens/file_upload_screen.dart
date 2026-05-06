
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/file_provider.dart';
import '../utils/constants.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});
  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fileNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedFileType = FileTypes.types.first;

  // Picked file info (optional - user can also just enter metadata)
  String? _pickedFileName;
  String? _pickedFilePath;
  int? _pickedFileSize;
  String? _pickedFileExt;
  Uint8List? _pickedFileBytes; // Actual file bytes for download

  @override
  void dispose() {
    _fileNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Open the device file picker to select a file
  Future<void> _pickFile() async {
    try {
      // withData: true lets us access bytes on web (path is unavailable on web)
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        // On web, file.path THROWS an exception, so we must not access it
        String? safePath;
        if (!kIsWeb) {
          safePath = file.path;
        }
        setState(() {
          _pickedFileName = file.name;
          _pickedFilePath = safePath ?? file.name;
          _pickedFileSize = file.size;
          _pickedFileExt = file.extension;
          _pickedFileBytes = file.bytes; // Store bytes for download
          // Auto-fill the file name from the picked file
          if (_fileNameController.text.isEmpty) {
            _fileNameController.text = file.name.split('.').first;
          }
          // Auto-detect file type from extension
          final ext = file.extension?.toUpperCase() ?? '';
          if (FileTypes.types.contains(ext)) {
            _selectedFileType = ext;
          } else if (['JPG', 'JPEG', 'PNG', 'GIF'].contains(ext)) {
            _selectedFileType = 'IMG';
          } else if (ext == 'DOC') {
            _selectedFileType = 'DOCX';
          } else if (ext == 'PPT') {
            _selectedFileType = 'PPTX';
          } else if (ext == 'XLS') {
            _selectedFileType = 'XLSX';
          } else {
            _selectedFileType = 'OTHER';
          }
        });
      }
    } catch (e) {
      // File picker may fail on some platforms — that's OK
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file picker: $e'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  /// Format file size to human-readable string
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Handle form submission — NOT async, no loading spinner needed
  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<FileProvider>(context, listen: false);
    final error = provider.addFile(
      fileName: _fileNameController.text,
      fileType: _selectedFileType,
      description: _descriptionController.text,
      filePath: _pickedFilePath,
      fileSize: _pickedFileSize,
    );

    if (error == null && _pickedFileBytes != null) {
      // Store bytes in provider so file can be downloaded later
      // Find the file we just added by name
      final addedFile = provider.allFiles.lastWhere(
        (f) => f.fileName == _fileNameController.text.trim(),
      );
      provider.storeFileBytes(addedFile.id, _pickedFileBytes!);
    }

    if (error != null) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Success — go back to file list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File added successfully! ✓'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add New File', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0, backgroundColor: AppColors.primary, foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Pick File from Device (Optional) ----
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _pickedFileName == null
                      ? const Column(
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 50, color: Colors.white),
                            SizedBox(height: 12),
                            Text('Tap to Pick a File (Optional)',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(height: 4),
                            Text('Or just fill in the details below',
                                style: TextStyle(fontSize: 13, color: Colors.white70)),
                          ],
                        )
                      : Column(
                          children: [
                            Icon(FileTypeIcons.getIcon(_selectedFileType), size: 50, color: Colors.white),
                            const SizedBox(height: 12),
                            Text(_pickedFileName!,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 2),
                            const SizedBox(height: 4),
                            Text(
                              '${_pickedFileSize != null ? _formatFileSize(_pickedFileSize!) : ""}  •  ${_pickedFileExt?.toUpperCase() ?? "Unknown"}',
                              style: const TextStyle(fontSize: 13, color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                              child: const Text('Tap to change file', style: TextStyle(fontSize: 12, color: Colors.white)),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ---- File Name ----
              const Text('File Name *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fileNameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Project_Report',
                  prefixIcon: const Icon(Icons.insert_drive_file, color: AppColors.primary),
                  filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter a file name';
                  if (v.trim().length < 2) return 'At least 2 characters required';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ---- File Type ----
              const Text('File Type *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedFileType,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category, color: AppColors.primary),
                  filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
                items: FileTypes.types.map((type) => DropdownMenuItem(value: type,
                  child: Row(children: [
                    Icon(FileTypeIcons.getIcon(type), color: FileTypeIcons.getColor(type), size: 20),
                    const SizedBox(width: 8), Text(type),
                  ]),
                )).toList(),
                onChanged: (val) { if (val != null) setState(() => _selectedFileType = val); },
              ),
              const SizedBox(height: 20),

              // ---- Description ----
              const Text('Description *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe the file contents...',
                  filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter a description';
                  if (v.trim().length < 5) return 'At least 5 characters required';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // ---- Submit Button ----
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.upload_file, size: 20), SizedBox(width: 8),
                    Text('Add File', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // ---- Info Note ----
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 20),
                  SizedBox(width: 10),
                  Expanded(child: Text('Files are stored locally using Hive and sync when online.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
