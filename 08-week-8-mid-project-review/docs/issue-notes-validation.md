# Issue: validasi judul catatan kosong

ID internal: **#4** · Label: `bug`, `week5`, `needs-review`
Pelapor: Bagas Ardiansa Putra · Assignee: Bagas Ardiansa Putra
Branch: `feat/notes-validation` → target `develop`

> Catatan transparansi: issue ini dicatat di repo sebagai dokumen karena `gh`
> CLI tidak tersedia di mesin praktikum (lihat `README.md` bagian 6.5). Nomor
> `#4` adalah ID pelacakan yang dipakai konsisten di seluruh laporan, bukan
> nomor issue di github.com. Isi di bawah adalah body issue yang dipakai saat
> penugasan.

---

## Ringkasan

Pengguna dapat menekan **Simpan** pada dialog "Catatan baru" dengan judul kosong
atau berisi spasi saja. Tidak ada catatan tersimpan **dan** tidak ada pesan
kesalahan, sehingga pengguna mengira datanya hilang.

## Langkah reproduksi

1. Buka `week5_local_storage_offline_first`, jalankan aplikasi.
2. Tekan tombol **+** di kanan bawah.
3. Biarkan field judul kosong (atau isi hanya spasi).
4. Tekan **Simpan**.

## Perilaku saat ini

- Dialog tertutup.
- Tidak ada baris baru pada daftar catatan.
- Tidak ada pesan error apa pun.

Penyebab: `_promptAddNote` memanggil `Navigator.pop(controller.text)` lalu
`if (trimmed.isEmpty) return;` — berhenti diam-diam.

Selain itu `NoteRepository.addNote` menerima `title` apa adanya, sehingga jalur
non-UI (sync/import di masa depan) bisa menulis baris dengan judul kosong ke
SQLite.

## Perilaku yang diharapkan

- Judul kosong / hanya spasi **ditolak** dengan pesan yang terlihat pengguna.
- Dialog tetap terbuka agar pengguna bisa memperbaiki input.
- Pesan error **hilang** begitu pengguna mulai mengetik.
- Judul disimpan dalam bentuk ter-*trim*.
- Aturan yang sama berlaku di UI **dan** di repository (satu sumber aturan).

## Kriteria penerimaan

- [ ] `validateNoteTitle` ada di `lib/core/note_validation.dart`, tanpa import Flutter.
- [ ] `NoteRepository.addNote` memanggil validator **sebelum** `_openDb()`.
- [ ] `AddNoteDialog` menampilkan `errorText` dan me-reset-nya lewat `onChanged`.
- [ ] `TextEditingController` di-`dispose()`.
- [ ] Ada test untuk jalur gagal: UI menampilkan error, error hilang, judul ter-trim,
      repository menolak sebelum membuka database, dan pesan error tidak memuat judul.
- [ ] `flutter analyze` bersih, `dart format` 0 changed, `flutter test` hijau.

## Di luar cakupan

- Migrasi week5 ke clean architecture (materi Minggu 7, bukan issue ini).
- Lokalisasi pesan error (belum ada infrastruktur i18n).
- Perubahan skema database.

## Rencana uji

| Jenis | Bukti |
|---|---|
| Unit | `test/validate_note_test.dart` |
| Repository | `test/note_repository_validation_test.dart` (termasuk flag `openDb` tidak dipanggil) |
| Widget | `test/add_note_dialog_test.dart` (error muncul, hilang, trim) |
| Manual | 4 langkah pada `README.md` bagian 9.3 |

## Definition of done

PR kecil (< 300 baris) ke `develop`, lolos review sejawat minimal satu putaran
`Request changes` → `Approve`, lalu di-*squash merge* dan branch dihapus.
