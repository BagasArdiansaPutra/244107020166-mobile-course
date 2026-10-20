import 'package:flutter_test/flutter_test.dart';
import 'package:week5_local_storage_offline_first/core/note_validation.dart';

void main() {
  group('validateNoteTitle', () {
    test('menolak judul null, kosong, dan hanya spasi', () {
      expect(validateNoteTitle(null), 'Judul catatan tidak boleh kosong.');
      expect(validateNoteTitle(''), 'Judul catatan tidak boleh kosong.');
      expect(validateNoteTitle('   '), 'Judul catatan tidak boleh kosong.');
    });

    test('menerima judul valid dan mengabaikan spasi di tepi', () {
      expect(validateNoteTitle('Belanja mingguan'), isNull);
      expect(validateNoteTitle('  Belanja mingguan  '), isNull);
    });

    test('menolak judul yang melebihi batas karakter', () {
      expect(validateNoteTitle('a' * maxNoteTitleLength), isNull);
      expect(validateNoteTitle('a' * (maxNoteTitleLength + 1)), isNotNull);
    });
  });
}
