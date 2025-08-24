part of 'auth_bloc.dart';

sealed class AuthEvent {}

class LoginEvent extends AuthEvent {
  final Map<String, dynamic> loginBody;
  LoginEvent(this.loginBody);
}

class RegistrationEvent extends AuthEvent {
  final Map<String, dynamic> regBody;
  RegistrationEvent(this.regBody);
}



class GetUserListEvent extends AuthEvent {

  GetUserListEvent();
}


