import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erpfarmasimobile/core/di/injection.dart';
import 'package:erpfarmasimobile/features/owner/presentation/bloc/organization/owner_organization_cubit.dart';
import 'package:erpfarmasimobile/features/owner/presentation/bloc/organization/owner_organization_state.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/organization/organization_context_cubit.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/organization/organization_context_state.dart';

class OwnerOrganizationSettingsPage extends StatelessWidget {
  const OwnerOrganizationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get Organization ID from Context
    String? orgId;
    final orgState = context.read<OrganizationContextCubit>().state;
    if (orgState is OrganizationContextLoaded) {
      orgId = orgState.organizationId;
    }

    if (orgId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error: Organization ID not found in context'),
        ),
      );
    }

    return BlocProvider(
      create: (_) => sl<OwnerOrganizationCubit>()..loadOrganization(orgId!),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Pengaturan Organisasi',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          backgroundColor: Theme.of(context).cardColor,
          foregroundColor: Theme.of(context).iconTheme.color,
          elevation: 0,
        ),
        body: BlocConsumer<OwnerOrganizationCubit, OwnerOrganizationState>(
          listener: (context, state) {
            if (state is OwnerOrganizationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is OwnerOrganizationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is OwnerOrganizationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OwnerOrganizationLoaded) {
              return _OrganizationForm(data: state.organization, orgId: orgId!);
            } else if (state is OwnerOrganizationInitial) {
              return const SizedBox.shrink();
            }
            // For Updating state, we might still want to show the form or a loader overlay.
            // But usually we just show previous loaded state or handle it within form.
            // Simplification: returns empty or loader if heavily refreshing.
            // Ideally we check if we have data even if updating.
            // But CUBIT emits new state. If Updating doesn't carry data, we lose the form.
            // My State definition didn't include data in Updating.
            // For now, let's treat Updating as "Loading" or handle it inside loaded if possible.
            // But since I restart stream, it will be blank.
            // Let's rely on Loading for now.
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _OrganizationForm extends StatefulWidget {
  final Map<String, dynamic> data;
  final String orgId;

  const _OrganizationForm({required this.data, required this.orgId});

  @override
  State<_OrganizationForm> createState() => _OrganizationFormState();
}

class _OrganizationFormState extends State<_OrganizationForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _taxIdController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data['name']);
    _addressController = TextEditingController(text: widget.data['address']);
    _phoneController = TextEditingController(text: widget.data['phone']);
    _emailController = TextEditingController(text: widget.data['email']);
    _websiteController = TextEditingController(text: widget.data['website']);
    _taxIdController = TextEditingController(
      text: widget.data['tax_id'],
    ); // Assuming column is tax_id
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _taxIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Informasi Dasar'),
            _buildTextField(
              'Nama Organisasi',
              _nameController,
              validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
            ),
            _buildTextField('Alamat', _addressController, maxLines: 3),

            const SizedBox(height: 24),
            _buildSectionTitle('Kontak'),
            _buildTextField(
              'Nomor Telepon',
              _phoneController,
              keyboardType: TextInputType.phone,
            ),
            _buildTextField(
              'Email',
              _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField(
              'Website',
              _websiteController,
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Legalitas'),
            _buildTextField('NPWP / Tax ID', _taxIdController),

            const SizedBox(height: 24),
            _buildReadOnlyField('ID Organisasi', widget.orgId),
            _buildReadOnlyField(
              'Terdaftar Sejak',
              widget.data['created_at']?.split('T')[0] ?? '-',
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() == true) {
      final updates = {
        'name': _nameController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'website': _websiteController.text,
        'tax_id': _taxIdController.text,
      };
      context.read<OwnerOrganizationCubit>().updateOrganization(
        widget.orgId,
        updates,
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: value,
            readOnly: true,
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
