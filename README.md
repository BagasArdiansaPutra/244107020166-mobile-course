# 244107020166 — Mobile Programming Course

Repository tugas mata kuliah **Pemrograman Mobile** (semester 5).
Setiap minggu disimpan dalam foldernya sendiri agar riwayat perubahan mudah
diaudit dan setiap project dapat dijalankan/diuji secara terpisah.

| | |
|---|---|
| Nama | Bagas Ardiansa Putra |
| NIM | 244107020166 |
| Kelas | TI-3D |
| Flutter | 3.47.2 (stable) / Dart 3.13.2 |
| Branch kerja | `develop` (bukan `main`) |

## Daftar project

| Minggu | Folder | Fokus |
|---|---|---|
| 1 | `week1-mobile-development-ecosystem-flutter-refresh` | Ekosistem Flutter, widget tree dasar |
| 2 | `week2_responsive_dashboard` | Layout responsif (breakpoint) |
| 3 | `week3_navigation`, `week3_todo` | Navigasi `go_router`, state todo |
| 4 | `week4_api` | Konsumsi REST API, pagination, detail |
| 5 | `week5_local_storage_offline_first` | SQLite, dirty flag, sync, cache-first, `shared_preferences` |
| 6 | `week6_authentication_security_fcm` | Login + token aman, refresh 401, deep link, FCM |
| 7 | `week_7_clean_architecture` | Refactor feature-first (`presentation → domain ← data`) |
| 8 | `08-week-8-mid-project-review` | Hygiene branch/commit, PR, peer review, static analysis |

## Laporan Minggu 8 — Mid Project Review

Laporan lengkap beserta screenshot ada di
**[`08-week-8-mid-project-review/README.md`](08-week-8-mid-project-review/README.md)**.

Cakupannya:

1. **Audit riwayat** — `git log --oneline -15`, `git branch -a`, `git status`
   beserta daftar masalah yang ditemukan
   ([`screenshots/01-audit.png`](08-week-8-mid-project-review/screenshots/01-audit.png)).
2. **Branch kerja yang benar** — `develop` dibuat sekali dari `main`, lalu
   `feat/notes-validation` dari `develop`, commit logis via `git add -p`
   ([`02-develop.png`](08-week-8-mid-project-review/screenshots/02-develop.png),
   [`04-add-p.png`](08-week-8-mid-project-review/screenshots/04-add-p.png),
   [`05-commit-push.png`](08-week-8-mid-project-review/screenshots/05-commit-push.png)).
3. **Perbaikan pesan commit lama** — tabel sebelum/sesudah 5 commit di
   [`docs/review-checklist.md`](08-week-8-mid-project-review/docs/review-checklist.md).
4. **PR kecil + peer review + AI review** — `docs/pr-notes-validation.md`,
   `docs/peer-review-notes-validation.md`, `docs/ai-review-vs-keputusan.md`.
5. **Static analysis** — `flutter analyze`, `dart format`, `flutter test` hijau
   di week5, week6, week7 (8 + 19 + 24 = 51 test).

| Audit | Riwayat branch | CI |
|---|---|---|
| ![Audit](08-week-8-mid-project-review/screenshots/01-audit.png) | ![Graph](08-week-8-mid-project-review/screenshots/13-graph.png) | ![CI](08-week-8-mid-project-review/screenshots/11-ci.png) |

## Cara menjalankan

```bash
git clone https://github.com/BagasArdiansaPutra/244107020166-mobile-course.git
cd 244107020166-mobile-course
git checkout develop

cd week5_local_storage_offline_first
flutter pub get
flutter run
```

Tiga pemeriksaan wajib sebelum minta review (ulangi di tiap folder project):

```bash
flutter analyze
dart format --output=none --set-exit-if-changed .
flutter test
```

## Konvensi commit

Format `tipe(scope): ringkasan imperatif`, tipe dari
`feat|fix|refactor|test|docs|chore|ci`. Satu commit = satu perubahan logis
(gunakan `git add -p`), branch hidup < 3 hari, selalu bercabang dari `develop`,
dan `main` tidak pernah di-commit langsung.
