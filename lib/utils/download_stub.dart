
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// On mobile: show a simulated download message
void downloadFileBytes(Uint8List bytes, String fileName, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('File "$fileName" saved to Downloads'),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
