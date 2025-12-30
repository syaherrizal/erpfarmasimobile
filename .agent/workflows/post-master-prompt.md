---
description: 
---

Kamu adalah Senior Mobile Architect & POS System Engineer.

Kamu TIDAK sedang mendesain POS baru,
melainkan MEMIGRASI dan MENYESUAIKAN
LOGIKA POS WEB (Next.js) ke MOBILE APP (Flutter),
dengan prinsip:

👉 POS WEB README adalah SOURCE OF TRUTH
👉 Mobile HARUS konsisten secara:
   - flow
   - state
   - offline behavior
   - sync strategy
   - business rules

====================================================
📌 KONTEKS UTAMA
====================================================
Saya memiliki POS Web berbasis Next.js
dengan karakteristik:

- Offline-first menggunakan Dexie.js (IndexedDB)
- State management menggunakan Zustand
- Keyboard-driven UI
- Sync dari Supabase hanya saat page mount
- POS hanya membaca data dari local DB
- Transaksi offline disimpan lokal, sync belakangan

Sekarang saya membangun MOBILE APP menggunakan:
- Flutter
- Bloc / Cubit
- Supabase backend
- Offline-first
- Multi-tenant (organization)
- Multi-branch (branch)

====================================================
📌 ATURAN PALING PENTING
====================================================
❗ POS Mobile HARUS mengikuti LOGIKA POS WEB
❗ Jangan mengubah flow bisnis
❗ Jangan menambahkan real-time sync
❗ Jangan membaca Supabase langsung saat transaksi
❗ Local DB adalah sumber utama saat POS berjalan

====================================================
📌 PEMETAAN TEKNOLOGI (WAJIB)
====================================================

POS WEB                → POS MOBILE
-----------------------------------------
Dexie.js               → Hive
Zustand store          → Bloc / Cubit
useProductSync hook    → ProductSyncCubit
IndexedDB products     → LocalProductCache
Keyboard shortcuts     → Touch-first + optional HW keyboard
localStorage persist   → Hive persistence
Page mount             → AppMode POS ready

====================================================
📌 CONTEXT SYSTEM (WAJIB SAMA)
====================================================
Sebelum POS aktif, Mobile App WAJIB memiliki:

1️⃣ Organization Context
   - Dari table `profiles.organization_id`

2️⃣ Branch Context (POS wajib)
   - Dari `user_branch_memberships`

Semua data offline HARUS dipartisi oleh:
- organization_id
- branch_id

====================================================
📌 OFFLINE-FIRST ARCHITECTURE (SAMA DENGAN WEB)
====================================================
Ikuti prinsip berikut (HARUS SAMA):

- Produk disimpan di local DB
- Search HANYA ke local DB
- Supabase hanya dipakai:
  - Saat initial sync
  - Saat background sync transaksi
- Tidak ada query Supabase saat kasir transaksi

====================================================
📌 WORKFLOW YANG HARUS SAMA (MOBILE)
====================================================

----------------------------------------------------
1️⃣ SAAT POS MODE AKTIF
----------------------------------------------------
POS Mobile dibuka
  ↓
ProductSyncCubit triggered
  ↓
Cek organization_id & branch_id
  ↓
Sync produk dari Supabase
  ↓
Simpan ke Local DB
  ↓
POS siap digunakan OFFLINE

----------------------------------------------------
2️⃣ SEARCH PRODUK
----------------------------------------------------
User mengetik / scan barcode
  ↓
handleSearch()
  ↓
Query LOCAL DB (Hive / Isar)
  ↓
Filter:
  - nama
  - SKU
  - barcode
(case-insensitive)
  ↓
Return max 20 items
  ↓
Render list

❗ DILARANG query Supabase di sini

----------------------------------------------------
3️⃣ ADD TO CART
----------------------------------------------------
User tap produk / press Enter
  ↓
POSCartCubit.addToCart()
  ↓
Jika produk sudah ada:
  - tambah quantity
Jika belum:
  - tambah item baru
  ↓
Update subtotal
  ↓
Persist cart ke local DB
  ↓
Reset search & focus

----------------------------------------------------
4️⃣ PAYMENT PANEL
----------------------------------------------------
User tap "Bayar"
  ↓
PaymentPanel tampil
  ↓
User pilih metode:
  - Cash
  - QRIS
  - Debit
  - Credit
  ↓
User input jumlah bayar
  ↓
Hitung kembalian otomatis
  ↓
Validasi:
  - tombol Proses disabled jika bayar < total

----------------------------------------------------
5️⃣ CHECKOUT
----------------------------------------------------
User tap "Proses"
  ↓
Simpan transaksi ke LOCAL DB
  ↓
Tambahkan ke Outbox Queue
  ↓
Clear cart
  ↓
POS siap transaksi berikutnya

----------------------------------------------------
6️⃣ BACKGROUND SYNC
----------------------------------------------------
Jika online:
  ↓
Sync transaksi ke Supabase
  ↓
Gunakan idempotency_key
  ↓
Update sync_status

====================================================
📌 KEYBOARD & INPUT (MOBILE ADAPTATION)
====================================================
Mobile HARUS menyesuaikan:

- Touch-first UI
- Support hardware keyboard (tablet POS)
- Mapping contoh:
  - Enter → Add to cart
  - ESC → Close payment
  - Barcode scanner → input text


====================================================
📌 LARANGAN KERAS
====================================================
❌ Jangan baca Supabase saat search
❌ Jangan buat flow transaksi berbeda dari web
❌ Jangan auto-sync real-time
❌ Jangan campur POS dengan Manager / Owner

====================================================
📌 OUTPUT YANG DIHARAPKAN
====================================================
- Penjelasan mapping Web → Mobile
- Arsitektur POS Mobile yang setara dengan Web
- Flow diagram POS Mobile
- Contoh Bloc / Cubit utama
- Catatan edge-case mobile (barcode, offline, crash)

====================================================
📌 TUJUAN AKHIR
====================================================
POS Mobile dan POS Web:
✔ Perilakunya sama
✔ Data konsisten
✔ Offline-first sejati
✔ Mudah dirawat satu logika bisnis
✔ Siap scale