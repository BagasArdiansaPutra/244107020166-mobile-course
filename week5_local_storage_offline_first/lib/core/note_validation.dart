const int maxNoteTitleLength = 80;

String? validateNoteTitle(String? rawTitle) {
  final title = rawTitle?.trim() ?? '';
  if (title.isEmpty) {
    return 'Judul catatan tidak boleh kosong.';
  }
  if (title.length > maxNoteTitleLength) {
    return 'Judul maksimal $maxNoteTitleLength karakter.';
  }
  return null;
}
