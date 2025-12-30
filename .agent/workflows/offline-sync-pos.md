---
description: 
---

Kamu adalah Mobile System Architect
yang ahli membangun aplikasi POS offline-first.

====================================================
📌 KONTEKS
====================================================
Saya membangun POS Apotek berbasis Flutter + Supabase.

Kondisi lapangan:
- Internet bisa tidak stabil
- POS harus tetap bisa transaksi
- Data HARUS sinkron saat online kembali

====================================================
📌 TUGAS KAMU
====================================================
Buatkan desain arsitektur OFFLINE-FIRST POS
yang mencakup:

1️⃣ Data apa saja yang wajib offline
   - Produk
   - Harga
   - Stok
   - Transaksi
   - Shift

2️⃣ Skema local database
   - Gunakan Hive / Isar
   - Sertakan field:
     - local_id
     - server_id
     - sync_status (pending, synced, failed)
     - updated_at

3️⃣ Flow transaksi POS:
   - Online
   - Offline
   - Online kembali (sync)

4️⃣ Conflict handling:
   - Double submit
   - Retry
   - Idempotency

5️⃣ Strategi sinkronisasi:
   - Queue / outbox pattern
   - Background sync
   - Manual retry jika gagal

====================================================
📌 ATURAN
====================================================
❌ Jangan asumsikan selalu online
❌ Jangan menghapus data lokal sebelum sukses sync
❌ Jangan bergantung ke UI untuk validasi sync

====================================================
📌 OUTPUT YANG DIHARAPKAN
====================================================
- Diagram flow (dalam teks)
- Contoh struktur entity lokal
- Contoh pseudocode sync process
- Best practice POS offline di dunia nyata
