/// ===================================================================
/// FILE PROVIDER - Central state management using Provider + Hive
/// ===================================================================
/// This provider manages all file operations: CRUD, versioning,
/// commenting, sharing, search/filter, offline storage (Hive), and
/// conflict resolution. Uses ChangeNotifier to update the UI.
/// ===================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/file_model.dart';

class FileProvider extends ChangeNotifier {
  // ---- State Variables ----
  List<FileItem> _files = []; // Master list of all files
  bool _isOnline = false; // Simulated connectivity status
  String _searchQuery = ''; // Current search text
  String _filterType = 'All'; // Current file type filter
  String _filterCategory = 'All'; // Personal / Shared / All
  final Uuid _uuid = const Uuid(); // For generating unique IDs

  // Hive box for persistent local storage
  static const String _boxName = 'files_box';

  // ---- Getters ----

  /// Returns all files (unfiltered)
  List<FileItem> get allFiles => List.unmodifiable(_files);

  /// Returns files filtered by search query, type, and category
  List<FileItem> get filteredFiles {
    List<FileItem> result = List.from(_files);

    // Apply search filter (case-insensitive match on file name)
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((f) =>
              f.fileName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply file type filter
    if (_filterType != 'All') {
      result = result.where((f) => f.fileType == _filterType).toList();
    }

    // Apply shared/personal category filter
    if (_filterCategory == 'Shared') {
      result = result.where((f) => f.isShared).toList();
    } else if (_filterCategory == 'Personal') {
      result = result.where((f) => !f.isShared).toList();
    }

    return result;
  }

  /// Returns only shared files
  List<FileItem> get sharedFiles =>
      _files.where((f) => f.isShared).toList();

  /// Returns files that have unsent changes (pending sync)
  List<FileItem> get pendingSyncFiles =>
      _files.where((f) => f.hasPendingSync).toList();

  bool get isOnline => _isOnline;
  String get searchQuery => _searchQuery;
  String get filterType => _filterType;
  String get filterCategory => _filterCategory;

  /// Returns all distinct file types present in the file list
  List<String> get availableFileTypes {
    final types = _files.map((f) => f.fileType).toSet().toList();
    types.sort();
    return ['All', ...types];
  }

  // ---- Initialization (Hive) ----

  /// Load saved files from Hive box (local storage)
  Future<void> loadFiles() async {
    try {
      final box = await Hive.openBox(_boxName);
      final filesJson = box.get('files_data');
      if (filesJson != null) {
        final List<dynamic> decoded = jsonDecode(filesJson);
        _files = decoded.map((e) => FileItem.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading files from Hive: $e');
      _files = [];
    }
    notifyListeners();
  }

  /// Save all files to Hive box (local storage)
  Future<void> _saveFiles() async {
    try {
      final box = await Hive.openBox(_boxName);
      final encoded = jsonEncode(_files.map((f) => f.toJson()).toList());
      await box.put('files_data', encoded);
    } catch (e) {
      debugPrint('Error saving files to Hive: $e');
    }
  }

  // ---- File Management (CRUD) ----

  /// Add a new file with initial version
  /// Returns error message if validation fails, null on success
  String? addFile({
    required String fileName,
    required String fileType,
    required String description,
    String? filePath,
    int? fileSize,
  }) {
    // --- Validation ---
    if (fileName.trim().isEmpty) return 'File name cannot be empty';
    if (fileType.trim().isEmpty) return 'File type is required';
    if (description.trim().isEmpty) return 'Description is required';

    // Check for duplicate file names
    final isDuplicate = _files.any(
      (f) => f.fileName.toLowerCase() == fileName.trim().toLowerCase(),
    );
    if (isDuplicate) return 'A file with this name already exists';

    final now = DateTime.now();
    final fileId = _uuid.v4();

    // Create the file with an initial version (v1)
    final newFile = FileItem(
      id: fileId,
      fileName: fileName.trim(),
      fileType: fileType.trim(),
      description: description.trim(),
      filePath: filePath,
      fileSize: fileSize,
      createdAt: now,
      updatedAt: now,
      hasPendingSync: true, // Needs syncing since created offline
      versions: [
        FileVersion(
          id: _uuid.v4(),
          versionNumber: 1,
          description: 'Initial version',
          timestamp: now,
        ),
      ],
    );

    _files.add(newFile);
    _saveFiles(); // Persist to Hive
    notifyListeners(); // Notify UI to rebuild
    return null; // Success
  }

  /// Delete a file by its ID
  void deleteFile(String fileId) {
    _files.removeWhere((f) => f.id == fileId);
    _saveFiles();
    notifyListeners();
  }

  /// Get a file by ID
  FileItem? getFileById(String id) {
    try {
      return _files.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---- Version Management ----

  /// Update a file — this creates a new version automatically
  String? updateFile({
    required String fileId,
    required String newDescription,
  }) {
    if (newDescription.trim().isEmpty) {
      return 'Version description cannot be empty';
    }

    final file = getFileById(fileId);
    if (file == null) return 'File not found';

    final now = DateTime.now();
    final newVersion = FileVersion(
      id: _uuid.v4(),
      versionNumber: file.currentVersion + 1,
      description: newDescription.trim(),
      timestamp: now,
    );

    file.versions.add(newVersion);
    file.updatedAt = now;
    file.hasPendingSync = true; // Mark as needing sync

    _saveFiles();
    notifyListeners();
    return null;
  }

  // ---- Collaboration (Comments) ----

  /// Add a comment to a file
  String? addComment({
    required String fileId,
    required String author,
    required String text,
  }) {
    if (author.trim().isEmpty) return 'Author name is required';
    if (text.trim().isEmpty) return 'Comment text cannot be empty';

    final file = getFileById(fileId);
    if (file == null) return 'File not found';

    final comment = FileComment(
      id: _uuid.v4(),
      author: author.trim(),
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    file.comments.add(comment);
    file.hasPendingSync = true;

    _saveFiles();
    notifyListeners();
    return null;
  }

  // ---- File Sharing ----

  /// Toggle the shared status of a file
  void toggleShareStatus(String fileId) {
    final file = getFileById(fileId);
    if (file != null) {
      file.isShared = !file.isShared;
      file.hasPendingSync = true;
      _saveFiles();
      notifyListeners();
    }
  }

  // ---- Search & Filter ----

  /// Update the search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set file type filter (e.g., PDF, TXT, All)
  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  /// Set category filter (All, Shared, Personal)
  void setFilterCategory(String category) {
    _filterCategory = category;
    notifyListeners();
  }

  /// Clear all filters and search
  void clearFilters() {
    _searchQuery = '';
    _filterType = 'All';
    _filterCategory = 'All';
    notifyListeners();
  }

  // ---- Offline & Sync ----

  /// Toggle online/offline mode (simulated)
  void toggleOnlineStatus() {
    _isOnline = !_isOnline;
    if (_isOnline) {
      // When going online, simulate syncing all pending files
      _syncPendingFiles();
    }
    notifyListeners();
  }

  /// Simulate syncing pending files when going online
  /// This resolves conflicts using "latest timestamp wins" strategy
  void _syncPendingFiles() {
    for (var file in _files) {
      if (file.hasPendingSync) {
        // Conflict Resolution: keep the latest version
        // In a real app, this would communicate with a server
        // Here we simulate by resolving based on timestamp
        _resolveConflicts(file);
        file.hasPendingSync = false;
      }
    }
    _saveFiles();
    notifyListeners();
  }

  /// Conflict resolution using latest-timestamp-wins strategy
  /// If a file has multiple offline updates, keep all versions
  /// but mark the latest one as the "current" version
  void _resolveConflicts(FileItem file) {
    if (file.versions.length > 1) {
      // Sort versions by timestamp (newest last)
      file.versions.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      // The last version is automatically the "current" one
      // All older versions are preserved in history
    }
  }

  /// Get sync status summary
  String get syncStatusText {
    final pending = pendingSyncFiles.length;
    if (_isOnline && pending == 0) return 'All synced ✓';
    if (_isOnline && pending > 0) return 'Syncing $pending file(s)...';
    if (!_isOnline && pending > 0) return '$pending file(s) pending sync';
    return 'Offline mode';
  }
}
