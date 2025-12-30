import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erpfarmasimobile/core/di/injection.dart';
import 'package:erpfarmasimobile/features/owner/presentation/bloc/branch/owner_branch_cubit.dart';
import 'package:erpfarmasimobile/features/owner/presentation/bloc/branch/owner_branch_state.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/organization/organization_context_cubit.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/organization/organization_context_state.dart';
import 'package:erpfarmasimobile/features/owner/presentation/pages/branch/owner_branch_form_page.dart';

class OwnerBranchListPage extends StatelessWidget {
  const OwnerBranchListPage({super.key});

  @override
  Widget build(BuildContext context) {
    String? orgId;
    final orgState = context.read<OrganizationContextCubit>().state;
    if (orgState is OrganizationContextLoaded) {
      orgId = orgState.organizationId;
    }

    if (orgId == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Organization ID not found')),
      );
    }

    return BlocProvider(
      create: (_) => sl<OwnerBranchCubit>()..loadBranches(orgId!),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Daftar Cabang',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          backgroundColor: Theme.of(context).cardColor,
          foregroundColor: Theme.of(context).iconTheme.color,
          elevation: 0,
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (navContext) => OwnerBranchFormPage(
                      orgId: orgId!,
                      // Pass the CUBIT to the form so it can trigger refresh on success
                      cubit: context.read<OwnerBranchCubit>(),
                    ),
                  ),
                );
              },
              backgroundColor: Theme.of(context).primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah Cabang',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
        body: BlocConsumer<OwnerBranchCubit, OwnerBranchState>(
          listener: (context, state) {
            if (state is OwnerBranchSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is OwnerBranchError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is OwnerBranchLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OwnerBranchLoaded) {
              if (state.branches.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada cabang terdaftar.',
                        style: TextStyle(
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.branches.length,
                itemBuilder: (context, index) {
                  final branch = state.branches[index];
                  return _BranchCard(
                    branch: branch,
                    orgId: orgId!,
                    cubit: context.read<OwnerBranchCubit>(),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final Map<String, dynamic> branch;
  final String orgId;
  final OwnerBranchCubit cubit;

  const _BranchCard({
    required this.branch,
    required this.orgId,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final type = branch['type'] ?? 'outlet';
    final isWarehouse = type == 'warehouse';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OwnerBranchFormPage(
                orgId: orgId,
                branchData: branch,
                cubit: cubit,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isWarehouse
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                      : const Color(0xFF0F766E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isWarehouse ? Icons.warehouse : Icons.store,
                  color: isWarehouse
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF0F766E),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            branch['name'] ?? 'Tanpa Nama',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.titleMedium?.color,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            (type as String).toUpperCase(),
                            // This part is tricky because the original code had 'const'.
                            // Wait, I will use MultiReplace for BranchFormPage shortly.
                            // Let's do a more robust fix here.
                            // The error was on line 183 (approx) and maybe elsewhere.
                            // I'll just remove 'const' from the widget creation if possible or specific lines.
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .grey
                                  .shade700, // I should update this too
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      branch['address'] ?? 'Alamat belum diatur',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (branch['phone'] != null &&
                        (branch['phone'] as String).isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            branch['phone'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
