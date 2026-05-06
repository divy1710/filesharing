

import 'package:flutter/material.dart';

/// App color palette — a modern, professional color scheme
class AppColors {
  // Primary gradient colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF4834D4);

  // Accent colors
  static const Color accent = Color(0xFF00CEC9);
  static const Color accentLight = Color(0xFF81ECEC);

  // Semantic colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDAA5A);
  static const Color error = Color(0xFFE17055);
  static const Color info = Color(0xFF74B9FF);

  // Neutral colors
  static const Color background = Color(0xFFF8F9FD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F8);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint = Color(0xFFB2BEC3);
  static const Color border = Color(0xFFDFE6E9);

  // Card background for shared files
  static const Color sharedBg = Color(0xFFDFE6FF);
  static const Color personalBg = Color(0xFFE8F5E9);
}

/// Predefined file types for the file type dropdown
class FileTypes {
  static const List<String> types = [
    'PDF',
    'DOCX',
    'TXT',
    'PPTX',
    'XLSX',
    'IMG',
    'ZIP',
    'OTHER',
  ];
}

/// Icon mapping for file types — gives visual cues
class FileTypeIcons {
  static IconData getIcon(String type) {
    switch (type.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'DOCX':
        return Icons.description;
      case 'TXT':
        return Icons.text_snippet;
      case 'PPTX':
        return Icons.slideshow;
      case 'XLSX':
        return Icons.table_chart;
      case 'IMG':
        return Icons.image;
      case 'ZIP':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Returns a color associated with a file type
  static Color getColor(String type) {
    switch (type.toUpperCase()) {
      case 'PDF':
        return const Color(0xFFE74C3C);
      case 'DOCX':
        return const Color(0xFF2980B9);
      case 'TXT':
        return const Color(0xFF27AE60);
      case 'PPTX':
        return const Color(0xFFE67E22);
      case 'XLSX':
        return const Color(0xFF1ABC9C);
      case 'IMG':
        return const Color(0xFF9B59B6);
      case 'ZIP':
        return const Color(0xFF7F8C8D);
      default:
        return const Color(0xFF95A5A6);
    }
  }
}
