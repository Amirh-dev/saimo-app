bool hasValidUsernameCharacters(String value) {
  final username = value.trim();
  return username.isNotEmpty && RegExp(r'^[A-Za-z0-9_]+$').hasMatch(username);
}
