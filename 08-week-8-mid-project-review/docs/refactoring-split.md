# Refactoring Challenge — memecah PR besar menjadi PR kecil

Dokumen ini mencatat langkah 1 jobsheet Praktikum 7: **satu PR > 300 baris
dipecah menjadi 2–3 PR kecil berurutan** yang masing-masing bisa direview
< 15 menit.

Semua angka di bawah diambil dari riwayat git repo ini, bukan perkiraan.

---

## 1. Memilih PR besar

```
$ git log --format="%h" --all | ... (shortstat tiap commit)
```

| Commit | Isi | File | Baris | Layak dipecah? |
|---|---|---|---|---|
| `765edc3` | import project week2 | 545 | +22.386 | Tidak — 90% file generated platform |
| `be47159` | modul week5 + week6 | 319 | +13.609 | Ya, per modul |
| `80db0b8` | import project week7 | 160 | +7.530 | Tidak — satu project utuh |
| `0ccf97e` | project week1 | 131 | +5.027 | Tidak — satu project utuh |
| **`91468ae`** | **laporan mid review** | **23** | **+970** | **Ya — dipilih** |

**Yang dipilih: `91468ae` (23 file, +970 baris).** Alasannya:

1. Perubahannya nyata melewati batas 300 baris (970).
2. Isinya lima dokumen terpisah, sehingga bisa dipotong di batas file tanpa
   mengubah kode sama sekali — tidak ada risiko regresi.
3. `be47159`/`80db0b8` adalah *project import*: memecahnya per modul tetap
   menyisakan ribuan baris per PR, jadi pelajarannya bukan "pecah setelah
   ditulis" melainkan "jangan pernah menulis PR sebesar itu".

## 2. Pengukuran (bukti)

```
$ git show --shortstat --format="" 91468ae
 23 files changed, 970 insertions(+)

$ git show --shortstat --format="" 91468ae -- .../docs/review-checklist.md .../docs/pr-notes-validation.md
 2 files changed, 193 insertions(+)

$ git show --shortstat --format="" 91468ae -- .../docs/peer-review-notes-validation.md .../docs/ai-review-vs-keputusan.md
 2 files changed, 282 insertions(+)

$ git show --shortstat --format="" 91468ae -- .../README.md .../screenshots
 19 files changed, 495 insertions(+)
```

## 3. Rencana tiga PR berurutan

| Urutan | Judul PR | Isi | File | Baris | Estimasi review |
|---|---|---|---|---|---|
| **PR-A** | `docs(week8): checklist commit dan body PR` | `docs/review-checklist.md` (91) + `docs/pr-notes-validation.md` (102) | 2 | **193** | ~8 menit |
| **PR-B** | `docs(week8): peer review dan AI review` | `docs/peer-review-notes-validation.md` (123) + `docs/ai-review-vs-keputusan.md` (159) | 2 | **282** | ~12 menit |
| **PR-C** | `docs(week8): README laporan dan screenshot` | `README.md` (495) + 18 gambar | 19 | **495** | ~15 menit (prosa + gambar, tanpa kode) |
| | | | **23** | **970** | |

**Mengapa urutan ini?**

- **PR-A** menetapkan *aturan* lebih dulu: format commit, ukuran PR, dan body PR
  yang dipakai semua PR berikutnya. Tanpa ini, reviewer belum punya patokan.
- **PR-B** menambahkan *bukti pelaksanaan aturan*: hasil review sejawat dan
  keputusan atas saran AI. Ia bergantung pada PR-A karena keduanya merujuk ID
  temuan yang sama (R1–R5, A1–A5).
- **PR-C** adalah *ringkasan*: README merangkum PR-A dan PR-B, jadi harus
  terakhir agar tautan dan angkanya sudah final.

PR-C memang 495 baris, di atas panduan 300. Itu diterima karena isinya Markdown
dan 18 gambar (nol baris kode); review berarti membaca, bukan menelusuri logika.
Bila aturan 300 baris ingin dipatuhi ketat, PR-C dipecah lagi menjadi
"Praktikum 1–2" dan "Praktikum 3 + AI Challenge" — tapi itu menambah PR keempat,
di luar batas 2–3 PR pada jobsheet.

## 4. Cara memecah (dapat direproduksi)

Riwayat `main` **tidak ditulis ulang** karena sudah di-push. Perintah berikut
menunjukkan cara memecah commit yang sama menjadi tiga PR berurutan:

```bash
# PR-A
git checkout -b docs/week8-a develop
git checkout 91468ae -- 08-week-8-mid-project-review/docs/review-checklist.md \
                        08-week-8-mid-project-review/docs/pr-notes-validation.md
git commit -m "docs(week8): checklist commit dan body PR"

# PR-B (setelah PR-A merge)
git checkout -b docs/week8-b develop
git checkout 91468ae -- 08-week-8-mid-project-review/docs/peer-review-notes-validation.md \
                        08-week-8-mid-project-review/docs/ai-review-vs-keputusan.md
git commit -m "docs(week8): peer review dan AI review"

# PR-C (setelah PR-B merge)
git checkout -b docs/week8-c develop
git checkout 91468ae -- 08-week-8-mid-project-review/README.md \
                        08-week-8-mid-project-review/screenshots
git commit -m "docs(week8): README laporan dan screenshot"
```

Karena tidak ada kode yang berubah, setiap PR hanya perlu `git diff --check`
untuk spasi dan pemeriksaan tautan gambar.

## 5. PR kecil yang benar-benar dikerjakan

Praktikum ini sendiri dikirim sebagai **tiga commit berurutan** di `main` agar
polanya terbukti, bukan hanya direncanakan:

| Commit | Isi | Baris |
|---|---|---|
| 1 | `docs(week8): rencana split PR besar + bukti pengukuran` (dokumen ini) | < 300 |
| 2 | `docs(week8): bukti testing per PR dan tabel error umum` | < 300 |
| 3 | `docs(week8): checklist verifikasi mandiri + README bagian 9` | < 300 |

Setiap commit meninggalkan repo dalam keadaan hijau (`flutter analyze` bersih,
`dart format` 0 changed, `flutter test` 51 lulus).

## 6. Pelajaran

- **Ukur dulu, pecah kemudian.** `git show --numstat` menunjukkan file mana yang
  benar-benar perlu dibaca manusia; pada project import, mayoritas baris adalah
  file generated platform yang tidak pernah direview.
- **Potong di batas tujuan review**, bukan di batas jumlah baris. PR-A (aturan),
  PR-B (bukti review), PR-C (ringkasan) masing-masing punya satu pertanyaan yang
  harus dijawab reviewer.
- **PR sebesar 13.000 baris tidak bisa diselamatkan dengan dipecah.** Yang benar
  adalah tidak menulisnya: satu modul = satu PR, sejak awal.
