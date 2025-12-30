# RBAC & Permission Implementation

The application uses a hybrid RBAC (Role-Based Access Control) system that combines system-default roles with dynamic granular permissions.

## Role Detection Logic

### System Role: "Owner"
The "Owner" role is treated as a "System Role" with global override capabilities.
- **Detection Tier 1**: Checks if `profiles.role.name` is "Owner" (case-insensitive).
- **Detection Tier 2 (Fallback)**: Checks if `profiles.user_id` matches `organizations.owner_id`.
- **Capability**: Has implicit access to all modes (POS, Manager, Owner) regardless of literal permission records.

### Dynamic Roles
All other roles (Manager, Kasir, Apoteker, etc.) rely on granular permission codes mapped in the database.

## Permission-to-Mode Mapping

The visibility of application modes in `ModeSelectionPage` is controlled by specific permission codes:

| Mode | Required Permission Code(s) | Fallback |
| :--- | :--- | :--- |
| **Kasir (POS)** | `menu.pos` OR `pos.*` | System Owner |
| **Manager Cabang** | `menu.inventory`, `menu.reporting`, `menu.finance`, etc. | System Owner |
| **Owner (Enterprise)** | `menu.dashboard` | System Owner |

## Implementation Technicals

### PermissionCubit
The `PermissionCubit` fetches permissions from the `role_permissions` table. 
- It uses `Set<String>` to store permission codes for $O(1)$ lookup performance in the UI.
- It ensures that permissions are loaded globally, making them available to any sub-feature via `BlocProvider`.

### Code Reference
Visibility check pattern used in `ModeSelectionPage`:
```dart
final bool hasManagerAccess = isOwner || permissions.any((p) => p.startsWith('menu.'));
```
