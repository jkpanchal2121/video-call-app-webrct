import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../Utils/api_end_point.dart';
import '../Utils/logger.dart';
import 'custom_exception.dart';


class ApiClient {
  http.Client? httpClient;

//  ApiClient({this.httpClient});
  ApiClient({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  /////
  ///
  /// POST APIS
  ///
  /// POST API CALL: SENDING LOGIN DATA REQUEST TO SERVER.
  ///
  ///
  ///
  Future<dynamic> postApiCall({
    required String baseUrl,
    required String endPoint,
    required Map postBody,
    String? isAccessToken,
  }) async {
    dynamic postResponseJson;
    var getUrl = '$baseUrl$endPoint';

    // Always include headers
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    if (isAccessToken != null &&
        isAccessToken.isNotEmpty &&
        isAccessToken != "null") {
      headers["Authorization"] = "Bearer $isAccessToken";
    }

    logger.i(getUrl);
    logger.i("Headers: $headers");
    logger.i("Body: ${jsonEncode(postBody)}");

    try {
      var response = await httpClient!.post(
        Uri.parse(getUrl),
        headers: headers,
        body: jsonEncode(postBody), // ✅ Encode body to JSON
      );

      postResponseJson = await _parsePostResponse(response);
    } on SocketException {
      throw FetchDataException("No internet Connection");
    }

    return postResponseJson;
  }

  // Future<dynamic> postSecureApiCall({
  //   required String baseUrl,
  //   required String endpoint,
  //   required Map<String, dynamic> body,
  //   String? accessToken,
  // }) async
  // {
  //   final Uri url = Uri.parse('$baseUrl$endpoint');
  //
  //   final headers = <String, String>{
  //
  //     'Accept': 'application/json',
  //     if (accessToken != null && accessToken.isNotEmpty && accessToken != 'null')
  //       'Authorization': 'Bearer $accessToken',
  //     'X-Content-Encrypted': 'AES-256-CBC',
  //   };
  //
  //   // Encrypt request body → Base64
  //   final String cipherB64 = EncryptData.encryptAES(body);
  //
  //   final decryptData = EncryptData.decryptAES('7T7EOTx/EEY7CK3lWU42HqFgfjCvxfSi3KprlorMNQ0ww571vbZlvRc9uSt4waxI645uUoCuJaooZF1nejb7fjt4jjF3it8VhjckGAQMh8Ql75k5EDLlCm/lSsUunLWQbQOljoXjcg88YxaFmi7iKovHH5sMifM1xkxI5Urn0Z6+YKhDbfamomq/3kD7IlKeovcALmu3Tmb1wCACUCXy0NGRVhSVo95Chri8J42xmSC9ze+UU+V9G50kFMEB2YSjYsb+mcduoBIOwsDUn3KC4kD9UnJM12188ozRWYUIPZGLHGhcfdNhAQps5VtDazOFJpAdoQmvpDme7Wesgq+V36d3AqgaUHkfsx0n5n3OzPkxlphlopyzPVLgKFRC0/0FIs6oL46nqOF9h/5UsRC9Ojqo4t11lxQF0sbWxckpUnBcnwTjKQcQNprcSdZWUBbj4cox6uXAN+JA5ODbc+J4HbsVtYP+l3xH3yj8vJkFiBsfn8QjuTw5Ju2XkYsbtUXc');
  //
  //
  //   final dataBody = {};
  //
  //   dataBody['login_encryption']  = cipherB64;
  //
  //   logger.i('POST $url');
  //   logger.i('Headers: $headers');
  //   logger.i('Encrypted body length: ${cipherB64}');
  //   logger.i('dataBody: ${dataBody}');
  //   logger.i('decryptData: ${decryptData}');
  //
  //   http.Response response;
  //   try {
  //     response = await httpClient!.post(url, headers: headers, body: dataBody);
  //   } on SocketException {
  //     throw const SocketException('No internet connection');
  //   }
  //
  //   logger.i('Status ${response.statusCode}');
  //   logger.i('Raw response body: ${response.body}');
  //
  //   if (response.statusCode != 200) {
  //     throw HttpException(
  //       'HTTP ${response.statusCode}: ${response.reasonPhrase}',
  //       uri: url,
  //     );
  //   }
  //
  //   // Response body is also just a JSON‑encoded Base64 string
  //   final String responseCipherB64 = jsonDecode(response.body);
  //
  //
  //   logger.i('Decrypted response: $responseCipherB64');
  //   return responseCipherB64;
  // }

  Future<dynamic> postAPICallsWithBody(
    String endPoint,
    dynamic postBody,
  ) async {
    dynamic postResponseJson;
    String postUrl;

    Map<String, String>? headers;

    postUrl = "$baseUrl$endPoint";

    var encodedBody = json.encode(postBody);
    headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
    };

    logger.i("post url: $postUrl, headers: $headers, body: $encodedBody");

    try {
      var response = await httpClient?.post(Uri.parse(postUrl),
          headers: headers, body: encodedBody);
      postResponseJson = await _parsePostResponse(response!);
    } on SocketException {
      throw FetchDataException("No internet connections.");
    }

    return postResponseJson;
  }

  ///
  /// MultipartRequest APIS
  ///
  /// POST API CALL: SENDING LOGIN DATA REQUEST TO SERVER.
  ///
  ///
  Future<dynamic> apiCallBasicPost({
    required String baseUrl,
    File? selectedImage,
    String? imageUrl,
  }) async {
    final Uri getUrl = Uri.parse(baseUrl);
    logger.i("postUrl $getUrl");

    final request = http.MultipartRequest('POST', getUrl);

    if (selectedImage != null) {
      // Add file with field name "image"
      request.files.add(await http.MultipartFile.fromPath(
        "image",
        selectedImage.path,
        contentType: MediaType('image', 'jpg'),
      ));
      logger.i('Attached File: ${selectedImage.path}');
    } else if (imageUrl != null) {
      // Clean the URL by removing unwanted characters like parentheses
      final cleanedUrl = imageUrl.replaceAll(RegExp(r'[()]'), '').trim();
      request.fields['image_url'] = cleanedUrl;
      logger.i('Attached Image URL: $cleanedUrl');
    } else {
      throw ArgumentError('Either selectedImage or imageUrl must be provided.');
    }

    logger.i('Request Fields: ${request.fields}');
    logger.i('Request Files: ${request.files}');

    try {
      final response = await request.send();

      // Parse response
      final responseBody = await http.Response.fromStream(response);
      logger.i("Response Body: ${responseBody.body}");

      final Map<String, dynamic> data = jsonDecode(responseBody.body);
      logger.i("Response: $data");
      logger.i("Request Info: ${response.request}");
      logger.i("Status Code: ${response.statusCode}");

      // Handle response
      return _handleResponse(response.statusCode, data);
    } catch (e) {
      logger.i('Error: $e');
      rethrow;
    }
  }

// Example response handler (you can customize this based on your API)

// Private helper to handle response codes
  dynamic _handleResponse(int statusCode, Map<String, dynamic> data) {
    switch (statusCode) {
      case 200:
        return data;

      case 401:
        throw UnAuthorizedException(data["message"]);

      case 404:
        throw DoesNotExistException(data["message"]);

      case 400:
        throw ServerValidationError(data["message"]);

      case 403:
        throw ServerValidationError(data["message"]);

      case 500:
      case 503:
        throw underMaintenanceError(
            data["message"] ?? 'Service is currently unavailable.');

      default:
        throw Exception(data["message"] ?? "Something went wrong");
    }
  }

  Future<dynamic> getApiCall(String baseUrl, String endPoint,
      {String query = "", String? isAccessToken, dynamic bodyForGetApi}) async {
    var getResponseJson;
    var getUrl;

    Map<String, String>? headers;

    if (query.isNotEmpty) {
      getUrl = "$baseUrl$endPoint?$query";
    } else {
      getUrl = "$baseUrl$endPoint";
    }

    if (isAccessToken != null) {
      logger.i("get with token");
      headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer ${isAccessToken}",
      };
    } else {
      logger.i("get without token");
      headers = {"Accept": "application/json"};
    }

    logger.i("url $getUrl, headers: $headers");

    try {
      var response = await httpClient?.get(Uri.parse(getUrl), headers: headers);
      getResponseJson = await _parseGetResponse(response!);
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    }

    return getResponseJson;
  }

