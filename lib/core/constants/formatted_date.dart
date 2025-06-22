String formatDate(String dateInput) {
  final date = DateTime.parse(dateInput);
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inDays >= 365) {
    final years = (diff.inDays / 365).floor();
    return '${years}y';
  }

  if (diff.inDays >= 30) {
    final months = (diff.inDays / 30).floor();
    return '${months}mo';
  }

  if (diff.inDays > 0) {
    return '${diff.inDays}d';
  }

  if (diff.inHours > 0) {
    return '${diff.inHours}h';
  }

  if (diff.inMinutes > 0) {
    return '${diff.inMinutes}m';
  }

  return 'now';
}
