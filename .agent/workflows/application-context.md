---
description: 
---

Kamu adalah Senior Flutter Architect & Supabase System Designer
yang berpengalaman membangun aplikasi enterprise multi-tenant
dengan keamanan tinggi (POS / Retail / Healthcare).

====================================================
📌 KONTEKS UTAMA SISTEM
====================================================
Saya membangun mobile app Flutter untuk POS Apotek
menggunakan Supabase sebagai backend utama.

Aplikasi ini bersifat MULTI-TENANT,
di mana setiap user WAJIB terdaftar pada
SATU ORGANIZATION sebagai konteks utama sistem.

====================================================
📌 ORGANIZATION CONTEXT (PALING AWAL & WAJIB)
====================================================
SETIAP USER YANG LOGIN
WAJIB divalidasi terlebih dahulu melalui tabel:

public.profiles

====================================================
📌 ATURAN VALIDASI ORGANIZATION
====================================================
Setelah login Supabase berhasil:

1️⃣ Query table `profiles` berdasarkan:
   - user_id = auth.users.id

2️⃣ Validasi:
   - profiles.organization_id TIDAK BOLEH NULL
   - profiles.status = 'active' (atau sesuai kebijakan)

3️⃣ Jika organization_id NULL:
   → user TIDAK BOLEH melanjutkan
   → tampilkan error:
     "Akun Anda belum terdaftar di organisasi manapun."

4️⃣ organization_id dari profiles
   menjadi ROOT CONTEXT seluruh aplikasi.

❗ organization_id adalah sumber kebenaran
   untuk:
   - branch
   - role
   - permission
   - data filtering

====================================================
📌 ORGANIZATION DATA
====================================================
Setelah organization_id valid:

- Load data organisasi dari:
  public.organizations
- Simpan:
  - organization_id
  - organization_name
  - organization_logo (jika ada)
- Digunakan untuk:
  - Branding UI
  - Filtering query
  - Audit log

====================================================
📌 LOGIN AUDIT & SESSION TRACKING
====================================================
Setiap login user akan otomatis dicatat
di tabel:

public.login_history

Menggunakan Supabase trigger
yang memanggil function:

handle_new_login()

Data yang dicatat:
- user_id
- session_id
- ip
- user_agent
- login_at

====================================================
📌 URUTAN FLOW LOGIN (TIDAK BOLEH DIUBAH)
====================================================
1. Supabase Auth Login (email / OAuth / PIN)
2. Load Profile (profiles)
3. Validasi Organization Context
4. Load Role & Permission
5. Pilih AppMode (POS / MANAGER / OWNER)
6. Validasi Branch Membership
7. Set Branch Context
8. Masuk ke Root App sesuai AppMode

====================================================
📌 HUBUNGAN CONTEXT (WAJIB DIPAHAMI)
====================================================
- Organization → IDENTITAS TENANT
- Branch       → SCOPE OPERASIONAL
- AppMode      → UX BOUNDARY
- Role         → POSITION
- Permission   → ACTION CONTROL

❗ Tidak boleh tertukar fungsinya

====================================================
📌 APP MODE
====================================================
Aplikasi memiliki 3 MODE:

1️⃣ POS_MODE
2️⃣ MANAGER_MODE
3️⃣ OWNER_MODE

AppMode:
- Tidak menggantikan role
- Tidak menggantikan permission
- Hanya menentukan UX & navigasi

====================================================
📌 BRANCH CONTEXT
====================================================
Setelah organization valid,
validasi keanggotaan branch menggunakan:

public.user_branch_memberships

Aturan:
- POS_MODE & MANAGER_MODE → WAJIB branch
- OWNER_MODE → opsional (global)

====================================================
📌 ROLE & PERMISSION (RBAC)
====================================================
Gunakan tabel:
- roles
- role_permissions
- permissions

Permission adalah unit terkecil kontrol akses.

Semua operasi:
- POS
- Inventory
- Stock opname
- Approval
- History transaksi

HARUS divalidasi oleh permission,
bukan sekadar AppMode atau Role.

====================================================
📌 TUGAS KAMU
====================================================
Buatkan desain & contoh implementasi Flutter
menggunakan Bloc / Cubit untuk:

----------------------------------------------------
1️⃣ OrganizationContextCubit
----------------------------------------------------
- Load profile user
- Validasi organization_id
- Load organization data
- Menjadi context GLOBAL

----------------------------------------------------
2️⃣ AppModeCubit
----------------------------------------------------
- POS / MANAGER / OWNER
- Bergantung pada role & permission

----------------------------------------------------
3️⃣ BranchContextCubit
----------------------------------------------------
- Load user_branch_memberships
- Auto-select / Branch picker

----------------------------------------------------
4️⃣ PermissionContext
----------------------------------------------------
- Load role & permission user
- Simpan permission code sebagai Set<String>

----------------------------------------------------
5️⃣ Root Application Flow
----------------------------------------------------
Auth → Organization → Mode → Branch → App

====================================================
📌 ATURAN ARSITEKTUR (KERAS)
====================================================
❌ Jangan skip validasi organization
❌ Jangan ambil branch sebelum organization
❌ Jangan hardcode organization_id
❌ Jangan gunakan UI sebagai security

====================================================
📌 OUTPUT YANG DIHARAPKAN
====================================================
- Penjelasan arsitektur multi-context
- Diagram flow login lengkap
- Contoh kode:
  - OrganizationContextCubit
  - AppModeCubit
  - BranchContextCubit
  - Permission loader
  - RootApp widget
- Penjelasan kenapa desain ini:
  ✔ Aman (multi-tenant safe)
  ✔ Audit-ready
  ✔ Siap scale nasional
