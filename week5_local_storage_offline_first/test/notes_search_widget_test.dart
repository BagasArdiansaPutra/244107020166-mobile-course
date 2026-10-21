import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_local_storage_offline_first/data/local/note.dart';
import 'package:week5_local_storage_offline_first/data/providers.dart';
import 'package:week5_local_storage_offline_first/pages/notes_page.dart';
import 'package:week5_local_storage_offline_first/pages/widgets/notes_empty_state.dart';

final _seed = [
  Note(id: 1, title: 'Belanja mingguan', updatedAt: DateTime(2026, 10, 21)),
  Note(id: 2, title: 'Ide proyek', updatedAt: DateTime(2026, 10, 20)),
];

class _FakeNotesNotifier extends NotesNotifier {
  @override
  Future<List<Note>> build() async => _seed;
}

Future<void> _pumpPage(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        notesProvider.overrideWith(_FakeNotesNotifier.new),
        dirtyCountProvider.overrideWith((ref) => 0),
      ],
      child: const MaterialApp(home: NotesPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('menampilkan semua catatan saat query kosong', (tester) async {
    await _pumpPage(tester);

    expect(find.text('Belanja mingguan'), findsOneWidget);
    expect(find.text('Ide proyek'), findsOneWidget);
    expect(find.byType(NotesEmptyState), findsNothing);
  });

  testWidgets('menyaring catatan saat pengguna mengetik', (tester) async {
    await _pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'belanja');
    await tester.pumpAndSettle();

    expect(find.text('Belanja mingguan'), findsOneWidget);
    expect(find.text('Ide proyek'), findsNothing);
  });

  testWidgets('menampilkan empty state saat query tidak cocok', (tester) async {
    await _pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'zzz-tak-ada');
    await tester.pumpAndSettle();

    expect(
      find.text('Tidak ada catatan yang cocok dengan "zzz-tak-ada".'),
      findsOneWidget,
    );
    expect(find.text('Belanja mingguan'), findsNothing);
  });

  testWidgets('tombol hapus pencarian memulihkan seluruh catatan', (
    tester,
  ) async {
    await _pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'zzz-tak-ada');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus pencarian'));
    await tester.pumpAndSettle();

    expect(find.text('Belanja mingguan'), findsOneWidget);
    expect(find.text('Ide proyek'), findsOneWidget);
  });

  testWidgets('hapus pencarian juga mengosongkan isi field', (tester) async {
    await _pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'zzz-tak-ada');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus pencarian'));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, isEmpty);
  });
}
