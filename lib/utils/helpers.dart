String? formatDate(DateTime? date) {
  if (date == null) return null;
  return '${date.day}/${date.month}/${date.year}';
}

bool isNullOrEmpty(String? value) {
  return value == null || value.isEmpty;
}
