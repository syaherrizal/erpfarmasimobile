---
description: 
---

Kamu adalah Senior Flutter Architect
yang berpengalaman membangun aplikasi enterprise
menggunakan Bloc / Cubit sebagai state management utama.

====================================================
📌 KONTEKS
====================================================
Saya membangun mobile app Flutter untuk POS Apotek
menggunakan Supabase sebagai backend (Auth, PostgreSQL, RLS).

Aplikasi ini adalah SATU APLIKASI (satu binary),
namun memiliki konsep APP MODE yang mengontrol:
- UX
- Navigasi
- Akses fitur
- Akses data (divalidasi server-side)

====================================================
📌 APP MODE (WAJIB)
====================================================
Aplikasi memiliki 3 MODE utama:

1️⃣ POS_MODE
   - Digunakan oleh kasir
   - Fokus transaksi penjualan

2️⃣ MANAGER_MODE
   - Digunakan oleh manager cabang
   - Fokus operasional & kontrol cabang

3️⃣ OWNER_MODE
   - Digunakan oleh owner
   - Fokus monitoring global & approval strategis

Mode:
- Dipilih saat login / first use (berdasarkan role)
- Disimpan di local secure storage
- Menjadi ROOT STATE aplikasi
- HARUS divalidasi di backend (Supabase RLS)

====================================================
📌 BATASAN & KAPABILITAS TIAP MODE
====================================================

🧾 POS_MODE
- Input transaksi penjualan
- Scan / cari produk
- Shift & pembayaran
- TIDAK boleh:
  - Lihat laporan
  - Lihat history transaksi global
  - Stock opname
  - Approval

🗂️ MANAGER_MODE
- Scope: 1 cabang (branch-level)
- Bisa:
  - Melakukan stock opname
  - Melihat inventory & batch
  - Approval operasional (opname, retur, dll)
  - Melihat history transaksi cabang
- TIDAK boleh:
  - Transaksi penjualan POS
  - Akses data lintas cabang
  - Akses kontrol owner (global)

📊 OWNER_MODE
- Scope: seluruh bisnis
- Bisa:
  - Monitoring semua cabang
  - Approval strategis
  - Lihat laporan & insight
  - Revoke / kontrol device
- TIDAK boleh:
  - Transaksi penjualan POS

====================================================
📌 TUGAS KAMU
====================================================
Buatkan contoh implementasi Flutter
menggunakan Bloc / Cubit untuk:

1️⃣ AppModeCubit
   - Menyimpan state:
     - selectedMode (POS / MANAGER / OWNER)
     - status (initial, loading, ready)
   - Load mode dari local storage
   - Switch mode dengan validasi (role & auth)

2️⃣ Root App Widget
   - Menggunakan BlocBuilder / BlocSelector
   - Menampilkan root page berdasarkan AppMode:
     - POSRootPage → POS_MODE
     - ManagerRootPage → MANAGER_MODE
     - OwnerRootPage → OWNER_MODE
   - TANPA menggunakan route guard berlebihan

3️⃣ Struktur Navigasi Berbasis Mode
   - POS UI terisolasi
   - Manager UI terisolasi
   - Owner UI terisolasi
   - Tidak ada cross-access antar mode

====================================================
📌 ATURAN ARSITEKTUR (WAJIB)
====================================================
❌ Jangan gunakan disable menu sebagai security
❌ Jangan mencampur halaman antar mode
❌ Jangan jadikan role-based menu sebagai root decision
✅ Navigasi HARUS berbasis AppMode state (Bloc)

====================================================
📌 OUTPUT YANG DIHARAPKAN
====================================================
- Penjelasan singkat arsitektur AppMode
- Diagram alur state (deskriptif)
- Contoh kode:
  - AppMode enum
  - AppModeState
  - AppModeCubit
  - main.dart / RootApp
  - POSRootPage
  - ManagerRootPage
  - OwnerRootPage
- Penjelasan kenapa pendekatan ini:
  ✔ Aman (security)
  ✔ Rapi (maintainable)
  ✔ Scalable (tambah mode di masa depan)
