/// ===================================================================
/// DOWNLOAD HELPER - Conditional import bridge
/// ===================================================================
/// On web: loads download_web.dart (real browser download)
/// On mobile: loads download_stub.dart (simulated download)
/// ===================================================================

export 'download_stub.dart' if (dart.library.html) 'download_web.dart';
