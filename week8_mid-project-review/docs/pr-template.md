# Template PR yang dipakai

Template ini dipakai untuk setiap PR di repo ini. Isi wajibnya empat bagian:
**masalah, solusi, cara uji, screenshot**. Tanpa keempatnya, PR belum siap
direview.

---

## Template kosong

```markdown
## Masalah
<gejala yang bisa direproduksi + dampaknya bagi pengguna>

## Solusi
<perubahan yang dilakukan, sebut file/komponen utamanya>
<alasan memilih pendekatan ini, termasuk yang sengaja tidak dilakukan>

## Cara uji
1. <langkah manual, bisa diikuti reviewer tanpa bertanya>
2. <perintah otomatis>

## Screenshot
<sebelum / sesudah, atau output terminal>

## Hasil mesin
| Perintah | Hasil |
|---|---|
| flutter analyze | |
| dart format --set-exit-if-changed . | |
| flutter test | |

## Dampak
<file, baris, risiko regresi>

Closes #<issue>
```

---

## Contoh terisi — PR #4

```markdown
## Masalah
Menekan Simpan dengan judul kosong menutup dialog tanpa menyimpan apa pun dan
tanpa pesan error, sehingga pengguna mengira catatan hilang. Selain itu
NoteRepository.addNote menerima judul kosong, jadi jalur sync/import bisa
menulis baris tidak valid ke SQLite.

## Solusi
1. Aturan tunggal di lib/core/note_validation.dart (validateNoteTitle), tanpa
   import Flutter sehingga bisa diunit-test.
2. AddNoteDialog (StatefulWidget) menampilkan errorText dan me-reset-nya lewat
   onChanged; controller di-dispose().
3. NoteRepository.addNote memanggil validator sebelum _openDb() sebagai penjaga
   terakhir.
Tidak memakai Either<Failure, Note> karena week5 belum clean architecture dan
judul kosong adalah pelanggaran kontrak pemanggil, bukan kegagalan domain.

## Cara uji
1. Tekan +, kosongkan field, tekan Simpan -> error muncul, dialog tetap terbuka.
2. Ketik satu huruf -> pesan error hilang.
3. Isi "  Belanja  " lalu Simpan -> tersimpan sebagai "Belanja".
4. flutter analyze && dart format --output=none --set-exit-if-changed . && flutter test

## Screenshot
screenshots/08-test-w5.png (8 test hijau)
screenshots/17-pr-kecil.png (ukuran diff)

## Hasil mesin
| Perintah | Hasil |
|---|---|
| flutter analyze | No issues found! |
| dart format --set-exit-if-changed . | 21 files (0 changed) |
| flutter test | +8 All tests passed! |

## Dampak
7 file, +198 / -24 baris. Tidak ada perubahan skema database. Perilaku lain
identik dengan akhir Minggu 7.

Closes #4
```

---

## Aturan yang mengikat template ini

| Aturan | Alasan |
|---|---|
| Judul `tipe(scope): ringkasan imperatif` | Bisa dicari dan dibaca di `git log --oneline` |
| Ukuran < 300 baris | Bisa direview < 15 menit |
| Wajib bagian **Cara uji** yang bisa diikuti | Review tanpa dijalankan tidak sah |
| Wajib **Hasil mesin** | Reviewer tidak perlu menebak status analyze/test |
| Wajib **Screenshot** untuk perubahan UI | Diff tidak menunjukkan tampilan sebenarnya |
| `Closes #<issue>` di akhir | Issue tertutup otomatis saat merge |
| Sebutkan yang **sengaja tidak** dilakukan | Mencegah reviewer mengulang saran yang sudah ditolak |
