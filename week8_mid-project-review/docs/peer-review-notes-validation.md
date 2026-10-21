# Peer Review — `feat/notes-validation`

Reviewer: rekan sejawat (sesi tukar PR 15 menit)
Author: Bagas Ardiansa Putra
Commit yang direview: `719f645` (versi awal PR)
Keputusan putaran 1: **Request changes**
Keputusan putaran 2 (setelah `2ff9393`): **Approve**

Format komentar: **observasi → dampak → usulan konkret**.
Setiap komentar harus bisa ditindaklanjuti tanpa bertanya ulang.

---

## R1 — Kebenaran (blocker): pesan error tidak pernah hilang

> **Observasi.** `setState(() => errorText = error)` dipanggil saat Simpan,
> tetapi tidak ada yang mengembalikan `errorText` ke `null`. `TextField` tidak
> punya `onChanged`.
> **Dampak.** Pengguna menekan Simpan pada field kosong, lalu mengetik judul
> yang benar; pesan "tidak boleh kosong" tetap menempel di bawah field sampai
> dialog ditutup. Ini membuat pengguna mengira inputnya masih salah.
> **Usulan.** Tambahkan `onChanged` yang mereset error:
> ```dart
> onChanged: (_) {
>   if (_errorText != null) setState(() => _errorText = null);
> },
> ```

**Status: diterima.** Diimplementasikan di `add_note_dialog.dart`. Dijaga oleh
test `menghapus error saat pengguna mengetik`.

---

## R2 — Kebenaran (blocker): judul ikut tercetak di pesan `ArgumentError`

> **Observasi.** `throw ArgumentError.value(title, 'title', error);` menyertakan
> nilai `title` ke dalam `toString()` exception.
> **Dampak.** Bila pemanggil melakukan `catch (e) { log(e.toString()); }`,
> isi catatan pengguna masuk ke log/crash report. Untuk aplikasi catatan, isi
> catatan adalah data pribadi. Selain itu pesan error jadi panjang dan sulit
> dibaca saat muncul di UI.
> **Usulan.** Lemparkan pesan validasi saja:
> ```dart
> throw ArgumentError(error);
> ```

**Status: diterima.** Diimplementasikan. Dijaga oleh test
`addNote tidak membocorkan judul ke pesan error` (mengirim judul panjang lalu
memastikan `error.toString()` tidak memuat isi judul).

---

## R3 — Arsitektur: validasi + dialog menumpuk di presentation, controller bocor

> **Observasi.** `_promptAddNote` 29 baris (`notes_page.dart:127-155`) berisi tiga
> tanggung jawab sekaligus: membuat `TextEditingController`, memvalidasi, dan
> membangun `AlertDialog` di dalam `StatefulBuilder`. `TextEditingController`
> dibuat di fungsi bebas sehingga tidak ada satu pun kode yang memanggil
> `dispose()`. Aturan validasi juga tidak bisa diuji tanpa memompa widget.
> **Dampak.** (a) controller bocor setiap kali dialog dibuka; (b) aturan bisnis
> "judul tidak boleh kosong" terkunci di layer UI sehingga jalur non-UI
> (sync, import, seed data) bisa melewatinya; (c) sulit dites.
> **Usulan.**
> 1. Pindahkan aturan ke fungsi murni `lib/core/note_validation.dart`
>    (`validateNoteTitle`) tanpa import Flutter.
> 2. Pindahkan dialog ke `lib/pages/widgets/add_note_dialog.dart` sebagai
>    `StatefulWidget` agar controller punya pemilik dan di-`dispose()`.
> 3. Panggil validator yang sama di `NoteRepository.addNote` sebagai penjaga
>    terakhir.
> **Alasan.** Aturan tetap satu sumber, UI tetap tipis, dan validator bisa
> diunit-test tanpa `testWidgets`.

**Status: diterima.** `notes_page.dart` turun dari 165 → 146 baris, dialog pindah
ke `add_note_dialog.dart` (51 baris); logika validasi sekarang 12 baris di
`core/`.

---

## R4 — Test: hanya jalur sukses, tidak ada bukti jalur gagal

> **Observasi.** Test awal hanya `validateNoteTitle` (fungsi murni). Tidak ada
> test yang membuktikan (a) UI benar-benar menampilkan pesan, (b) repository
> menolak **sebelum** membuka database, (c) judul di-trim.
> **Dampak.** Regresi "validasi dihapus dari UI" atau "database dibuka dulu baru
> divalidasi" akan lolos CI.
> **Usulan.** Tambah:
> - `test/add_note_dialog_test.dart`: error muncul, error hilang saat mengetik,
>   hasil dialog ter-trim.
> - `test/note_repository_validation_test.dart`: `addNote('   ')` melempar
>   `ArgumentError` **dan** `openDb` tidak pernah dipanggil (flag boolean).

**Status: diterima.** Total test week5 naik dari 0 → 8.

---

## R5 — Keterbacaan: pesan error hard-coded di dua tempat

> **Observasi.** Teks `'Judul catatan tidak boleh kosong.'` ditulis literal di
> produksi dan di test.
> **Usulan.** Jadikan konstanta `const emptyTitleMessage = '...'` di
> `note_validation.dart` lalu pakai di test.
> **Alasan.** Menghindari duplikasi string.

**Status: ditolak (dengan alasan).** Pesan hanya dipakai satu kali di produksi
(dikembalikan validator) dan tidak pernah dibandingkan di kode aplikasi. Test
justru **sengaja** mengunci teks agar perubahan pesan yang tidak disengaja
tertangkap. Menambah konstanta hanya memindahkan literal ke tempat lain tanpa
mengurangi risiko, dan membuat test lebih sulit dibaca. Bila kelak pesan
dipakai untuk lokalisasi, barulah konstanta/ARB masuk akal.

---

## Ringkasan keputusan

| ID | Kategori | Level | Keputusan |
|----|----------|-------|-----------|
| R1 | Kebenaran (state) | blocker | Diterima |
| R2 | Kebenaran (data pribadi di log) | blocker | Diterima |
| R3 | Arsitektur (lapisan + lifecycle) | blocker | Diterima |
| R4 | Test (jalur gagal) | saran kuat | Diterima |
| R5 | Keterbacaan | nit | Ditolak, alasan tertulis |

Bukti perbaikan: commit `2ff9393`, lalu `flutter analyze` bersih dan
`flutter test` +8 lulus (`screenshots/08-test-w5.png`).
