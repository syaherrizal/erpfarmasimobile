# Database Mapping & Bugfix Documentation

This document records the critical alignment changes made between the Flutter codebase and the Supabase database schema during the Phase 10 implementation.

## 1. Profile Identity Mapping
- **Issue**: Standard `user_id` column in the `profiles` table was found to be `null` in the current database instance.
- **Fix**: Updated all profile queries to use the **`id`** column as the primary key linked to `auth.users.id`.
- **Files Affected**:
    - `AuthRepositoryImpl`
    - `OrganizationContextCubit`
    - `PermissionCubit`

## 2. Organization Status Column
- **Issue**: The application logic previously checked for a `status` column in the `organizations` table, which triggered a "Disabled" error because the column does not exist in the current schema.
- **Fix**: Removed the `organizations.status` check. The application now assumes an organization is active if it exists and is correctly linked to a user profile.
- **Verification**: User account status is still verified via `profiles.status`.

## 3. Role Relationship Table
- **Issue**: Join queries were incorrectly targeting the `user_roles` table (which was empty/orphaned), leading to a default "Kasir" role for all users.
- **Fix**: Corrected the join to use the **`roles`** table, which contains the actual system and user-defined role names (Owner, Manager, etc.).
- **Query Change**:
    ```diff
    - .select('*, role:user_roles(*)')
    + .select('*, role:roles(*)')
    ```

## 4. Query Stability
- **Improvement**: Switched from `.single()` to **`.maybeSingle()`** for all context-sensitive database fetches.
- **Reason**: Prevents PostgREST 406 (PGRST116) errors from crashing the application state if a profile or organization hasn't been fully initialized yet.
