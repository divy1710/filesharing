

import 'package:intl/intl.dart';

/// Format a DateTime to a user-friendly string
/// e.g., "May 06, 2026 at 2:30 PM"
String formatDateTime(DateTime dt) {
  return DateFormat('MMM dd, yyyy \'at\' h:mm a').format(dt);
}

/// Format a DateTime to a short date string
/// e.g., "May 06, 2026"
String formatDate(DateTime dt) {
  return DateFormat('MMM dd, yyyy').format(dt);
}

/// Format a DateTime to just the time
/// e.g., "2:30 PM"
String formatTime(DateTime dt) {
  return DateFormat('h:mm a').format(dt);
}

/// Get relative time string (e.g., "2 hours ago", "Just now")
String getRelativeTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);

  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return formatDate(dt);
}
