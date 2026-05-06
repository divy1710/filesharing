/// ===================================================================
/// FILE MODEL - Represents a file in the Smart File Share app
/// ===================================================================
/// This model holds all metadata about a file including its name,
/// type, description, sharing status, versions, and comments.
/// ===================================================================

import 'dart:convert';

/// Represents a single version of a file
/// Each time a file is updated, a new FileVersion is created
class FileVersion {
  final String id; // Unique ID for this version
  final int versionNumber; // e.g. 1, 2, 3...
  final String description; // What changed in this version
  final DateTime timestamp; // When this version was created
  final String? filePath; // Path of the file for this version
  final int? fileSize; // Size of the file for this version

  FileVersion({
    required this.id,
    required this.versionNumber,
    required this.description,
    required this.timestamp,
    this.filePath,
    this.fileSize,
  });

  /// Convert FileVersion to JSON for local storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'versionNumber': versionNumber,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'filePath': filePath,
        'fileSize': fileSize,
      };

  /// Create FileVersion from JSON (when loading from storage)
  factory FileVersion.fromJson(Map<String, dynamic> json) => FileVersion(
        id: json['id'],
        versionNumber: json['versionNumber'],
        description: json['description'],
        timestamp: DateTime.parse(json['timestamp']),
        filePath: json['filePath'],
        fileSize: json['fileSize'],
      );
}

/// Represents a comment on a file for collaboration
class FileComment {
  final String id; // Unique ID for this comment
  final String author; // Who wrote the comment
  final String text; // The comment text
  final DateTime timestamp; // When the comment was posted

  FileComment({
    required this.id,
    required this.author,
    required this.text,
    required this.timestamp,
  });

  /// Convert FileComment to JSON for local storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Create FileComment from JSON (when loading from storage)
  factory FileComment.fromJson(Map<String, dynamic> json) => FileComment(
        id: json['id'],
        author: json['author'],
        text: json['text'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

/// Main file model — represents a shared/personal file
class FileItem {
  final String id; // Unique file ID
  String fileName; // Name of the file
  String fileType; // e.g. PDF, DOCX, TXT, IMG
  String description; // Brief description of file
  String? filePath; // Path of the picked file on device
  int? fileSize; // Size of the picked file in bytes
  bool isShared; // Whether this file is shared with others
  DateTime createdAt; // When the file was first uploaded
  DateTime updatedAt; // When the file was last modified
  List<FileVersion> versions; // Version history
  List<FileComment> comments; // Comment thread
  bool hasPendingSync; // Whether changes need syncing

  FileItem({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.description,
    this.filePath,
    this.fileSize,
    this.isShared = false,
    required this.createdAt,
    required this.updatedAt,
    List<FileVersion>? versions,
    List<FileComment>? comments,
    this.hasPendingSync = false,
  })  : versions = versions ?? [],
        comments = comments ?? [];

  /// Get the current (latest) version number
  int get currentVersion =>
      versions.isEmpty ? 1 : versions.last.versionNumber;

  /// Convert FileItem to JSON for local storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'fileType': fileType,
        'description': description,
        'filePath': filePath,
        'fileSize': fileSize,
        'isShared': isShared,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'versions': versions.map((v) => v.toJson()).toList(),
        'comments': comments.map((c) => c.toJson()).toList(),
        'hasPendingSync': hasPendingSync,
      };

  /// Create FileItem from JSON (when loading from storage)
  factory FileItem.fromJson(Map<String, dynamic> json) => FileItem(
        id: json['id'],
        fileName: json['fileName'],
        fileType: json['fileType'],
        description: json['description'],
        filePath: json['filePath'],
        fileSize: json['fileSize'],
        isShared: json['isShared'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        versions: (json['versions'] as List<dynamic>?)
                ?.map((v) => FileVersion.fromJson(v))
                .toList() ??
            [],
        comments: (json['comments'] as List<dynamic>?)
                ?.map((c) => FileComment.fromJson(c))
                .toList() ??
            [],
        hasPendingSync: json['hasPendingSync'] ?? false,
      );

  /// Serialize the entire FileItem to a JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Deserialize a FileItem from a JSON string
  factory FileItem.fromJsonString(String jsonStr) =>
      FileItem.fromJson(jsonDecode(jsonStr));
}

