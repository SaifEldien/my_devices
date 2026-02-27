String getNameFromEmail(String email) {
  if (!email.contains('@')) return "User";
  String namePart = email.split('@')[0];
  namePart = namePart.replaceAll(RegExp(r'\d'), '');
  namePart = namePart.replaceAll(RegExp(r'[._-]'), ' ');
  return namePart.split(' ').where((s) => s.isNotEmpty).map((word) {
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ').trim();
}

