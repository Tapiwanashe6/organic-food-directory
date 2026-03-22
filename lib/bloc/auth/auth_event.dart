import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  const LoginEvent(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}

class GoogleLoginEvent extends AuthEvent {
  const GoogleLoginEvent();
}

class SignupEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const SignupEvent(this.name, this.email, this.password);
  @override
  List<Object> get props => [name, email, password];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthStateEvent extends AuthEvent {
  const CheckAuthStateEvent();
}