import '../data/local/note.dart';

/// Menyaring catatan berdasarkan judul.
///
/// Fungsi murni: tidak menyentuh Flutter, SQLite, maupun Dio, sehingga bisa
/// diuji tanpa widget test dan tanpa database. Pencarian mengabaikan besar/kecil
/// huruf dan spasi di tepi query. Query kosong mengembalikan seluruh catatan
/// tanpa mengubah urutannya.
List<Note> filterNotes(List<Note> notes, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return List<Note>.unmodifiable(notes);

  return List<Note>.unmodifiable(
    notes.where((note) => note.title.toLowerCase().contains(needle)),
  );
}