  /// HERE, CONVERTING HTTP RESPONSE TO JSON.
  Future<dynamic> _parseGetResponse(http.Response response) async {
    logger.i("GET API RESPONSE: ${response.body}");
    logger.i("request Status: ${response.statusCode}");

    switch (response.statusCode) {
      case 200:
        var getResponseJson = json.decode(response.body);
        return getResponseJson;

      case 401:
        // throw UnAuthorizedException("Unautorized Acces s or Invalid Credentials");
        var postResponseJson = json.decode(response.body);
        logger.i("message:  ${postResponseJson["message"]}");
        throw UnAuthorizedException(postResponseJson["message"]);

      case 404:
        var postResponseJson = json.decode(response.body);
        throw DoesNotExistException(postResponseJson["message"]);

      case 400:
        var postResponseJson = json.decode(response.body);
        throw ServerValidationError(postResponseJson["message"]);

      default:
        throw Exception("Something went Wrong");
    }
  }

  Future<dynamic> getApiCallWithToken(
    String baseUrl,
    String endPoint, {
    String query = "",
    String? isAccessToken,
    dynamic bodyForGetApi,
  }) async {
    dynamic getResponseJson;
    String getUrl;

    // Set headers based on token availability
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (isAccessToken != null) "Authorization": isAccessToken,
    };

    // Construct the full URL with or without query parameters
    getUrl =
        query.isNotEmpty ? "$baseUrl$endPoint?$query" : "$baseUrl$endPoint";

    logger.i("url: $getUrl, headers: $headers");
    logger.i("Request start time: ${DateTime.now()}");

    try {
      // Make the GET request
      var response = await httpClient?.get(Uri.parse(getUrl), headers: headers);

      // Parse the response
      getResponseJson = await _parseGetResponseWithToken(response!);
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    }

