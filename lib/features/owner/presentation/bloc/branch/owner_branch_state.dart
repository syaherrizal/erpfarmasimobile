import 'package:equatable/equatable.dart';

abstract class OwnerBranchState extends Equatable {
  const OwnerBranchState();

  @override
  List<Object?> get props => [];
}

class OwnerBranchInitial extends OwnerBranchState {}

class OwnerBranchLoading extends OwnerBranchState {}

class OwnerBranchLoaded extends OwnerBranchState {
  final List<Map<String, dynamic>> branches;

  const OwnerBranchLoaded(this.branches);

  @override
  List<Object?> get props => [branches];
}

class OwnerBranchActionLoading extends OwnerBranchState {
  // Can be used when adding/updating to show loading overlay while keeping list visible
  // For simplicity, we might just reload or show global loader.
  // But let's keep it separate if we want granular UI updates.
  // Actually, standard pattern: emit Loading -> Loaded.
  // Or emit Loaded(isLoading: true).
  // Let's stick to Loading for full screen, or handle "Submitting" separately.
  // We'll trust the full refresh pattern for now.
}

class OwnerBranchSuccess extends OwnerBranchState {
  final String message;

  const OwnerBranchSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class OwnerBranchError extends OwnerBranchState {
  final String message;

  const OwnerBranchError(this.message);

  @override
  List<Object?> get props => [message];
}
