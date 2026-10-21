# AI Log — Week 9 (AI-Assisted Development)

Catatan mentah pemakaian AI pada fitur **pencarian judul catatan**.
Disimpan apa adanya agar setiap klaim bisa diaudit.

Tanggal: 21 Oktober 2026
Author: Bagas Ardiansa Putra (244107020166)
Project: `week5_local_storage_offline_first`

---

## 1. Prompt inti (formula 5 slot)

```text
Peran: senior Flutter dev.
Konteks: project week5_local_storage_offline_first, layer-first
(lib/core, lib/data, lib/pages), Riverpod, SQLite + Dio. Model Note adalah
model data polos (id, title, body, updatedAt, dirty). Daftar catatan sudah
dimuat lewat notesProvider.
Tugas: tambah pencarian judul catatan + empty state.
Batas: jangan ubah arsitektur, jangan panggil SQLite/Dio dari widget,
maks 80 baris, aturan filter harus fungsi murni yang bisa diuji.
Output: kode + 3 test case + cara uji manual.
```

### 1.1 Pemetaan slot

| Slot | Isi |
|---|---|
| Peran | senior Flutter dev |
| Konteks | layer-first week5, Riverpod, SQLite + Dio, model `Note` |
| Tugas | pencarian judul + empty state |
| Batas | arsitektur tetap, tanpa SQLite di widget, maks 80 baris, filter murni |
| Output | kode + 3 test + cara uji |

### 1.2 Buruk vs baik

```text
BURUK : "buatkan search notes yang keren"
BAIK  : "Tambah search judul notes.
         Arsitektur: presentation->domain<-data.
         Jangan panggil SQLite dari widget.
         Sertakan empty state + 1 widget test."
```

Prompt kabur menghasilkan kode kabur yang sulit diuji. Yang membuat prompt
"baik" bukan panjangnya, melainkan adanya **batas yang bisa dibuktikan salah**
— "jangan panggil SQLite dari widget" bisa diperiksa dengan `grep`.

---

## 2. Konteks yang ditempel (dan yang tidak)

Disertakan:

- Struktur folder: `lib/core`, `lib/data/{local,repositories}`, `lib/pages`.
- Kontrak repository: `fetchNotes`, `getNoteById`, `addNote`, `deleteNote`,
  `countDirty`, `markAllSynced`.
- Model `Note`: `id`, `title`, `body`, `updatedAt`, `dirty`.
- Versi package dari `pubspec.yaml`: `flutter_riverpod` 3.x, `sqflite`,
  `dio` 5.x, `go_router`.
- Potongan kode relevan: `providers.dart` dan `notes_page.dart`.
- Yang **tidak boleh** diubah: skema database, router, arsitektur.

Tidak disertakan:

- Token FCM, JWT, API key, password → diganti `TOKEN_PLACEHOLDER`.
- Seluruh repo (500+ file).
- Screenshot kabur.

Pemeriksaan sebelum mengirim prompt:

```
$ grep -RInE "Bearer|api[_-]?key|password|token" lib
(tidak ada output → tidak ada secret yang ikut ditempel)
```

---

## 3. Output awal AI (draft)

AI mengirim satu widget utuh (`notes_search_draft.dart`, 45 baris):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../domain/note_search_usecase.dart';   // (1)
import 'widgets/note_tile.dart';

class NotesSearchDraft extends ConsumerWidget {
  const NotesSearchDraft({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);        // (2)

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Cari judul catatan',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) =>
                ref.read(notesProvider.notifier).searchNotes(value), // (3)
          ),
        ),
        Expanded(
          child: results.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('$error')),
            data: (notes) => notes.isEmpty
                ? const Center(child: Text('Tidak ada catatan yang cocok'))
                : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) =>
                        NoteTile(note: notes[index]),
                  ),
          ),
        ),
      ],
    );
  }
}
```

dan fungsi filter:

```dart
List<Note> filterNotes(List<Note> notes, String query) {
  if (query.isEmpty) return notes;
  return notes.where((note) => note.title.startsWith(query)).toList();
}
```

---

## 4. Halusinasi API yang ditemukan

Tiga simbol yang **tidak ada** di repo:

| # | Simbol | Klaim AI | Kenyataan |
|---|---|---|---|
| 1 | `../domain/note_search_usecase.dart` | file use case | file tidak ada; week5 tidak punya `lib/domain` |
| 2 | `searchResultsProvider` | provider hasil filter | provider tidak ada |
| 3 | `NotesNotifier.searchNotes()` | method pencarian | method tidak ada (hanya `add`, `remove`) |

Bukti:

```
$ flutter analyze
error - Target of URI doesn't exist: '../domain/note_search_usecase.dart'
        - lib\pages\notes_search_draft.dart:5:8 - uri_does_not_exist
error - Undefined name 'searchResultsProvider'.
        - lib\pages\notes_search_draft.dart:13:31 - undefined_identifier
error - The method 'searchNotes' isn't defined for the type 'NotesNotifier'.
        - lib\pages\notes_search_draft.dart:25:50 - undefined_method
3 issues found.
ANALYZE_EXIT=1
```

```
$ grep -RInE "searchNotes|searchResultsProvider" lib test
(tidak ada output, exit 1)
```

Method yang benar-benar ada:

```
NotesNotifier  : build, add, remove, refresh
NoteRepository : fetchNotes, getNoteById, addNote, deleteNote,
                 countDirty, markAllSynced
