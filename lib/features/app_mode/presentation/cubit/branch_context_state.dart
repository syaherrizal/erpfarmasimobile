part of 'branch_context_cubit.dart';

abstract class BranchContextState extends Equatable {
  const BranchContextState();

  @override
  List<Object?> get props => [];
}

class BranchContextInitial extends BranchContextState {}

class BranchContextLoading extends BranchContextState {}

class BranchContextLoaded extends BranchContextState {
  final List<Map<String, dynamic>> memberships;
  final String selectedBranchId;
  final String selectedBranchName;
  final String organizationId;
  final bool isSelectionRequired;

  const BranchContextLoaded({
    required this.memberships,
    required this.selectedBranchId,
    required this.selectedBranchName,
    required this.organizationId,
    this.isSelectionRequired = false,
  });

  BranchContextLoaded copyWith({
    List<Map<String, dynamic>>? memberships,
    String? selectedBranchId,
    String? selectedBranchName,
    String? organizationId,
    bool? isSelectionRequired,
  }) {
    return BranchContextLoaded(
      memberships: memberships ?? this.memberships,
      selectedBranchId: selectedBranchId ?? this.selectedBranchId,
      selectedBranchName: selectedBranchName ?? this.selectedBranchName,
      organizationId: organizationId ?? this.organizationId,
      isSelectionRequired: isSelectionRequired ?? this.isSelectionRequired,
    );
  }

  @override
  List<Object?> get props => [
    memberships,
    selectedBranchId,
    selectedBranchName,
    organizationId,
    isSelectionRequired,
  ];
}

class BranchContextError extends BranchContextState {
  final String message;

  const BranchContextError(this.message);

  @override
  List<Object?> get props => [message];
}
