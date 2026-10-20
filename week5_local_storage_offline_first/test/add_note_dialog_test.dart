import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_local_storage_offline_first/pages/widgets/add_note_dialog.dart';

void main() {
  testWidgets('menampilkan error untuk judul kosong', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AddNoteDialog())),
    );

    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Judul catatan tidak boleh kosong.'), findsOneWidget);
  });

  testWidgets('menghapus error saat pengguna mengetik', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AddNoteDialog())),
    );

    await tester.tap(find.text('Simpan'));
    await tester.pump();
    expect(find.text('Judul catatan tidak boleh kosong.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Belanja');
    await tester.pump();

    expect(find.text('Judul catatan tidak boleh kosong.'), findsNothing);
  });

  testWidgets('mengembalikan judul yang sudah di-trim', (tester) async {
    String? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await showDialog<String>(
                  context: context,
                  builder: (_) => const AddNoteDialog(),
                );
              },
              child: const Text('Buka'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Belanja  ');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(result, 'Belanja');
  });
}
