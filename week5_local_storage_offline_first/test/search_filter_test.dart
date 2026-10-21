import 'package:flutter_test/flutter_test.dart';
import 'package:week5_local_storage_offline_first/core/note_search.dart';
import 'package:week5_local_storage_offline_first/data/local/note.dart';

Note _note(String title) =>
    Note(title: title, updatedAt: DateTime(2026, 10, 21));

void main() {
  final notes = [
    _note('Belanja mingguan'),
    _note('belanja bulanan'),
    _note('Ide proyek'),
    _note('Catatan rapat'),
  ];

  group('filterNotes', () {
    test('query kosong mengembalikan semua catatan', () {
      expect(filterNotes(notes, ''), hasLength(4));
    });

    test('filter abaikan huruf besar/kecil', () {
      expect(filterNotes(notes, 'belanja'), hasLength(2));
    });

    test('cocokkan potongan judul di tengah kata', () {
      final result = filterNotes(notes, 'proy');
      expect(result, hasLength(1));
      expect(result.single.title, 'Ide proyek');
    });

    test('query tak cocok mengembalikan list kosong', () {
      expect(filterNotes(notes, 'zzz-tak-ada'), isEmpty);
    });

    test('spasi di tepi query diabaikan', () {
      expect(filterNotes(notes, '   rapat  '), hasLength(1));
    });

    test('urutan asli catatan dipertahankan', () {
      final result = filterNotes(notes, 'belanja');
      expect(result.map((n) => n.title), [
        'Belanja mingguan',
        'belanja bulanan',
      ]);
    });

    test('query hanya spasi tidak menyaring apa pun', () {
      expect(filterNotes(notes, '   '), hasLength(4));
    });
  });
}
