import 'package:flutter_test/flutter_test.dart';
import 'package:week5_local_storage_offline_first/data/repositories/note_repository.dart';

void main() {
  test('addNote menolak judul kosong sebelum membuka database', () async {
    var databaseOpened = false;
    final repository = NoteRepository(
      openDb: () async {
        databaseOpened = true;
        throw StateError('Database tidak boleh dibuka.');
      },
    );

    await expectLater(
      repository.addNote(title: '   '),
      throwsA(isA<ArgumentError>()),
    );
    expect(databaseOpened, isFalse);
  });

  test('addNote tidak membocorkan judul ke pesan error', () async {
    final repository = NoteRepository(
      openDb: () async => throw StateError('Database tidak boleh dibuka.'),
    );
    final secret = 'rahasia ' * 20;

    try {
      await repository.addNote(title: secret);
      fail('addNote seharusnya melempar ArgumentError.');
    } on ArgumentError catch (error) {
      expect(error.toString(), isNot(contains('rahasia')));
    }
  });
}
