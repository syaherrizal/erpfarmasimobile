import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/repositories/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested(this.email, this.password);
}

class AuthGoogleLoginRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final Map<String, dynamic>? profile;
  const AuthAuthenticated(this.user, this.profile);
  @override
  List<Object?> get props => [user, profile];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Check current session
    // This part is tricky with Supabase 2.x which handles auth state via stream mostly.
    // For simplicity, we assume initial check logic here or use a listener in App.
    // But let's check current session.
    // Actually, best practice is to listen to stream. For this simplified Bloc, we will check current session user.
    // (In real app, we might subscribe to stream in main.dart or here)

    // For now, let's start with Unauthenticated to force login or use session restoration if available.
    // But since we are building, let's assume we want to restore session.
    // GetIt probably has the client.

    // Let's rely on Events from UI for now or impl initialization.
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.signInWithEmail(
        event.email,
        event.password,
      );
      if (response.user != null) {
        final profile = await _authRepository.getUserProfile(response.user!.id);
        emit(AuthAuthenticated(response.user!, profile));
      } else {
        emit(const AuthFailure('Login failed: No user returned'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.signInWithGoogle();
      if (response.user != null) {
        final profile = await _authRepository.getUserProfile(response.user!.id);
        emit(AuthAuthenticated(response.user!, profile));
      } else {
        emit(const AuthFailure('Google Login failed'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _authRepository.signOut();
    emit(AuthUnauthenticated());
  }
}
