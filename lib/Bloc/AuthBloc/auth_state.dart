part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final RequestStatus loginStatus;
  final RequestStatus regStatus;
  final RequestStatus userListStatus;
  final RegistrationModel? registrationModelData;
  final UserListModel? userListModelData;
  final int? statusCode;
  final String? errorMessage;

  const AuthState({
    this.loginStatus = RequestStatus.initial,
    this.regStatus = RequestStatus.initial,
    this.userListStatus = RequestStatus.initial,
    this.registrationModelData,
    this.userListModelData,
    this.statusCode,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    loginStatus,
    regStatus,
    registrationModelData,
    userListStatus,
    userListModelData,
    statusCode,
    errorMessage,
  ];

  AuthState copyWith({
    RequestStatus? loginStatus,
    RequestStatus? regStatus,
    RegistrationModel? registrationModelData,
    RequestStatus? userListStatus,
    UserListModel? userListModelData,

    int? statusCode,
    String? errorMessage,
  }) {
    return AuthState(
      registrationModelData:
          registrationModelData ?? this.registrationModelData,
      loginStatus: loginStatus ?? this.loginStatus,
      regStatus: regStatus ?? this.regStatus,
      userListModelData: userListModelData ?? this.userListModelData,
      userListStatus: userListStatus ?? this.userListStatus,

      statusCode: statusCode,
      errorMessage: errorMessage,
    );
  }
}

enum RequestStatus { initial, loading, success, failure }

final class AuthInitial extends AuthState {}
