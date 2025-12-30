import 'package:equatable/equatable.dart';

abstract class OwnerOrganizationState extends Equatable {
  const OwnerOrganizationState();

  @override
  List<Object?> get props => [];
}

class OwnerOrganizationInitial extends OwnerOrganizationState {}

class OwnerOrganizationLoading extends OwnerOrganizationState {}

class OwnerOrganizationLoaded extends OwnerOrganizationState {
  final Map<String, dynamic> organization;

  const OwnerOrganizationLoaded(this.organization);

  @override
  List<Object?> get props => [organization];
}

class OwnerOrganizationUpdating extends OwnerOrganizationState {}

class OwnerOrganizationSuccess extends OwnerOrganizationState {
  final String message;

  const OwnerOrganizationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class OwnerOrganizationError extends OwnerOrganizationState {
  final String message;

  const OwnerOrganizationError(this.message);

  @override
  List<Object?> get props => [message];
}
