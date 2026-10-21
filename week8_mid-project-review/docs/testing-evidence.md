# Testing evidence — review tanpa dijalankan tidak sah

Aturan yang dipakai: **setiap PR yang mengubah perilaku wajib menyertakan
bukti uji.** Reviewer tidak boleh memberi `Approve` hanya dari membaca diff.
Isi dokumen ini adalah bukti yang benar-benar dijalankan, bukan rencana.

---

## 1. Tiga perintah wajib

```bash
flutter analyze
dart format --output=none --set-exit-if-changed .
flutter test
```

Semuanya harus keluar dengan kode `0`. Di CI, ketiganya dijalankan pada setiap
`pull_request` ke `develop`/`main` untuk tiga project (`.github/workflows/ci.yml`).

## 2. Bukti per PR

| PR | Perubahan perilaku? | analyze | format | test | Manual 5 menit | Screenshot |
|---|---|---|---|---|---|---|
| #1 week5 hygiene | Tidak (nama package + format) | 0 issue | 0 changed | 8 lulus | tidak perlu | `06`–`08` |
| #2 week7 hygiene | Tidak (nama package + lint) | 0 issue | 0 changed | 24 lulus | tidak perlu | `09`–`10` |
| #3 CI | Tidak (workflow) | — | — | — | gate diuji gagal (lihat `23`) | `11` |
| #4 validasi judul | **Ya** | 0 issue | 21 files, 0 changed | 8 lulus | ya (4 langkah) | `08`, `17`, `20` |
| #5 week6 hygiene | Tidak (nama package + format) | 0 issue | 0 changed | 19 lulus | tidak perlu | `15`–`16` |
| #6 CI week6 | Tidak (1 baris matrix) | — | — | — | — | `11` |
| #7 laporan | Tidak (dokumen) | — | — | — | pemeriksaan tautan 23/23 ada | `13` |

Ukuran tiap PR (semua jauh di bawah batas 300 baris):

```
f85765f  16 files,  +58 / -70      (PR #1)
c19c0d5  18 files, +117 / -107     (PR #2)
9f6ba08   1 file,   +35            (PR #3)
a3acf31   7 files, +198 / -24      (PR #4)
24d5fe9  10 files,  +72 / -64      (PR #5)
37ff067   1 file,    +1            (PR #6)
91468ae  23 files, +970            (PR #7, dipecah 3 di docs/refactoring-split.md)
```

## 3. Bukti manual 5 menit — validasi judul (PR #4)

Langkah yang dijalankan pada aplikasi week5:

1. Buka aplikasi, tekan tombol **+** → dialog "Catatan baru".
2. Kosongkan field, tekan **Simpan** → muncul `Judul catatan tidak boleh kosong.`,
   dialog tetap terbuka, daftar tidak bertambah.
3. Ketik satu huruf → pesan error langsung hilang.
4. Isi `  Belanja  ` lalu **Simpan** → tersimpan sebagai `Belanja` (spasi dibuang).

Keempat langkah itu kini juga dikunci otomatis oleh widget test, sehingga tidak
bergantung pada ingatan reviewer:

```
test/add_note_dialog_test.dart
  ✓ menampilkan error untuk judul kosong
  ✓ menghapus error saat pengguna mengetik
  ✓ mengembalikan judul yang sudah di-trim
```

## 4. Bukti otomatis terakhir

```
week5_local_storage_offline_first
  flutter analyze   -> No issues found! (ran in 4.6s)
  dart format       -> Formatted 21 files (0 changed)
  flutter test      -> 00:03 +8: All tests passed!

week6_authentication_security_fcm
  flutter analyze   -> No issues found! (ran in 4.6s)
  dart format       -> Formatted 17 files (0 changed)
  flutter test      -> 00:01 +19: All tests passed!

week_7_clean_architecture
  flutter analyze   -> No issues found! (ran in 4.3s)
  dart format       -> Formatted 30 files (0 changed)
  flutter test      -> 00:02 +24: All tests passed!
```

Total **51 test**, 0 issue, 0 file berubah. Screenshot: `22-static-analysis.png`.

## 5. Gate CI benar-benar bisa gagal

Gate yang tidak pernah merah bukan gate. Simulasi dengan satu file kotor:

| Gerbang | Output | Exit |
|---|---|---|
| `flutter analyze` | `unused_import` pada `lib/tmp_ci_demo.dart:1` | `1` |
| `dart format --set-exit-if-changed .` | `Changed lib/tmp_ci_demo.dart`, `1 changed` | `1` |
| `flutter test` | `Expected: <2> Actual: <1>` | `1` |

File simulasi dihapus dan `git status --short` kembali kosong. Screenshot:
`23-ci-menolak-kotor.png`.

## 6. Aturan review yang dipakai

1. Reviewer **checkout** branch, bukan membaca diff di browser.
2. Reviewer menjalankan tiga perintah di atas; bila merah → `Request changes`.
3. Untuk perubahan perilaku, reviewer mengulang langkah manual pada bagian 3.
4. `Approve` hanya diberikan bila bukti uji ada di deskripsi PR **dan** bisa
   direproduksi reviewer.
