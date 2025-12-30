import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final String userId;
  const ProfileLoadRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class ProfileUpdateRequested extends ProfileEvent {
  final String userId;
  final Map<String, dynamic> data;

  const ProfileUpdateRequested(this.userId, this.data);

  @override
  List<Object> get props => [userId, data];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profile;
  final List<Map<String, dynamic>> sessions;

  const ProfileLoaded({required this.profile, required this.sessions});

  @override
  List<Object?> get props => [profile, sessions];

  ProfileLoaded copyWith({
    Map<String, dynamic>? profile,
    List<Map<String, dynamic>>? sessions,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      sessions: sessions ?? this.sessions,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc(this._repository) : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _repository.getProfile(event.userId);
      final sessions = await _repository.getLoginHistory(event.userId);

      if (profile == null) {
        emit(const ProfileError('Profile not found'));
        return;
      }

      emit(ProfileLoaded(profile: profile, sessions: sessions));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        await _repository.updateProfile(event.userId, event.data);
        // Refresh data
        add(ProfileLoadRequested(event.userId));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    }
  }
}