    logger.i("Request end time: ${DateTime.now()}");
    return getResponseJson;
  }

  Future<dynamic> _parseGetResponseWithToken(http.Response response) async {
    // Log response details for debugging
    logger.i("GET API RESPONSE: ${response.body}");
    logger.i("Request Status: ${response.statusCode}");

    switch (response.statusCode) {
      case 200:
        // Successful response
        return json.decode(response.body);

      case 401:
        // Unauthorized access
        var responseJson = json.decode(response.body);
        logger.i("Message: ${responseJson["message"]}");
        throw UnAuthorizedException(responseJson["message"]);

      case 404:
        // Resource not found
        var responseJson = json.decode(response.body);
        throw DoesNotExistException(responseJson["message"]);

      case 400:
        // Bad request with validation error
        var responseJson = json.decode(response.body);
        throw ServerValidationError(responseJson["message"]);

      case 500:
        // Internal server error
        var responseJson = json.decode(response.body);
        throw ServerValidationError(responseJson["message"]);

      default:
        // Unhandled status code
        throw Exception("Something went wrong");
    }
  }

  Future<dynamic> putApiCall(String baseUrl, String endPoint,
      {String query = "", String? isAccessToken, dynamic bodyForGetApi}) async {
    var putResponseJson;
    var putUrl;

    Map<String, String>? headers;

    if (query.isNotEmpty) {
      putUrl = "$baseUrl$endPoint?$query";
    } else {
      putUrl = "$baseUrl$endPoint";
    }

    if (isAccessToken != null) {
      logger.i("get with token");
      headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": isAccessToken,
      };
    } else {
      logger.i("get without token");
      headers = {"Accept": "application/json"};
    }

    logger.i("url $putUrl, headers: $headers, body: ${bodyForGetApi}");

    try {
      var response = await httpClient?.put(Uri.parse(putUrl),
          headers: headers, body: jsonEncode(bodyForGetApi));
      putResponseJson = await _parsePutResponse(response!);
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    }

    return putResponseJson;
  }

  Future<dynamic> apiCallMultipartPostImageUpload(
    String baseUrl,
    String apiEndPoint,
    List<File> files,
    String productId,
  ) async {
    var getUrl;

    getUrl = Uri.parse('$baseUrl$apiEndPoint');
    logger.i("postUrl $getUrl");

    var request = http.MultipartRequest('POST', getUrl);

    // final token =
    // (await SharedPreferences.getInstance()).getString('accessToken');
    //
    // final headers = {
    //   "key": 'laundryapikey',
    //   if (token != null) 'Authorization': token,
    // };

    // final headers = {
    //   "key": 'laundryapikey',
    //   if (marketPlaceUserAccessToken != null) 'Authorization': '${marketPlaceUserAccessToken}',
    // };

    // request.headers.addAll(headers);
    request.fields['productId'] = productId;
    for (int i = 0; i < files.length; i++) {
      request.files.add(await http.MultipartFile.fromPath(
          "image", files[i].path,
          contentType: MediaType('image', 'jpg')));
    }
    var response = await request.send();

    var stringResponse = await response.stream.bytesToString();
    logger.i("string response ${stringResponse}");
    logger.i(response.request);
    logger.i(response.statusCode);
    switch (response.statusCode) {
      case 200:
        var postResponseJson = json.decode(stringResponse);
        return postResponseJson;

      case 401:
        var postResponseJson = json.decode(stringResponse);

        logger.i("message:  ${postResponseJson["message"]}");
        throw UnAuthorizedException(postResponseJson["message"]);

      case 404:
        var postResponseJson = json.decode(stringResponse);

        logger.i("message:  ${postResponseJson["message"]}");
        throw DoesNotExistException(postResponseJson["message"]);

      case 400:
        var postResponseJson = json.decode(stringResponse);

        logger.i("message:  ${postResponseJson["message"]}");
        throw ServerValidationError(postResponseJson['message']);

      case 403:
        var postResponseJson = json.decode(stringResponse);

        logger.i("message:  ${postResponseJson["message"]}");
        throw ServerValidationError(postResponseJson["message"]);

      case 500:
        var postResponseJson = json.decode(stringResponse);

        logger.i("message:  ${postResponseJson["message"]}");
        throw underMaintenanceError(postResponseJson["message"] == null
            ? ' '
            : postResponseJson["message"]);

      case 503:
        var postResponseJson = json.decode(stringResponse);

        logger.i("message:  ${postResponseJson["message"]}");
        throw underMaintenanceError(postResponseJson["message"] == null
            ? ' '
            : postResponseJson["message"]);

      default:
        var postResponseJson = json.decode(stringResponse);

        logger.i("message:  ${postResponseJson["message"]}");
        // throw Exception("Something went Wrong");
        throw Exception(postResponseJson["message"]);
    }
  }

  Future<dynamic> _parsePutResponse(http.Response response) async {
    // logger.i("GET API RESPONSE: ${response.body}");
    // logger.i("request Status: ${response.statusCode}");

    switch (response.statusCode) {
      case 200:
        var getResponseJson = json.decode(response.body);
        return getResponseJson;

      case 401:
        // throw UnAuthorizedException("Unautorized Acces s or Invalid Credentials");
        var postResponseJson = json.decode(response.body);
        logger.i("message:  ${postResponseJson["message"]}");
        throw UnAuthorizedException(postResponseJson["message"]);

      case 404:
        var postResponseJson = json.decode(response.body);
        throw DoesNotExistException(postResponseJson["message"]);

      case 400:
        var postResponseJson = json.decode(response.body);
        throw ServerValidationError(postResponseJson["message"]);

      default:
        throw Exception("Something went Wrong");
    }
  }

  Future<dynamic> postApiCallWithToken(
    String baseUrl,
    String endPoint,
    dynamic postBody, {
    String? isAccessToken,
    String? fireBaseTokenWhenBothNeeded,
    bool? isGetFirebaseToken,
    bool? isAppUserToken,
  }) async {
    dynamic postResponseJson;
    final String getUrl = '$baseUrl$endPoint';

    // logger.i URL and body for debugging
    logger.i("POST URL: $getUrl");
    logger.i("POST Body: $postBody");

    // Encode the body for JSON format
    final String encodedBody = json.encode(postBody);

    // Define headers based on token conditions
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (isAppUserToken == true && isGetFirebaseToken == true) ...{
        "Authorization": isAccessToken!,
        "firebase": fireBaseTokenWhenBothNeeded!,
      } else if (isGetFirebaseToken == true) ...{
        "firebase": isAccessToken!,
      } else if (isAccessToken != null) ...{
        "Authorization": isAccessToken,
      },
    };

    logger.i("Headers: $headers");
    logger.i("Request Start Time: ${DateTime.now()}");

    try {
      // Make the POST request
      final response = await httpClient?.post(
        Uri.parse(getUrl),
        headers: headers,
        body: encodedBody,
      );

      // Ensure response is not null before parsing
      if (response != null) {
        postResponseJson = await _parsePostResponseWithToken(response);
      } else {
        throw FetchDataException("Failed to fetch response.");
      }
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    }

    // Debugging output for request completion time
    logger.i("Request End Time: ${DateTime.now()}");

    return postResponseJson;
  }

  Future<dynamic> _parsePostResponseWithToken(http.Response response) async {
    // Log response details for debugging
    logger.i("Post API Response: ${response.body}");
    logger.i("Post status: ${response.statusCode}");

    switch (response.statusCode) {
      case 200:
        // Successful response
        return json.decode(response.body);

      case 401:
        // Unauthorized access
        var responseJson = json.decode(response.body);
        logger.i("Message: ${responseJson["message"]}");
        throw UnAuthorizedException(responseJson["message"]);

      case 404:
        // Resource not found
        var responseJson = json.decode(response.body);
        logger.i("Message: ${responseJson["message"]}");
        throw DoesNotExistException(responseJson["message"]);

      case 400:
        // Bad request with validation error
        var responseJson = json.decode(response.body);
        logger.i("Message: ${responseJson["message"]}");
        throw ServerValidationError(responseJson['message']);

      case 403:
        // Forbidden access
        var responseJson = json.decode(response.body);
        logger.i("Message: ${responseJson["message"]}");
        throw ServerValidationError(responseJson["message"]);

      case 500:
        // Internal server error
        var responseJson = json.decode(response.body);
        throw ServerValidationError(responseJson["message"]);

      default:
        // Unhandled status code
        var responseJson = json.decode(response.body);
        logger.i("Message: ${responseJson["message"]}");
        throw Exception(responseJson["message"]);
    }
  }

  ///
  /// POST API CALL: FOR MULZTIPART
  ///
  Future<dynamic> multipartPostApiCall(
    String baseUrl,
    String endPoint, {
    String? isAccessToken,
    String? isFireBaseToken,
    String? fileKey,
    Map<String, dynamic>? fields,
    // Map<String, File>? files,
  }) async {
    var getUrl = '$baseUrl$endPoint';
    var request = http.MultipartRequest('POST', Uri.parse(getUrl));

    Map<String, String>? headers;

    if (isAccessToken != null) {
      headers = {
        // "Accept": "application/json",
        "Authorization": isAccessToken,
        "Content-Type": "application/json",
      };
    } else if (isFireBaseToken != null) {
      headers = {
        // "Accept": "application/json",
        "firebase": isFireBaseToken,
      };
    } else {
      headers = {};
      // headers = {"Accept": "application/json"};
    }

    request.headers.addAll(headers);

    // Add form fields if provided
    if (fields != null) {
      fields.forEach((key, value) async {
        if (key == (fileKey ?? "productImage") && fields[key] is List<File>) {
          log(value.runtimeType.toString());
          log(value.toString());

          List<File> attachments = fields[key];

          logger.i('attachments>>>${attachments}');

          for (var entry in attachments) {
            // log(entry);

            // String? mimeType = lookupMimeType(entry.path);
            // var contentType = mimeType != null ? MediaType('image', mimeType) : null;

            String fileExtension = entry.path.split('.').last.toLowerCase();
            MediaType contentType;

            // Check for image type
            if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(fileExtension)) {
              contentType = MediaType('image', fileExtension);
            }
            // Check for video type
            else if (['mp4', 'mov', 'avi', 'mkv', 'flv']
                .contains(fileExtension)) {
              contentType = MediaType('video', fileExtension);
            } else {
              continue; // Skip unsupported files
            }

            request.files.add(await http.MultipartFile.fromPath(key, entry.path,
                contentType: contentType));
          }
        } else if (key == (fileKey ?? "productImage")) {
          String fileExtension = fields[key].path.split('.').last.toLowerCase();
          MediaType contentType;

          // Check for image type
          if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(fileExtension)) {
            contentType = MediaType('image', fileExtension);
            request.files.add(await http.MultipartFile.fromPath(
                key, fields[key].path,
                contentType: contentType));
          }
          // Check for video type
          else if (['mp4', 'mov', 'avi', 'mkv', 'flv']
              .contains(fileExtension)) {
            contentType = MediaType('video', fileExtension);
            request.files.add(await http.MultipartFile.fromPath(
                key, fields[key].path,
                contentType: contentType));
          }
        } else {
          request.fields[key] = value;
        }
      });
    }

    // // Add files if provided
    // if (files != null) {
    //   for (var entry in files.entries) {
    //     request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value.path));
    //   }
    // }

    logger.i("Multipart POST URL: $getUrl");
    logger.i("Headers: $headers");
    logger.i("Fields: $fields");
    logger.i("Request: $request");
    // logger.i("Files: ${files?.keys}");

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return _parsePostResponseWithToken(
          response); // Use your existing response handler
    } on SocketException {
      throw FetchDataException("No internet connection");
    }
    // catch (e) {
    //   logger.i("Error: $e");
    //   throw Exception("Error during multipart POST request");
    // }
  }

  Future<dynamic> multipartListFilePostApiCall(
    String baseUrl,
    String endPoint, {
    String? isAccessToken,
    String? isFireBaseToken,
    String? fileKey,
    Map<String, String>? fields,
    List<File>? files,
  }) async {
    var getUrl = '$baseUrl$endPoint';
    var request = http.MultipartRequest('POST', Uri.parse(getUrl));

    Map<String, String>? headers;

    if (isAccessToken != null) {
      headers = {
        // "Accept": "application/json",
        "Authorization": isAccessToken,
        "Content-Type": "application/json",
      };
    } else if (isFireBaseToken != null) {
      headers = {
        // "Accept": "application/json",
        "firebase": isFireBaseToken,
      };
    } else {
      headers = {};
      // headers = {"Accept": "application/json"};
    }

    request.headers.addAll(headers);

    // Add form fields if provided
    if (fields != null) {
      request.fields.addAll(fields);
    }

    for (File entry in (files ?? [])) {
      // log(entry);

      // String? mimeType = lookupMimeType(entry.path);
      // var contentType = mimeType != null ? MediaType('image', mimeType) : null;

      String fileExtension = entry.path.split('.').last.toLowerCase();
      MediaType contentType;

      // Check for image type
      if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(fileExtension)) {
        contentType = MediaType('image', fileExtension);
      }
      // Check for video type
      else if (['mp4', 'mov', 'avi', 'mkv', 'flv'].contains(fileExtension)) {
        contentType = MediaType('video', fileExtension);
      } else {
        continue; // Skip unsupported files
      }

      request.files.add(await http.MultipartFile.fromPath(
          fileKey ?? "image", entry.path,
          contentType: contentType));
    }

    logger.i("Multipart POST URL: $getUrl");
    logger.i("Headers: $headers");
    logger.i("Fields: $fields");
    logger.i("Request: $request");
    // logger.i("Files: ${files?.keys}");

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return _parsePostResponseWithToken(
          response); // Use your existing response handler
    } on SocketException {
      throw FetchDataException("No internet connection");
    }
    // catch (e) {
    //   logger.i("Error: $e");
    //   throw Exception("Error during multipart POST request");
    // }
  }

  ///
  /// MultipartRequest APIS
  ///
  /// POST API CALL: SENDING LOGIN DATA REQUEST TO SERVER.
  ///
  ///
  Future<dynamic> apiCallMultipartPost({
    required String baseUrl,
    required String apiEndPoint,
    File? selectedFile, // Nullable: this API doesn't need a file
    Map<String, dynamic>? postBody, // Pass your fields here
    String? token,
    bool isAudio = false,
  }) async {
    final uri = Uri.parse('$baseUrl$apiEndPoint');
    logger.i("Request URL: $uri");

    final request = http.MultipartRequest('POST', uri);

    // Add headers
    request.headers.addAll({
      "Authorization": 'Bearer $token',
      "Accept": "application/json",
      "Content-Type": "application/json",
    });

    // Add body fields
    if (postBody != null) {
      postBody.forEach((key, value) {
        request.fields[key] = value.toString();
      });
    }

    // Optional: Add file if provided
    if (selectedFile != null) {
      final fileField = isAudio ? "audio" : "image";
      final mimeType = isAudio ? 'audio/mpeg' : 'image/jpeg';

      request.files.add(await http.MultipartFile.fromPath(
        fileField,
        selectedFile.path,
        contentType: MediaType.parse(mimeType),
      ));
    }

    logger.i("Sending request with fields: ${request.fields}");
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    logger.i("Response: $responseBody");

    switch (response.statusCode) {
      case 200:
        return json.decode(responseBody);
      case 401:
        throw UnAuthorizedException(json.decode(responseBody)['message']);
      case 404:
        throw DoesNotExistException(json.decode(responseBody)['message']);
      case 400:
      case 403:
        throw ServerValidationError(json.decode(responseBody)['message']);
      case 500:
      case 503:
        throw underMaintenanceError(
            json.decode(responseBody)['message'] ?? 'Server error');
      default:
        throw Exception(
            json.decode(responseBody)['message'] ?? 'Unexpected error');
    }
  }

  //////
  ///
  /// POST API CALL: SENDING LOGIN DATA REQUEST TO SERVER.
  ///
  Future<dynamic> _parsePostResponse(http.Response response) async {
    log("Post Api Response: ${response.body}");
    logger.i("post status: ${response.statusCode}");

    switch (response.statusCode) {
      case 200:
        var data = response.body;
        var postResponseJson = json.decode(data);
        return postResponseJson;

      case 401:
        var data = response.body;
        var postResponseJson = json.decode(data);
        log("message:  ${postResponseJson["message"]}");
        throw UnAuthorizedException(postResponseJson["message"]);

      case 404:
        log("here");
        var data = response.body;
        var postResponseJson = json.decode(data);
        log("message:  ${postResponseJson["message"]}");
        throw DoesNotExistException(postResponseJson["message"]);

      case 400:
        var data = response.body;
        var postResponseJson = json.decode(data);
        log("message:  ${postResponseJson["message"]}");
        throw ServerValidationError(postResponseJson['message']);

      case 403:
        var data = response.body;
        var postResponseJson = json.decode(data);
        log("message:  ${postResponseJson["message"]}");
        throw ServerValidationError(postResponseJson["message"]);

      case 500:
        // throw underMaintenanceError('Application Under Maintenance');
        var data = response.body;
        var postResponseJson = json.decode(data);
        log("message:  ${postResponseJson["message"]}");
        throw underMaintenanceError(postResponseJson["message"] == null
            ? ' '
            : postResponseJson["message"]);

      case 503:
        // throw underMaintenanceError('Application Under Maintenance');
        var data = response.body;
        var postResponseJson = json.decode(data);
        log("message:  ${postResponseJson["message"]}");
        throw underMaintenanceError(postResponseJson["message"] == null
            ? ' '
            : postResponseJson["message"]);

      default:
        var data = response.body;
        var postResponseJson = json.decode(data);
        log("message:  ${postResponseJson["message"]}");
        // throw Exception("Something went Wrong");
        throw Exception(postResponseJson["message"]);
    }
  }

  /////
  ///
  /// GET APIS WITH ACCES TOKEN
  ///
  /// GET API CALL: SENDING DATA REQUEST TO SERVER.
  ///
  Future<dynamic> getApiCallWithAccessToken(
    String baseUrl,
    String endPoint, {
    String query = "",
    String? isAccessToken,
    dynamic bodyForGetApi,
  }) async {
    dynamic getResponseJson;
    String getUrl;

    // Set headers based on token availability
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (isAccessToken != null) "Authorization": isAccessToken,
    };

    // Construct the full URL with or without query parameters
    getUrl =
        query.isNotEmpty ? "$baseUrl$endPoint?$query" : "$baseUrl$endPoint";

    log("url: $getUrl, headers: $headers");
    log("Request start time: ${DateTime.now()}");

    try {
      // Make the GET request
      var response = await httpClient?.get(Uri.parse(getUrl), headers: headers);

      // Parse the response
      getResponseJson = await _parseGetResponseWithAccessToken(response!);
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    }

    log("Request end time: ${DateTime.now()}");
    return getResponseJson;
  }

  Future<dynamic> _parseGetResponseWithAccessToken(
      http.Response response) async {
    // Log response details for debugging
    logger.i("GET API RESPONSE: ${response.body}");
    logger.i("Request Status: ${response.statusCode}");

    switch (response.statusCode) {
      case 200:
        // Successful response
        return json.decode(response.body);

      case 401:
        // Unauthorized access
        var responseJson = json.decode(response.body);
        logger.i("Message: ${responseJson["message"]}");
        throw UnAuthorizedException(responseJson["message"]);

      case 404:
        // Resource not found
        var responseJson = json.decode(response.body);
        throw DoesNotExistException(responseJson["message"]);

      case 400:
        // Bad request with validation error
        var responseJson = json.decode(response.body);
        throw ServerValidationError(responseJson["message"]);

      case 500:
        // Internal server error
        var responseJson = json.decode(response.body);
        throw ServerValidationError(responseJson["message"]);

      case 503:
        // Service unavailable
        throw underMaintenanceError('Application Under Maintenance');

      default:
        // Unhandled status code
        throw Exception("Something went wrong");
    }
  }

  /////
  ///
  /// POST APIS WITH ACCESS TOKEN
  ///
  /// POST API CALL: SENDING logger.iIN DATA REQUEST TO SERVER.
  ///
  ///

  Future<dynamic> postApiCallWithAccessToken(
    String baseUrl,
    String endPoint,
    dynamic postBody, {
    String? query,
    String? isAccessToken,
    String? fireBaseTokenWhenBothNeeded,
    bool? isGetFirebaseToken,
    bool? isAppUserToken,
  }) async {
    dynamic postResponseJson;
    final String getUrl =
        query != null ? "$baseUrl$endPoint$query" : "$baseUrl$endPoint";

    // logger.iger.i URL and body for debugging
    logger.i("POST URL: $getUrl");
    logger.i("POST Body: $postBody");

    // Encode the body for JSON format
    final String encodedBody = json.encode(postBody);

    // Define headers based on token conditions
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (isAppUserToken == true && isGetFirebaseToken == true) ...{
        "Authorization": isAccessToken!,
        "firebase": fireBaseTokenWhenBothNeeded!,
      } else if (isGetFirebaseToken == true) ...{
        "firebase": isAccessToken!,
      } else if (isAccessToken != null) ...{
        "Authorization": isAccessToken,
      },
    };

    logger.i("Headers: $headers");
    logger.i("Request Start Time: ${DateTime.now()}");

    try {
      // Make the POST request
      final response = await httpClient?.post(
        Uri.parse(getUrl),
        headers: headers,
        body: encodedBody,
      );

      // Ensure response is not null before parsing
      if (response != null) {
        postResponseJson = await _parsePostResponseWithAccessToken(response);
      } else {
        throw FetchDataException("Failed to fetch response.");
      }
    } on SocketException {
      throw FetchDataException("No Internet Connection");
    }

    // Debugging output for request completion time
    log("Request End Time: ${DateTime.now()}");

    return postResponseJson;
  }

  Future<dynamic> _parsePostResponseWithAccessToken(
      http.Response response) async {
    // Log response details for debugging
    logger.i("Post API Response: ${response.body}");
    log("Post status: ${response.statusCode}");

    switch (response.statusCode) {
      case 200:
        // Successful response
        return json.decode(response.body);

      case 401:
        // Unauthorized access
        var responseJson = json.decode(response.body);
        logger.i("Message: ${responseJson["message"]}");
        throw UnAuthorizedException(responseJson["message"]);

      case 404:
        // Resource not found
        var responseJson = json.decode(response.body);
        logger.i("Message: ${responseJson["message"]}");
        throw DoesNotExistException(responseJson["message"]);

      case 400:
        // Bad request with validation error
        var responseJson = json.decode(response.body);
        logger.i("Message: ${responseJson["message"]}");
        throw ServerValidationError(responseJson['message']);

      case 403:
        // Forbidden access
        var responseJson = json.decode(response.body);
        logger.i("Message: ${responseJson["message"]}");
        throw ServerValidationError(responseJson["message"]);

      case 500:
        // Internal server error
        var responseJson = json.decode(response.body);
        throw ServerValidationError(responseJson["message"]);

      case 503:
        // Service unavailable
        throw underMaintenanceError('Application Under Maintenance');

      default:
        // Unhandled status code
        var responseJson = json.decode(response.body);
        logger.i("Message: ${responseJson["message"]}");
        throw Exception(responseJson["message"]);
    }
  }

  /////
  ///
  /// PUS APIS WITH ACCESS TOKEN
  ///
  /// PUT API CALL: SENDING LOGIN DATA REQUEST TO SERVER.
  ///
  ///
  Future<dynamic> putAPICallsWithBody(
    String baseUrl,
    String endPoint,
    dynamic putBody, {
    String? isAccessToken,
  }) async {
    String putUrl = "$baseUrl$endPoint";
    var encodedBody = json.encode(putBody);
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (isAccessToken != null) "Authorization": isAccessToken,
    };

    log("PUT URL: $putUrl, Headers: $headers,\nBody: $encodedBody");

    try {
      var response = await httpClient?.put(
        Uri.parse(putUrl),
        headers: headers,
        body: encodedBody,
      );
      return await _parsePutWithBodyResponse(response!);
    } on SocketException {
      throw FetchDataException("No internet connection.");
    }
  }

  Future<dynamic> _parsePutWithBodyResponse(http.Response response) async {
    logger.i("PUT API Response: ${response.body}");
    logger.i("Response Status Code: ${response.statusCode}");

    var responseJson = json.decode(response.body);
    switch (response.statusCode) {
      case 200:
        return responseJson;
      case 400:
        logger.i("Error Message: ${responseJson['message']}");
        throw ServerValidationError(responseJson['message']);

      case 401:
        logger.i("Error Message: ${responseJson['message']}");
        throw UnAuthorizedException(responseJson['message']);

      case 403:
        logger.i("Error Message: ${responseJson['message']}");
        throw ServerValidationError(responseJson['message']);

      case 404:
        logger.i("Error Message: ${responseJson['message']}");
        throw DoesNotExistException(responseJson['message']);

      case 500:
        logger.i("Error Message: ${responseJson['message']}");
        throw ServerValidationError(responseJson['message']);

      case 503:
        throw underMaintenanceError("Application Under Maintenance");

      default:
        logger.i("Error Message: ${responseJson['message']}");
        throw Exception(responseJson['message']);
    }
  }

  /////
  ///
  /// PUS APIS WITH ACCESS TOKEN AND MULTIPART
  ///
  /// PUT API CALL: SENDING LOGIN DATA REQUEST TO SERVER.
  ///
  ///
  Future<dynamic> apiCallMultipartPut(
    String baseUrl,
    String apiEndPoint,
    File? selectedImage,
    File? selectedCoverImage,
    dynamic putBody, {
    String? accessToken,
  }) async {
    // Construct the PUT URL
    final getUrl = Uri.parse('$baseUrl$apiEndPoint');
    log("PUT URL: $getUrl");

    // Create the MultipartRequest with the PUT method
    final request = http.MultipartRequest('PUT', getUrl);

    // Add headers
    request.headers.addAll({
      "Accept": "multipart/form-data",
      if (accessToken != null) "Authorization": accessToken,
    });

    // Add the file
    if (selectedImage != null)
      request.files.add(await http.MultipartFile.fromPath(
        "profileImage",
        selectedImage.path,
        contentType: MediaType('image', 'jpg'),
      ));

    if (selectedCoverImage != null)
      request.files.add(await http.MultipartFile.fromPath(
        "coverImage",
        selectedCoverImage.path,
        contentType: MediaType('image', 'jpg'),
      ));

    // Log for debugging
    logger.i('Request Fields: ${request.fields}');

    // Send the request
    try {
      final response = await request.send();

      // Read and decrypt the response
      final stringResponse = await response.stream.bytesToString();
      logger.i("Response: $stringResponse");
      logger.i("Status Code: ${response.statusCode}");

      //  return await _parsePutWithBodyResponse(response!);

      // Handle response based on status code
      switch (response.statusCode) {
        case 200:
          return json.decode(stringResponse);

        case 401:
          throw UnAuthorizedException('Unauthorized access.');

        case 404:
          throw DoesNotExistException('Resource not found.');

        case 400:
          throw ServerValidationError('Invalid request.');

        case 500:
        case 503:
          throw underMaintenanceError('Server is under maintenance.');

        default:
          throw Exception('Unexpected error occurred.');
      }
    } on SocketException {
      throw FetchDataException("No internet connection.");
    } catch (e) {
      logger.i("Error: $e");
      throw Exception("Error occurred while uploading file.");
    }
  }

  Future<dynamic> apiCallMultipartPostForCommunity(
      String baseUrl, String apiEndPoint, Map<String, dynamic> mediaMap,
      {String? isAccessToken}) async {
    try {
      logger.i('postData===>>> 6 $mediaMap');
      MediaData data = MediaData.fromJson(mediaMap);
      var getUrl = Uri.parse('$baseUrl$apiEndPoint');
      logger.i("postUrl $getUrl");
      logger.i('postData===>>> 8 ${jsonEncode(data.tags)}');

      var request = http.MultipartRequest('POST', getUrl);

      // request.headers.addAll({
      //   "Accept": "multipart/form-data",
      //   "isClient": "true",
      //   "Authorization": "$communityAccesToken",
      // });

      // Add 'caption' field
      if (data.caption != null) {
        request.fields['caption'] = data.caption!;
      }

      if (data.latitude != null) {
        request.fields['latitude'] = data.latitude!;
      }

      if (data.placeId != null) {
        request.fields['placeId'] = data.placeId!;
      }

      if (data.longitude != null) {
        request.fields['longitude'] = data.longitude!;
      }

      if (data.address != null) {
        request.fields['address'] = data.address!;
      }

      if (data.imageOrientation != null) {
        request.fields['imageOrientation'] = '${data.imageOrientation}';
      }

      if (data.thumbnail != null) {
        // Ensure the file is an image
        String fileExtension =
            data.thumbnail!.path.split('.').last.toLowerCase();
        MediaType contentType = MediaType('image',
            fileExtension); // Set image content type dynamically based on the file extension

        var multipartFile = await http.MultipartFile.fromPath(
          "thumbnail", // Field name (key) in the request
          data.thumbnail!.path,
          contentType: contentType, // Use dynamic image content type
        );

        // Add the thumbnail file to the request
        request.files.add(multipartFile);
      }

      // Add 'tags' field (ensure it's serialized as JSON string)
      if (data.tags != null) {
        request.fields['tags'] = jsonEncode(data.tags);
      }

      // Add 'media' files
      if (data.media != null) {
        for (var media in data.media!) {
          // Determine content type based on file extension
          String fileExtension = media.path.split('.').last.toLowerCase();
          MediaType contentType;

          // Check for image type
          if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(fileExtension)) {
            contentType = MediaType('image', fileExtension);
          }
          // Check for video type
          else if (['mp4', 'mov', 'avi', 'mkv', 'flv']
              .contains(fileExtension)) {
            contentType = MediaType('video', fileExtension);
          } else {
            continue; // Skip unsupported files
          }

          // Create multipart file with appropriate content type
          var multipartFile = await http.MultipartFile.fromPath(
            "media", // Match the key in your backend
            media.path,
            contentType: contentType,
          );

          // Add the multipart file to the request
          request.files.add(multipartFile);
        }
      }

      logger.i('request fields >>> ${request.fields}');
      logger.i('request files >>> ${request.files}');

      // Sending the request
      var response = await request.send();

      var stringResponse = await response.stream.bytesToString();
      logger.i("Response: $stringResponse");

      // Handle response
      if (response.statusCode == 200) {
        return json.decode(stringResponse);
      } else {
        throw Exception(
            "Failed with status: ${response.statusCode}, body: $stringResponse");
      }
    } catch (e) {
      logger.i("Error: $e");
      rethrow;
    }
  }

  Future<dynamic> deleteAPICalls(
    String baseUrl,
    String endPoint, {
    String query = "",
    String? isAccessToken,
    dynamic postBody,
  }) async {
    dynamic postResponseJson;
    String deleteUrl;

    Map<String, String>? headers;

    deleteUrl = "$baseUrl$endPoint";

    // var encodedBody = json.encode(putBody);

    if (isAccessToken != null) {
      headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": isAccessToken,
      };
    } else {
      headers = {"Accept": "application/json"};
    }

    logger.i("Delete url: $deleteUrl, headers: $headers");
    // log(postBody);
    var encodedBody;
    if (postBody != null) {
      encodedBody = json.encode(postBody);
    }

    try {
      var response = await httpClient?.delete(Uri.parse(deleteUrl),
          headers: headers, body: encodedBody);
      logger.i('dasdasdad1211112 ${response}');

      postResponseJson = await _parseDeleteResponse(response!);
      logger.i('dasdasdad1212 ${response}');
    } on SocketException {
      throw FetchDataException("No internet connections.");
    }

    return postResponseJson;
  }

  Future<dynamic> _parseDeleteResponse(http.Response response) async {
    switch (response.statusCode) {
      case 200:
        var postResponseJson = json.decode(response.body);
        return postResponseJson;

      case 401:
        var postResponseJson = json.decode(response.body);
        logger.i("401 message:  ${postResponseJson["message"]}");
        throw UnAuthorizedException(postResponseJson["message"]);

      case 404:
        var postResponseJson = json.decode(response.body);
        logger.i("404 message:  ${postResponseJson["message"]}");
        throw DoesNotExistException(postResponseJson["message"]);

      case 400:
        var postResponseJson = json.decode(response.body);
        logger.i("400 message:  ${postResponseJson["message"]}");
        throw ServerValidationError(postResponseJson['message']);

      case 403:
        var postResponseJson = json.decode(response.body);
        logger.i("403 message:  ${postResponseJson["message"]}");
        throw ServerValidationError(postResponseJson["message"]);

      case 500:
        var postResponseJson = json.decode(response.body);
        logger.i("500 message:  ${postResponseJson["message"]}");
        throw ServerValidationError(postResponseJson["message"]);

      case 503:
        var postResponseJson = json.decode(response.body);
        logger.i("503 message:  ${postResponseJson["message"]}");
        throw underMaintenanceError('Application Under Maintenance');

      default:
        var postResponseJson = json.decode(response.body);
        logger.i("default message:  ${postResponseJson["message"]}");
        // throw Exception("Something went Wrong");
        throw Exception(postResponseJson["message"]);
    }
  }
}

