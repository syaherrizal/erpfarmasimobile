import 'package:flutter/material.dart';
import 'package:erpfarmasimobile/features/owner/presentation/bloc/branch/owner_branch_cubit.dart';

class OwnerBranchFormPage extends StatefulWidget {
  final String orgId;
  final Map<String, dynamic>? branchData;
  final OwnerBranchCubit cubit;

  const OwnerBranchFormPage({
    super.key,
    required this.orgId,
    this.branchData,
    required this.cubit,
  });

  @override
  State<OwnerBranchFormPage> createState() => _OwnerBranchFormPageState();
}

class _OwnerBranchFormPageState extends State<OwnerBranchFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  String _type = 'outlet'; // Default type
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.branchData;
    _nameController = TextEditingController(text: data?['name']);
    _addressController = TextEditingController(text: data?['address']);
    _phoneController = TextEditingController(text: data?['phone']);
    if (data?['type'] != null) {
      final rawType = data!['type'].toString().toLowerCase();
      if (rawType.contains('warehouse') || rawType.contains('gudang')) {
        _type = 'warehouse';
      } else {
        _type = 'outlet';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() == true) {
      setState(() {
        _isLoading = true;
      });

      final branchData = {
        'name': _nameController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'type': _type,
      };

      try {
        if (widget.branchData != null) {
          // Update
          await widget.cubit.updateBranch(
            widget.orgId,
            widget.branchData!['id'],
            branchData,
          );
        } else {
          // Add
          await widget.cubit.addBranch(widget.orgId, branchData);
        }

        if (mounted) {
          Navigator.pop(context); // Close the form
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan: $e'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.branchData != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Cabang' : 'Tambah Cabang Baru',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).iconTheme.color,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submit,
              child: const Text(
                'Simpan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informasi Cabang'),
              _buildTextField(
                'Nama Cabang',
                _nameController,
                validator: (v) =>
                    v?.isEmpty == true ? 'Nama wajib diisi' : null,
                hint: 'Contoh: Cabang Jakarta Selatan',
              ),
              _buildTextField(
                'Alamat',
                _addressController,
                maxLines: 3,
                hint: 'Alamat lengkap cabang...',
              ),
              _buildTextField(
                'Nomor Telepon',
                _phoneController,
                keyboardType: TextInputType.phone,
                hint: '0812...',
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Tipe Cabang'),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Outlet / Apotek'),
                      subtitle: const Text(
                        'Melayani penjualan langsung ke pelanggan',
                      ),
                      value: 'outlet',
                      groupValue: _type,
                      onChanged: (val) => setState(() => _type = val!),
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text('Gudang / Warehouse'),
                      subtitle: const Text(
                        'Penyimpanan stok, tidak melayani penjualan POS langsung',
                      ),
                      value: 'warehouse',
                      groupValue: _type,
                      onChanged: (val) => setState(() => _type = val!),
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    String? hint,
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
              hintText: hint,
              hintStyle: TextStyle(color: Theme.of(context).disabledColor),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
