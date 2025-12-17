part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final UserModel user;

  const AuthUserChanged(this.user);

  @override
  List<Object> get props => [user];
}
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthSignUpRequested(this.email, this.password, this.name);

  @override
  List<Object> get props => [email, password, name];
}

class AuthLogoutRequested extends AuthEvent {}
