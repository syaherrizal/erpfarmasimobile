import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/repositories/owner_repository.dart';

// Events
abstract class OwnerEvent extends Equatable {
  const OwnerEvent();
  @override
  List<Object?> get props => [];
}

class OwnerDashboardDataRequested extends OwnerEvent {
  final String organizationId;
  const OwnerDashboardDataRequested(this.organizationId);
  @override
  List<Object?> get props => [organizationId];
}

// States
abstract class OwnerState extends Equatable {
  const OwnerState();
  @override
  List<Object?> get props => [];
}

class OwnerInitial extends OwnerState {}

class OwnerLoading extends OwnerState {}

class OwnerLoaded extends OwnerState {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> recentTransactions;

  const OwnerLoaded({required this.stats, required this.recentTransactions});

  @override
  List<Object?> get props => [stats, recentTransactions];
}

class OwnerError extends OwnerState {
  final String message;
  const OwnerError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class OwnerBloc extends Bloc<OwnerEvent, OwnerState> {
  final OwnerRepository _repository;

  OwnerBloc(this._repository) : super(OwnerInitial()) {
    on<OwnerDashboardDataRequested>(_onDashboardDataRequested);
  }

  Future<void> _onDashboardDataRequested(
    OwnerDashboardDataRequested event,
    Emitter<OwnerState> emit,
  ) async {
    emit(OwnerLoading());

    final statsResult = await _repository.getDashboardStats(
      event.organizationId,
    );
    final transactionsResult = await _repository.getRecentTransactions(
      event.organizationId,
    );

    statsResult.fold((failure) => emit(OwnerError(failure.message)), (stats) {
      transactionsResult.fold(
        (failure) => emit(OwnerError(failure.message)),
        (transactions) =>
            emit(OwnerLoaded(stats: stats, recentTransactions: transactions)),
      );
    });
  }
}
