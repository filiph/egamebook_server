

/// creates a beautiful file name
String renderDriveDumpFilename(String folderId) {
  DateTime dt = new DateTime.now();
  return "drivedump-${dt.year}${d2(dt.month)}${d2(dt.day)}-${d2(dt.hour)}${d2(dt.minute)}-${folderId}";
}

/// formates number to two digits
String d2(int number) {
  if (number == null) return "XX";
  return number.toString().padLeft(2, '0');
}