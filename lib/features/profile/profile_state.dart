part of 'profile_cubit.dart';

sealed class ProfileState {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileSuccess extends ProfileState {
  const ProfileSuccess(this.userId);

  final String userId;
}

final class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message);

  final String message;
}