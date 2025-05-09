import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatApiWrapper {
  // Future<IsmChatResponseModel> _handleNoInternet(bool showDailog) async {
  //   IsmChatLog.error('----- Internet not working -----');
  //   if (showDailog && Get.isDialogOpen == false) {
  //     await IsmChatUtility.showErrorDialog(IsmChatStrings.noInternet);
  //   }

  //   return const IsmChatResponseModel(
  //     data: IsmChatStrings.noInternet,
  //     errorCode: 1000,
  //     hasError: true,
  //   );
  // }

  Future<IsmChatResponseModel> get(
    String api, {
    bool showLoader = false,
    bool showDailog = true,
    required Map<String, String> headers,
  }) async {
    IsmChatLog('Request - GET $api \n$headers');

    // if (!(await IsmChatUtility.isNetworkAvailable)) {
    //   return await _handleNoInternet(showDailog);
    // }
    var uri = Uri.parse(api);
    if (showLoader) {
      IsmChatUtility.showLoader();
    }
    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 60));

      if (showLoader) {
        IsmChatUtility.closeLoader();
      }

      return _processResponse(response: response, apiUrl: uri.toString());
    } on TimeoutException catch (_) {
      if (showLoader) {
        IsmChatUtility.closeLoader();
      }
      return const IsmChatResponseModel(
        data: '{"message":"Request timed out"}',
        hasError: true,
        errorCode: 1000,
      );
    }
  }

  Future<IsmChatResponseModel> post(
    String api, {
    required dynamic payload,
    required Map<String, String> headers,
    bool showLoader = false,
    bool showDailog = true,
  }) async {
    IsmChatLog('Request - POST $api \n$payload \n$headers');
    // if (!(await IsmChatUtility.isNetworkAvailable)) {
    //   return await _handleNoInternet(showDailog);
    // }
    var uri = Uri.parse(api);
    if (showLoader) {
      IsmChatUtility.showLoader();
    }
    try {
      final response = await http
          .post(uri, body: jsonEncode(payload), headers: headers)
          .timeout(const Duration(seconds: 60));

      if (showLoader) {
        IsmChatUtility.closeLoader();
      }
      return _processResponse(response: response, apiUrl: uri.toString());
    } on TimeoutException catch (_) {
      if (showLoader) {
        IsmChatUtility.closeLoader();
      }
      return const IsmChatResponseModel(
        data: '{"message":"Request timed out"}',
        hasError: true,
        errorCode: 1000,
      );
    }
  }

  Future<IsmChatResponseModel> put(
    String api, {
    required dynamic payload,
    required Map<String, String> headers,
    bool showLoader = false,
    bool forAwsUpload = false,
    bool showDailog = true,
  }) async {
    IsmChatLog('Request - PUT $api \n$payload \n$headers');
    // if (!(await IsmChatUtility.isNetworkAvailable)) {
    //   return await _handleNoInternet(showDailog);
    // }
    var uri = Uri.parse(api);
    if (showLoader) {
      IsmChatUtility.showLoader();
    }
    try {
      final response = await http
          .put(
            uri,
            body: forAwsUpload ? payload : jsonEncode(payload),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      if (showLoader) {
        IsmChatUtility.closeLoader();
      }

      return _processResponse(response: response, apiUrl: uri.toString());
    } on TimeoutException catch (_) {
      if (showLoader) {
        IsmChatUtility.closeLoader();
      }
      return const IsmChatResponseModel(
        data: '{"message":"Request timed out"}',
        hasError: true,
        errorCode: 1000,
      );
    }
  }

  Future<IsmChatResponseModel> patch(
    String api, {
    required dynamic payload,
    required Map<String, String> headers,
    bool showLoader = false,
    bool showDailog = true,
  }) async {
    IsmChatLog('Request - PATCH $api \n$payload \n$headers');
    // if (!(await IsmChatUtility.isNetworkAvailable)) {
    //   return await _handleNoInternet(showDailog);
    // }
    var uri = Uri.parse(api);
    if (showLoader) {
      IsmChatUtility.showLoader();
    }
    try {
      final response = await http
          .patch(
            uri,
            body: jsonEncode(payload),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      if (showLoader) {
        IsmChatUtility.closeLoader();
      }

      return _processResponse(response: response, apiUrl: uri.toString());
    } on TimeoutException catch (_) {
      if (showLoader) {
        IsmChatUtility.closeLoader();
      }
      return const IsmChatResponseModel(
        data: '{"message":"Request timed out"}',
        hasError: true,
        errorCode: 1000,
      );
    }
  }

  Future<IsmChatResponseModel> delete(
    String api, {
    required dynamic payload,
    required Map<String, String> headers,
    bool showLoader = false,
    bool showDailog = true,
  }) async {
    IsmChatLog('Request - DELETE $api \n$payload \n$headers');
    // if (!(await IsmChatUtility.isNetworkAvailable)) {
    //   return await _handleNoInternet(showDailog);
    // }
    var uri = Uri.parse(api);
    if (showLoader) {
      IsmChatUtility.showLoader();
    }
    try {
      final response = await http
          .delete(
            uri,
            body: jsonEncode(payload),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      if (showLoader) {
        IsmChatUtility.closeLoader();
      }

      return _processResponse(response: response, apiUrl: uri.toString());
    } on TimeoutException catch (_) {
      if (showLoader) {
        IsmChatUtility.closeLoader();
      }
      return const IsmChatResponseModel(
        data: '{"message":"Request timed out"}',
        hasError: true,
        errorCode: 1000,
      );
    }
  }

  IsmChatResponseModel _processResponse({
    required http.Response response,
    required String apiUrl,
  }) {
    IsmChatLog.info(
      'Response - ${response.request?.method} ${response.statusCode} ${response.request?.url}\n${response.body}',
    );
    switch (response.statusCode) {
      case 204:
        return IsmChatResponseModel(
          data: '{}',
          hasError: false,
          errorCode: response.statusCode,
        );
      case 200:
      case 201:
      case 202:
      case 203:
      case 205:
      case 208:
        return IsmChatResponseModel(
          data: response.body,
          hasError: false,
          errorCode: response.statusCode,
        );
      case 400:
      case 401:
      case 404:
      case 406:
      case 409:
      case 422:
      case 500:
      case 503:
      case 522:
      default:
        final res = IsmChatResponseModel(
          data: response.body,
          hasError: true,
          errorCode: response.statusCode,
        );
        IsmChatConfig.chatInvalidate?.call(res, apiUrl);
        return res;
    }
  }
}
