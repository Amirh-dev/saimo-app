part of 'profile_cubit.dart';

sealed class ProfileState {
  const ProfileState();

  ProfileUser? get profile => null;

  bool get isLoading => false;
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {
  @override
  bool get isLoading => true;
}

final class ProfileSuccess extends ProfileState {
  const ProfileSuccess(
    this.user, {
    this.isRefreshing = false,
  });

  final ProfileUser user;
  final bool isRefreshing;

  String get userId => user.id;

  @override
  ProfileUser get profile => user;

  @override
  bool get isLoading => isRefreshing;
}

final class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message);

  final String message;
}
