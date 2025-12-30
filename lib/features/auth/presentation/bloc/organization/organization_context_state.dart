import 'package:equatable/equatable.dart';

abstract class OrganizationContextState extends Equatable {
  const OrganizationContextState();

  @override
  List<Object?> get props => [];
}

class OrganizationContextInitial extends OrganizationContextState {}

class OrganizationContextLoading extends OrganizationContextState {}

class OrganizationContextLoaded extends OrganizationContextState {
  final String organizationId;
  final String organizationName;
  final String? organizationLogo;
  final Map<String, dynamic> organizationData;

  const OrganizationContextLoaded({
    required this.organizationId,
    required this.organizationName,
    this.organizationLogo,
    required this.organizationData,
  });

  @override
  List<Object?> get props => [
    organizationId,
    organizationName,
    organizationLogo,
    organizationData,
  ];
}

class OrganizationContextError extends OrganizationContextState {
  final String message;

  const OrganizationContextError(this.message);

  @override
  List<Object?> get props => [message];
}
