# AI Review vs Keputusan Final

PR: `feat/notes-validation` → `develop`
Commit yang direview AI: `719f645` (versi sebelum tindak lanjut)
Tanggal: 20 Oktober 2026
Reviewer manusia (pemutus): Bagas Ardiansa Putra

Dokumen ini menyimpan **prompt**, **output awal AI**, tabel
**usulan vs keputusan final**, dan **bukti** (grep/test). Tujuannya agar setiap
saran AI bisa diaudit, bukan diterima mentah.

---

## 1. Prompt yang dipakai

```text
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

Konteks tambahan yang saya berikan ke AI: diff `719f645` pada
`week5_local_storage_offline_first` (bukan week7). Catatan penting: **week5
belum memakai Clean Architecture** — ia masih layer-first (`lib/data`,
`lib/pages`). Ini relevan untuk menilai temuan arsitektur.

---

## 2. Output awal AI (5 temuan)

| ID | Level | Temuan | Usulan AI |
|----|-------|--------|-----------|
| A1 | blocker | Validasi hanya ada di UI. `NoteRepository.addNote` masih menerima `title` kosong, sehingga jalur non-UI (sync/import/seed) bisa menulis baris tanpa judul. | Tambahkan guard yang sama di repository sebelum `_openDb()`. |
| A2 | blocker | `TextEditingController` dibuat di fungsi `_promptAddNote` dan tidak pernah di-`dispose()`. Setiap buka dialog menambah listener yang tidak dilepas. | Pindahkan dialog ke `StatefulWidget` dan `dispose()` controller di `State.dispose()`. |
| A3 | blocker | Jangan lempar `ArgumentError`; buat `NoteValidationFailure` di `core/failures.dart` dan bungkus hasil use case dengan `Either<Failure, Note>`. | Refactor ke pola `Either` + `Failure` seperti week7. |
| A4 | saran | Ganti `TextField` + `errorText` dengan `Form` + `TextFormField` + `GlobalKey<FormState>` agar validasi "idiomatik". | Buat `_formKey`, panggil `_formKey.currentState!.validate()`. |
| A5 | saran | Pindahkan aturan validasi ke `StateNotifier`/provider Riverpod agar UI bebas logika. | Buat `NoteValidationNotifier`. |

---

## 3. Verifikasi terhadap kenyataan

Checklist yang dipakai (sesuai jobsheet):

1. Apakah temuan benar-benar ada? → buktikan dengan grep / test gagal / reproduksi.
2. Apakah usulan melanggar dependency rule (domain mengimpor Flutter/Dio/SQLite)?
3. Apakah AI hanya nitpick style yang seharusnya ditangani formatter/CI?

### A1 — TERBUKTI BENAR

```
$ git show 6d4e684:week5_local_storage_offline_first/lib/data/repositories/note_repository.dart | grep -n "validate"
(tidak ada output)
```

```
$ grep -n "validateNoteTitle" week5_local_storage_offline_first/lib/data/repositories/note_repository.dart
lib\data\repositories\note_repository.dart:27:final error = validateNoteTitle(title);
```

Sebelum perbaikan tidak ada satu pun pemanggilan validasi di repository. Sesudah
perbaikan ada di baris 27, **sebelum** `await _openDb()` (baris 32).

Bukti screenshot: `screenshots/14-ai-proof.png`.

### A2 — TERBUKTI BENAR

```
$ git show 6d4e684:week5_local_storage_offline_first/lib/pages/notes_page.dart | grep -n "dispose"
(tidak ada output)
```

```
$ grep -c "dispose" week5_local_storage_offline_first/lib/pages/widgets/add_note_dialog.dart
1
```

Versi lama tidak punya `dispose` sama sekali; versi baru memilikinya di
`_AddNoteDialogState.dispose()`.

### A3 — DITOLAK

Alasan tertulis:

1. **Melanggar konteks repo.** `week5_local_storage_offline_first` tidak punya
   `core/failures.dart` maupun tipe `Either`. Menambahkannya berarti
   memindahkan pola week7 ke belakang — pekerjaan refactor besar untuk satu
   validasi 12 baris.
2. **Kategori error salah.** Judul kosong bukan kegagalan domain (tidak ada
   jaringan/disk yang gagal); itu pelanggaran kontrak pemanggil. `ArgumentError`
   adalah tipe yang tepat dan sudah dikenali Dart.
3. **Tidak menambah keamanan.** `Either` hanya mengubah cara pemanggil
   menangani error; ia tidak menambah satu pun test atau mencegah bug baru.

### A4 — DITOLAK

`Form` + `GlobalKey<FormState>` memindahkan state validasi ke objek global yang
harus dikelola (dibuat, dipasang, di-reset) tanpa mengubah perilaku. `errorText`
saat ini **sudah** bisa diuji langsung lewat `find.text(...)` tanpa key. Bila
kelak dialog punya 5 field, migrasi ke `Form` baru masuk akal; untuk satu field
ia menambah kode tanpa manfaat.

### A5 — DITOLAK

`validateNoteTitle` adalah fungsi murni: input string, output `String?`. Tidak
ada state yang perlu di-*notify*. Membungkusnya dalam `StateNotifier` berarti
setiap test harus membangun `ProviderContainer` — memperbesar permukaan test
dan memperlambat umpan balik. Aturan tetap di `core/note_validation.dart`
sehingga bisa dipakai UI, repository, dan test tanpa Riverpod.

---

## 4. Tabel usulan vs keputusan final

| ID | Usulan AI | Keputusan | Alasan ringkas | Bukti |
|----|-----------|-----------|----------------|-------|
| A1 | Guard validasi di repository | **Diterima** | Menutup jalur non-UI; murah (5 baris) | grep + test `addNote menolak judul kosong sebelum membuka database` |
| A2 | Dialog jadi `StatefulWidget` + `dispose` | **Diterima** | Memperbaiki lifecycle controller; sekaligus membuat UI bisa dites | grep `dispose` + 3 widget test |
| A3 | `Failure` + `Either` | **Ditolak** | Bukan arsitektur week5; kategori error salah; tanpa manfaat uji | bagian 3 |
| A4 | `Form` + `TextFormField` | **Ditolak** | Tidak mengubah perilaku, menambah state global | bagian 3 |
| A5 | Validasi di provider Riverpod | **Ditolak** | Fungsi murni tanpa state; test jadi lebih berat | bagian 3 |

Hasil akhir: **2 temuan AI benar dan diterapkan, 3 ditolak dengan alasan
tertulis.** Tidak ada saran AI yang diterapkan tanpa bukti.

---

## 5. Bukti mesin setelah keputusan

```
PS ...\week5_local_storage_offline_first> flutter analyze
No issues found! (ran in 7.1s)

PS ...> dart format --set-exit-if-changed .
Formatted 21 files (0 changed)

PS ...> flutter test
00:02 +8: All tests passed!
```

Screenshot: `screenshots/06-analyze-w5.png`, `screenshots/07-format-w5.png`,
`screenshots/08-test-w5.png`.

---

## 6. Pelajaran

- AI cepat menemukan **dua bug nyata** (A1, A2) yang lolos dari review manual
  pertama — terutama A2 yang tidak terlihat dari diff karena berupa *absence*
  (`dispose` yang tidak ada).
- AI juga cenderung **mengimpor pola dari konteks lain** (A3: `Either` dari
  week7) dan **menyarankan idiomatik tanpa mengukur manfaat** (A4, A5). Dua
  kategori ini yang paling berbahaya bila diterima mentah: kode bertambah,
  arsitektur jadi tidak konsisten, tanpa bug yang hilang.
- Aturan praktis: setiap saran AI harus punya **bukti grep/test** dan
  **tidak boleh menambah layer baru** tanpa alasan yang bisa diuji.
