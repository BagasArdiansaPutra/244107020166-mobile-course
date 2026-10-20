# Review Checklist — Mid Project Review (Minggu 8)

Nama: Bagas Ardiansa Putra
NIM: 244107020166
Kelas: TI-3D
Repository: `244107020166-mobile-course`

Dokumen ini berisi dua hal wajib dari jobsheet:

1. Tabel sebelum/sesudah untuk tiga pesan commit lama (Praktikum 1 langkah 3).
2. Penilaian kesiapan tengah semester (Praktikum 3 langkah 3).

---

## 1. Perbaikan pesan commit lama (simulasi)

### Audit awal

```
$ git log --oneline -15
80db0b8 feat: initialize Flutter project with clean architecture structure and features
939f5fd rename folder
be47159 feat: add local storage offline-first and authentication security FCM course modules
a253a84 commit tugas
765edc3 commit tugas
0ccf97e feat: create week 1 flutter profile app
```

Masalah yang ditemukan:

| No | Temuan | Bukti |
|----|--------|-------|
| 1 | Semua commit langsung ke `main`, tidak ada `develop` maupun branch fitur | `git branch -a` hanya menampilkan `main` |
| 2 | Dua commit berpesan `commit tugas` (tidak informatif) | `765edc3`, `a253a84` |
| 3 | Satu commit hanya berisi rename folder tanpa penjelasan | `939f5fd` "rename folder" |
| 4 | Satu commit mencampur 160 file / 7.530 baris dalam satu pesan | `80db0b8` |
| 5 | `main` berumur > 1 bulan (2026-09-08 → 2026-10-11) tanpa branch pendek | tanggal commit |
| 6 | Tidak ada file untracked kotor, tetapi `android/app/google-services.json` ikut ter-commit | `git ls-files` |

### Tabel sebelum → sesudah

| # | Commit | Pesan lama | Pesan konvensional (usulan) | Alasan |
|---|--------|-----------|------------------------------|--------|
| 1 | `765edc3` | `commit tugas` | `feat(week2): tambah responsive dashboard dan isi identitas mahasiswa` | Perubahan sebenarnya adalah folder `responsive_dashboard` baru **dan** penggantian nama/NIM/email pada `lib/main.dart`. Tipe `feat` + scope `week2` menyebut apa dan di mana; isi pesan menyebut dua perubahan logisnya. |
| 2 | `a253a84` | `commit tugas` | `docs(week3): ganti identitas README week3 ke Bagas Ardiansa Putra` | Diff-nya hanya 3 baris di `week3_navigation/README.md` (nama, NIM, kelas). Tipe `docs` benar karena tidak menyentuh kode; menyebut file membuat commit bisa dicari tanpa membuka diff. |
| 3 | `939f5fd` | `rename folder` | `refactor(repo): samakan penamaan folder week1-week3` | Commit rename murni (0 insert/delete). Tipe `refactor` menandai tidak ada perubahan perilaku, sehingga reviewer tahu tidak perlu menguji fungsional. |
| 4 | `80db0b8` | `feat: initialize Flutter project with clean architecture structure and features` | `feat(week7): import project clean architecture hasil refactor` | Pesan lama terlalu lebar ("structure and features") untuk 160 file. Scope `week7` + kata "import" menjelaskan bahwa ini pemindahan project, bukan penulisan fitur baru. |
| 5 | `be47159` | `feat: add local storage offline-first and authentication security FCM course modules` | `feat(week5,week6): tambah modul offline-first dan auth+FCM` | Satu commit memuat dua modul berbeda; bila memungkinkan dipecah per modul. Bila tetap digabung, scope ganda membuat isi commit jujur. |

**Aturan yang dipakai mulai sekarang**

- Format: `tipe(scope): ringkasan imperatif` — tipe dari `feat|fix|refactor|test|docs|chore|ci`.
- Satu commit = satu perubahan logis; gunakan `git add -p` untuk memisahkan hunk.
- Bukti uji ikut disebut di badan commit (`flutter test` hijau, nama test).
- Branch hidup < 3 hari, selalu dari `develop`, tidak pernah commit langsung ke `main`.

---

## 2. Kesiapan tengah semester

| Kriteria | Target | Hasil | Bukti |
|----------|--------|-------|-------|
| Struktur feature-first terbukti | 3 grep sterilitas kosong | Lolos | `screenshots/12-sterility.png` |
| `flutter analyze` bersih | 0 issue di week5, week6, week7 | Lolos | `screenshots/06-analyze-w5.png`, `screenshots/09-analyze-w7.png`, `screenshots/15-analyze-w6.png` |
| `dart format` rapi | 0 file berubah | Lolos | `screenshots/07-format-w5.png` |
| `flutter test` hijau | semua test lulus | 8 + 19 + 24 = **51 test** | `screenshots/08-test-w5.png`, `screenshots/16-test-w6.png`, `screenshots/10-test-w7.png` |
| PR kecil + commit jelas | 1 fitur per PR, < 300 baris | 7 PR, PR fitur 198 baris | `docs/pr-notes-validation.md` |
| Review ditindaklanjuti | semua komentar terjawab | 5 temuan sejawat + 5 temuan AI | `docs/peer-review-notes-validation.md`, `docs/ai-review-vs-keputusan.md` |
| README + screenshot + cara menjalankan | lengkap | Lolos | `README.md` |
| Aplikasi berjalan identik dengan akhir Minggu 7 | tidak ada perubahan perilaku selain validasi judul | Lolos | PR #4 hanya menambah validasi; PR #1–#3,#5–#6 hanya format/nama package/CI |

### Uji sterilitas dependency rule (Minggu 7, diulang di Minggu 8)

```
$ grep -RInE "^import .*features/[a-z_]+/data" lib/features/*/presentation
(tidak ada output)

$ grep -RInE "^import .*package:(flutter|dio|sqflite)" lib/features/*/domain
(tidak ada output)

$ grep -RInE "^import .*presentation" lib/features/*/data
(tidak ada output)
```

Ketiganya kosong → aturan dependensi `presentation -> domain <- data` masih terjaga
setelah semua perubahan Minggu 8.

### Status: **SIAP mid review**

Tidak ada PR berstatus *request changes* yang belum ditindaklanjuti, tidak ada
branch fitur yang menggantung, dan `develop` selalu hijau.
