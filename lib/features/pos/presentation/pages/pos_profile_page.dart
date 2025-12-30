import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/utils/user_agent_utils.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../../features/app_mode/presentation/cubit/app_mode_cubit.dart';
import '../../../../features/app_mode/app_mode.dart';
import '../bloc/shift/shift_bloc.dart';

class PosProfilePage extends StatefulWidget {
  const PosProfilePage({super.key});

  @override
  State<PosProfilePage> createState() => _PosProfilePageState();
}

class _PosProfilePageState extends State<PosProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProfileBloc>().add(ProfileLoadRequested(authState.user.id));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          if (!_isEditing) {
            _nameController.text = state.profile['full_name'] ?? '';
            _emailController.text = state.profile['email'] ?? '';
          }
        }
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Fallback to AuthBloc data if ProfileBloc not ready (or error)
        // effectively handling initial state too
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            String role = 'Member';
            String orgName = '';

            if (authState is AuthAuthenticated) {
              final profile = state is ProfileLoaded
                  ? state.profile
                  : authState.profile;
              role =
                  profile?['role']?['name']?.toString().toUpperCase() ??
                  'MEMBER';
              orgName =
                  profile?['organization']?['name']?.toString() ??
                  'Organization';

              // If not loaded yet, prepopulate controllers
              if (state is! ProfileLoaded && !_isEditing) {
                _nameController.text =
                    profile?['full_name'] ??
                    authState.user.email?.split('@')[0] ??
                    '';
                _emailController.text = authState.user.email ?? '';
              }
            }

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                title: Text(
                  'Profil Saya',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                iconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              body: ResponsiveLayout(
                mobile: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(context, role, orgName),
                      const SizedBox(height: 16),
                      _buildEditProfileCard(context),
                      const SizedBox(height: 16),
                      _buildSecurityCard(context),
                      const SizedBox(height: 16),
                      _buildThemeCard(context),
                      const SizedBox(height: 16),
                      _buildSessionsCard(context, state),
                      const SizedBox(height: 32),
                      _buildLogoutButton(context),
                    ],
                  ),
                ),
                tablet: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            _buildProfileCard(context, role, orgName),
                            const SizedBox(height: 24),
                            _buildThemeCard(context),
                            const SizedBox(height: 24),
                            _buildLogoutButton(context),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 8,
                        child: Column(
                          children: [
                            _buildEditProfileCard(context),
                            const SizedBox(height: 24),
                            _buildSecurityCard(context),
                            const SizedBox(height: 24),
                            _buildSessionsCard(context, state),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileCard(BuildContext context, String role, String orgName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white,
            child: Text(
              _nameController.text.isNotEmpty
                  ? _nameController.text.substring(0, 2).toUpperCase()
                  : 'US',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text.isEmpty ? 'User' : _nameController.text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _emailController.text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Active Member',
              style: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow(context, Icons.business, 'Organisasi', orgName),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            Icons.admin_panel_settings_outlined,
            'Role',
            role,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            Icons.key,
            'User ID',
            context.read<AuthBloc>().state is AuthAuthenticated
                ? '${(context.read<AuthBloc>().state as AuthAuthenticated).user.id.substring(0, 8)}...'
                : '...',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildEditProfileCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Edit Profil',
      subtitle: 'Perbarui informasi pribadi dan preferensi akun Anda.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  context,
                  label: 'Nama Lengkap',
                  controller: _nameController,
                  hint: 'Masukkan nama lengkap',
                ),
              ),
              if (ResponsiveLayout.isTablet(context)) ...[
                const SizedBox(width: 24),
                Expanded(
                  child: _buildTextField(
                    context,
                    label: 'Email',
                    controller: _emailController,
                    hint: 'Email address',
                    readOnly: true,
                    helperText:
                        'Email tidak dapat diubah. Hubungi admin jika perlu perubahan.',
                  ),
                ),
              ],
            ],
          ),
          if (ResponsiveLayout.isMobile(context)) ...[
            const SizedBox(height: 16),
            _buildTextField(
              context,
              label: 'Email',
              controller: _emailController,
              hint: 'Email address',
              readOnly: true,
              helperText: 'Email tidak dapat diubah.',
            ),
          ],
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                final user =
                    (context.read<AuthBloc>().state as AuthAuthenticated).user;
                context.read<ProfileBloc>().add(
                  ProfileUpdateRequested(user.id, {
                    'full_name': _nameController.text,
                    'updated_at': DateTime.now().toIso8601String(),
                  }),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Simpan Perubahan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    String? hint,
    bool readOnly = false,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              readOnly ? Icons.lock_outline : Icons.person_outline,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: readOnly
                ? Theme.of(context).colorScheme.surfaceContainerLowest
                : Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            helperText: helperText,
            helperMaxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSectionCard(
            context,
            title: 'Keamanan Akun',
            subtitle: 'Ubah password dan setting 2FA',
            icon: Icons.key_outlined,
            child:
                const SizedBox.shrink(), // Placeholder for now, actionable via tap usually
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSectionCard(
            context,
            title: 'Preferensi Notifikasi',
            subtitle: 'Atur notifikasi email dan push',
            icon: Icons.notifications_outlined,
            child: const SizedBox.shrink(),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return _buildSectionCard(
          context,
          title: 'Tampilan Aplikasi',
          subtitle: 'Sesuaikan tema aplikasi (Light / Dark)',
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  themeMode == ThemeMode.dark ? 'Mode Gelap' : 'Mode Terang',
                ),
                value: themeMode == ThemeMode.dark,
                onChanged: (isDark) {
                  context.read<ThemeCubit>().toggleTheme(isDark);
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.swap_horizontal_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Ganti Mode Aplikasi'),
                subtitle: const Text('Beralih ke Command Center / Owner Mode'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  final shiftState = context.read<ShiftBloc>().state;
                  // Determine if shift is open.
                  // Note: ShiftBloc state might be ShiftOpened, ShiftClosed, etc.
                  // We need to be careful. If state is ShiftInitial or Loading, we might not know yet.
                  // But usually in POS root, ShiftBloc is initialized.

                  if (shiftState is ShiftOpened) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Akses Ditolak'),
                        content: const Text(
                          'Anda tidak dapat mengganti mode aplikasi saat Shift Kasir masih berstatus OPEN.\n\nHarap tutup shift terlebih dahulu melalui menu Shift untuk melanjutkan.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Mengerti'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Proceed to switch mode
                    context.read<AppModeCubit>().setMode(AppMode.owner);
                    // Navigation should be handled by AppMode wrapper/listener in root,
                    // but usually we might need to pop all routes or go to root.
                    // Assuming AppRoot handles this based on state change.
                    // For safety, we can use context.go('/') if root handles redirection.
                    context.go('/');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSessionsCard(BuildContext context, ProfileState state) {
    List<Map<String, dynamic>> sessions = [];
    if (state is ProfileLoaded) {
      sessions = state.sessions;
    }

    return _buildSectionCard(
      context,
      title: 'Sesi Login Aktif Saya',
      subtitle: 'Kelola perangkat yang sedang mengakses akun Anda saat ini.',
      icon: Icons.devices,
      child: Column(
        children: [
          if (sessions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Tidak ada riwayat sesi ditemukan.'),
            )
          else
            ...sessions.asMap().entries.map((entry) {
              final index = entry.key;
              final session = entry.value;
              final userAgent = session['user_agent'] as String?;
              final ip = session['ip'] as String? ?? 'Unknown IP';
              final date =
                  DateTime.tryParse(session['login_at']?.toString() ?? '') ??
                  DateTime.now();
              // Assume first session is current for now as per sort order
              final isCurrent = index == 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                  color: isCurrent
                      ? Colors.green.shade50
                      : Theme.of(context).colorScheme.surface,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Icon(
                        UserAgentUtils.getIcon(userAgent),
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${UserAgentUtils.getBrowserName(userAgent)} on ${UserAgentUtils.getOsName(userAgent)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'CURRENT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$ip  •  ${DateFormat('d MMM HH:mm').format(date)}',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isCurrent)
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.logout, size: 14),
                        label: const Text('End Session'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red.shade200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    IconData? icon,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          context.read<AuthBloc>().add(AuthLogoutRequested());
          context.go('/login');
        },
        icon: const Icon(Icons.logout),
        label: const Text('Keluar (Logout)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          side: BorderSide(color: Colors.red.shade100),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
