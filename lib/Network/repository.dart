import 'dart:convert';

import 'package:demoproject/Models/AuthModel/registration_model.dart';
import 'package:demoproject/Models/AuthModel/user_list_model.dart';
import 'package:demoproject/Utils/constent.dart';

import '../Utils/api_end_point.dart';
import '../Utils/logger.dart';
import 'api_client.dart';
import 'custom_exception.dart';
import 'package:http/http.dart' as http;

class Repository {
  final ApiClient apiClient;

  Repository(this.apiClient);

  static Repository getInstance() {
    return Repository(ApiClient(httpClient: http.Client()));
  }

  /// login
  Future<RegistrationModel> login(Map<String, dynamic> body) async {
    try {
      logger.i('in repo');

      Map<String, dynamic> json = await apiClient.postApiCall(
        baseUrl: baseUrl,
        endPoint: loginEndpoint,
        postBody: body,
      );

      logger.i('api called');

      RegistrationModel loginModel = RegistrationModel.fromJson(json);

      logger.i('get response');
      return loginModel;
    } on CustomException {
      rethrow;
    }
  }

  /// registration

  Future<RegistrationModel> registration(Map<String, dynamic> body) async {
    try {
      logger.i('in repo');

      Map<String, dynamic> json = await apiClient.postApiCall(
        baseUrl: baseUrl,
        endPoint: registrationEndpoint,
        postBody: body,
      );

      logger.i('api called');

      RegistrationModel loginModel = RegistrationModel.fromJson(json);

      logger.i('get response');
      return loginModel;
    } on CustomException {
      rethrow;
    }
  }


  /// get all user list
  Future<UserListModel> getAllUserList() async {
    try {
      logger.i('in repo');

      Map<String, dynamic> json = await apiClient.getApiCall(
         baseUrl,
        getUserListEndpoint,
      isAccessToken: accessToken,
      );

      logger.i('api called');

      UserListModel loginModel = UserListModel.fromJson(json);

      logger.i('get response');
      return loginModel;
    } on CustomException {
      rethrow;
    }
  }
}
