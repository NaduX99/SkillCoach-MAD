String? extractYoutubeId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  if (uri.host.contains('youtu.be'))
    return uri.pathSegments.isNotEmpty
        ? uri.pathSegments.first : null;
  if (uri.host.contains('youtube.com'))
    return uri.queryParameters['v'];
  return null;
}

/// Validates if a string is a valid email address
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

/// Capitalizes the first letter of each word in a string
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

/// Formats a DateTime into a readable string
String formatDate(DateTime date) {
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
