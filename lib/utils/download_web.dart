

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Trigger a real browser file download
void downloadFileBytes(Uint8List bytes, String fileName, BuildContext context) {
  try {
    // Create a Blob from file bytes
    final blob = html.Blob([bytes]);
    // Generate a temporary object URL for the blob
    final url = html.Url.createObjectUrlFromBlob(blob);
    // Create a hidden anchor element, set download attribute, and click it
    final anchor = html.AnchorElement()
      ..href = url
      ..download = fileName
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    // Clean up
    anchor.remove();
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.download_done, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('Downloading "$fileName"...')),
        ]),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download failed: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