```

---

## 5. Debug dengan test merah

### 5.1 Bug logika filter

Draft `filterNotes` memakai `startsWith` dan tidak `trim`. Test merah:

```
$ flutter test test/search_filter_test.dart
+1 -1: filter abaikan huruf besar/kecil [E]
  Expected: an object with length of <2>
    Actual: [Instance of 'Note']
+1 -2: cocokkan potongan judul di tengah kata [E]
  Expected: an object with length of <1>
    Actual: []
+2 -3: spasi di tepi query diabaikan [E]
  Expected: an object with length of <1>
    Actual: []
+2 -5: Some tests failed.
TEST_EXIT=1
```

Akar masalah: `startsWith` peka huruf besar/kecil dan mencocokkan dari awal
judul saja; query dengan spasi di tepi tidak pernah cocok.

Perbaikan (8 baris, fungsi murni):

```dart
List<Note> filterNotes(List<Note> notes, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return List<Note>.unmodifiable(notes);

  return List<Note>.unmodifiable(
    notes.where((note) => note.title.toLowerCase().contains(needle)),
  );
}
```

Sesudah: `+7: All tests passed!`

### 5.2 Bug state field pencarian

Reproduksi: ketik `zzz-tak-ada` → tekan **Hapus pencarian**. Daftar pulih, tetapi
field masih berisi teks lama.

```
$ flutter test test/notes_search_widget_test.dart
+4 -1: hapus pencarian juga mengosongkan isi field [E]
  Expected: empty
    Actual: 'zzz-tak-ada'
TEST_EXIT=1
```

Akar masalah: `TextEditingController` dibuat `late final` sekali dan tidak
disinkronkan ketika `widget.query` berubah dari luar (tombol clear ada di
`NotesEmptyState`, bukan di field).

Perbaikan:

```dart
@override
void didUpdateWidget(NotesSearchField oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.query != oldWidget.query && _controller.text != widget.query) {
    _controller.text = widget.query;
  }
}
```

Sesudah: `00:04 +20: All tests passed!`

---

## 6. Prompt yang paling membantu

Prompt yang dipakai untuk review, bukan untuk generate:

```text
Review kode search Flutter ini sebagai senior dev.
Konteks: feature-first (presentation->domain<-data), Riverpod, SQLite + Dio.
Fokus: kebenaran, arsitektur, test. Abaikan style.
Beri 3 temuan + level blocker/saran + alasan.
```

Yang saya ubah dari prompt jobsheet: saya **menambahkan kalimat konteks nyata**
— "week5 masih layer-first, `lib/domain` belum ada" — karena tanpa itu AI terus
menyarankan pola week7 (`Either`, use case layer) yang tidak berlaku di project
ini. Perubahan kecil ini memangkas saran yang tidak relevan.

---

## 7. Tabel usulan AI vs keputusan final

| ID | Usulan AI | Level | Keputusan | Alasan | Bukti |
|---|---|---|---|---|---|
| S1 | Field pencarian tidak tersinkron saat query berubah dari luar | blocker | **Terima + refactor** | Bug nyata; fix dipilih `didUpdateWidget`, bukan `GlobalKey` dari parent | Test merah `Expected: empty` / `Actual: 'zzz-tak-ada'` → 20 test hijau |
| S2 | `build()` `NotesPage` terlalu gemuk | blocker | **Terima + refactor** | Diukur 76 baris → dipecah jadi 31/10/25/14/12/12/18 | `grep`/hitung baris |
| S3 | Pindahkan `filterNotes` ke `lib/domain`, kembalikan `List<String>` | saran | **Tolak** | (a) `lib/domain` belum ada, menambah layer untuk 8 baris; (b) membuang `id`/`dirty` merusak navigasi `/note/{id}` dan tombol hapus; (c) `Note` model polos, jadi import `core → data/local` tidak melanggar dependency rule | `grep -nE "^import" lib/core/note_search.dart` → hanya `note.dart` |

Syarat jobsheet: **minimal 1 temuan terbukti benar** (S1, S2) dan **minimal 1
ditolak dengan alasan teknis** (S3) — terpenuhi.

---

## 8. Keputusan tiap file hasil AI

| File / bagian | Keputusan | Alasan |
|---|---|---|
| `notes_search_draft.dart` | **Tolak + tulis manual** | 3 simbol tidak ada, `flutter analyze` exit 1 |
| `filterNotes` (logika awal) | **Terima + refactor** | `startsWith` peka huruf, 5 test merah → `trim`+`toLowerCase`+`contains` |
| `NotesSearchField` (S1) | **Terima + refactor** | Bug nyata; fix `didUpdateWidget` |
| `NotesPage.build` (S2) | **Terima + refactor** | 76 → 31 baris, semua fungsi < 40 |
| S3 (pindah ke `lib/domain`) | **Tolak** | Menambah layer + membuang `id`/`dirty` |

---

## 9. Hasil akhir

```
$ flutter analyze
No issues found! (ran in 5.2s)

$ dart format --set-exit-if-changed .
Formatted 26 files (0 changed)

$ flutter test
00:02 +20: All tests passed!
```

Rincian 20 test: 8 test lama (validasi judul) + 7 filter + 5 widget search.
