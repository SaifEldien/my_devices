bool isUrl(String path) {
  final uri = Uri.tryParse(path);
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https');
}