class MediaData {
  String? caption;
  String? placeId;
  String? latitude;
  String? address;
  String? longitude;
  File? thumbnail;
  int? imageOrientation;
  List<File>? media;
  List<List<Map<dynamic, dynamic>>>? tags;

  MediaData({this.media, this.caption, this.tags});

  MediaData.fromJson(Map<String, dynamic> json) {
    caption = json['caption'];
    placeId = json['placeId'];
    latitude = json['latitude'];
    address = json['address'];
    thumbnail = json['thumbnail'];
    longitude = json['longitude'];
    imageOrientation = json['imageOrientation'];

    // Parse `media` as a list of File objects
    if (json['media'] != null && json['media'] is List) {
      media = (json['media'] as List).map((file) {
        if (file is File) return file; // Already a File object
        if (file is String) return File(file); // Convert path to File
        throw Exception("Invalid media format");
      }).toList();
    }

    // Parse `tags` as a List<Map<String, dynamic>>
    if (json['tags'] != null && json['tags'] is List) {
      tags = List<List<Map<String, dynamic>>>.from(json['tags']);
    } else {
      tags = [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'caption': caption,
      // Media remains as a list of File objects
      'media': media,
      'tags': tags,
      'longitude': longitude,
      'address': address,
      'latitude': latitude,
      'thumbnail': thumbnail,
      'placeId': placeId,
      'imageOrientation': imageOrientation,
    };
  }
}
