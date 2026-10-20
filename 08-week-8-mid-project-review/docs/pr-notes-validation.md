# PR: feat(notes): validasi judul kosong + test

Branch: `feat/notes-validation` → `develop`
Commit fitur: `719f645`, tindak lanjut review: `2ff9393`
Merge ke develop: `a3acf31` (squash)

---

## Judul

`feat(notes): validasi judul kosong + test`

## Masalah

Pengguna bisa menyimpan catatan tanpa judul. Pada versi sebelumnya
(`week5_local_storage_offline_first/lib/pages/notes_page.dart`), dialog
"Catatan baru" langsung memanggil `Navigator.pop(controller.text)` tanpa
memeriksa isi field. Bila pengguna menekan **Simpan** dengan field kosong atau
hanya spasi, fungsi `_promptAddNote` diam-diam berhenti (`if (trimmed.isEmpty) return;`)
sehingga **tidak ada catatan tersimpan dan tidak ada pesan apa pun** — pengguna
mengira data hilang.

Selain itu `NoteRepository.addNote` menerima `title` apa adanya, sehingga jalur
lain (sync/import di masa depan) bisa menyimpan baris dengan judul kosong ke
SQLite.

## Solusi

1. **Aturan tunggal dan murni** di `lib/core/note_validation.dart`:

   ```dart
   const int maxNoteTitleLength = 80;

   String? validateNoteTitle(String? rawTitle) {
     final title = rawTitle?.trim() ?? '';
     if (title.isEmpty) return 'Judul catatan tidak boleh kosong.';
     if (title.length > maxNoteTitleLength) {
       return 'Judul maksimal $maxNoteTitleLength karakter.';
     }
     return null;
   }
   ```

   Fungsi ini tidak menyentuh Flutter, sehingga bisa diuji tanpa widget test.

2. **UI** — dialog dipindah dari closure `StatefulBuilder` di `notes_page.dart`
   ke `lib/pages/widgets/add_note_dialog.dart` (StatefulWidget). Alasannya:
   `TextEditingController` sekarang punya pemilik yang jelas dan di-`dispose()`
   pada `State.dispose()`, dan `errorText` bisa di-reset saat pengguna mengetik.

3. **Repository** sebagai penjaga terakhir:

   ```dart
   final error = validateNoteTitle(title);
   if (error != null) {
     throw ArgumentError(error);
   }
   ```

   `ArgumentError` dipakai (bukan `Exception` baru) karena judul kosong adalah
   pelanggaran kontrak pemanggil, bukan kegagalan domain/jaringan.

## Cara uji

1. Jalankan aplikasi week5, tekan **+**.
2. Kosongkan field, tekan **Simpan** → muncul `Judul catatan tidak boleh kosong.`,
   dialog tetap terbuka, tidak ada baris baru di daftar.
3. Ketik satu huruf → pesan error hilang.
4. Isi `  Belanja  ` lalu **Simpan** → tersimpan sebagai `Belanja` (spasi tepi dibuang).
5. Otomatis:

   ```
   cd week5_local_storage_offline_first
   flutter analyze
   dart format --output=none --set-exit-if-changed .
   flutter test test/validate_note_test.dart
   flutter test
   ```

## Hasil mesin

| Perintah | Hasil |
|----------|-------|
| `flutter analyze` | No issues found! |
| `dart format --set-exit-if-changed .` | 21 files (0 changed) |
| `flutter test` | +8 All tests passed! |

## Dampak

7 file, +198 / −24 baris — masih di bawah batas 300 baris sehingga bisa
direview < 15 menit.

## Catatan

`gh` CLI tidak tersedia di mesin praktikum, sehingga PR ini dibuat manual lewat
tautan GitHub yang dicetak `git push`:

```
https://github.com/BagasArdiansaPutra/244107020166-mobile-course/pull/new/feat/notes-validation
```

Isi dokumen ini dipakai apa adanya sebagai body PR.
