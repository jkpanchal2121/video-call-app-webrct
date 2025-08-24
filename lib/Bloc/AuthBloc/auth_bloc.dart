import 'package:bloc/bloc.dart';
import 'package:demoproject/Models/AuthModel/registration_model.dart';
import 'package:demoproject/Models/AuthModel/user_list_model.dart';
import 'package:demoproject/Network/repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../../Network/custom_exception.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  Repository repository;
  AuthBloc(this.repository) : super(AuthInitial()) {
    on<LoginEvent>(_login);
    on<RegistrationEvent>(_registration);
    on<GetUserListEvent>(_getAllUserList);
  }

  Future<void> _login(LoginEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(loginStatus: RequestStatus.loading));
    try {
      final RegistrationModel registrationModelData = await repository.login(
        event.loginBody,
      );

      emit(
        state.copyWith(
          loginStatus: RequestStatus.success,
          registrationModelData: registrationModelData,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loginStatus: RequestStatus.failure));
      _handleError(e, emit);
    }
  }

  Future<void> _registration(
    RegistrationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(regStatus: RequestStatus.loading));
    try {
      final RegistrationModel registrationModelData = await repository.registration(
        event.regBody,
      );

      emit(
        state.copyWith(
          regStatus: RequestStatus.success,
          registrationModelData: registrationModelData,
        ),
      );
    } catch (e) {
      emit(state.copyWith(regStatus: RequestStatus.failure));
      _handleError(e, emit);
    }
  }

  Future<void> _getAllUserList(
    GetUserListEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(loginStatus: RequestStatus.loading));
    try {
      final UserListModel userListModelData = await repository.getAllUserList();

      emit(
        state.copyWith(
          userListStatus: RequestStatus.success,
          userListModelData: userListModelData,
        ),
      );
    } catch (e) {
      emit(state.copyWith(userListStatus: RequestStatus.failure));
      _handleError(e, emit);
    }
  }

  void _handleError(dynamic error, Emitter<AuthState> emit) {
    int statusCode = 500;
    String message = error.toString();

    if (error is FetchDataException) {
      statusCode = 500;
    } else if (error is UnAuthorizedException) {
      statusCode = 401;
    } else if (error is DoesNotExistException) {
      statusCode = 404;
    } else if (error is ServerValidationError) {
      statusCode = 400;
    } else if (error is ServerValidationError) {
      statusCode = 503;
    } else {
      statusCode = 500;
    }

    emit(state.copyWith(statusCode: statusCode, errorMessage: message));
  }
}
