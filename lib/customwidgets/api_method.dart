import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lktaskmanagementapp/config.dart';

class ApiService {
  Future<Map<String, dynamic>> request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    bool tokenRequired = false,
    bool isMultipart = false,
  }) async {
    if (tokenRequired) {
      final token = await _getToken();
      if (token == null) {
        return {'message': 'Token is required but not found.'};
      }
      return _sendRequestWithToken(method, endpoint, body, token, isMultipart);
    } else {
      return _sendRequestWithoutToken(method, endpoint, body, isMultipart);
    }
  }

  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> _sendRequestWithToken(
      String method, String endpoint, Map<String, dynamic>? body, String token, bool isMultipart) async {
    try {
      final uri = Uri.parse('${Config.apiUrl}$endpoint');
      final headers = _getHeaders(token);
      return await _sendRequest(method, uri, headers, body, isMultipart);
    } catch (e) {
      return {'statusCode': 500, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _sendRequestWithoutToken(
      String method, String endpoint, Map<String, dynamic>? body, bool isMultipart) async {
    try {
      final uri = Uri.parse('${Config.apiUrl}$endpoint');
      final headers = {'Content-Type': 'application/json'};
      return await _sendRequest(method, uri, headers, body, isMultipart);
    } catch (e) {
      return {'statusCode': 500, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _sendRequest(
      String method, Uri uri, Map<String, String> headers, Map<String, dynamic>? body, bool isMultipart) async {
    try {
      http.Response response;

      if (isMultipart) {
        var request = http.MultipartRequest(method.toUpperCase(), uri);
        request.headers.addAll(headers);

        if (body != null) {
          body.forEach((key, value) {
            request.fields[key] = value.toString();
          });
        }

        var streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        final requestBody = body != null ? json.encode(body) : null;
        switch (method.toLowerCase()) {
          case 'get':
            response = await http.get(uri, headers: headers);
            break;
          case 'post':
            response = await http.post(uri, headers: headers, body: requestBody);
            break;
          case 'put':
            response = await http.put(uri, headers: headers, body: requestBody);
            break;
          case 'delete':
            response = await http.delete(uri, headers: headers, body: requestBody);
            break;
          default:
            return {'statusCode': 400, 'message': 'Invalid HTTP method.'};
        }
      }
      if (response.statusCode == 200) {
        return json.decode(response.body);

      } else {
        return json.decode(response.body);
      }
    } catch (e) {
      return {
        'statusCode': 500,
        'message': 'Check Your API',
      };
    }
  }
  }




























//
// import 'package:flutter_bloc/flutter_bloc.dart';//
// abstract class ApiState {}
//
// class ApiInitial extends ApiState {}
//
// class ApiLoading extends ApiState {}
//
// class ApiSuccess extends ApiState {
//   final Map<String, dynamic> data;
//   ApiSuccess(this.data);
// }
//
// class ApiError extends ApiState {
//   final String message;
//   ApiError(this.message);
// }
//
// class ApiCubit extends Cubit<ApiState> {
//   ApiCubit() : super(ApiInitial());
//
//   Future<void> markAttendanceCheckin(String inOutFlag, String inLocation) async {
//     emit(ApiLoading());
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       int userId = prefs.getInt('user_Id') ?? 0;
//
//       if (userId != 0) {
//         final response = await ApiService().request(
//           method: 'post',
//           endpoint: 'attendance/MarkAttendnace',
//           body: {
//             'userId': userId,
//             'inOutFlag': inOutFlag,
//             'inLocation': inLocation,
//           },
//         );
//
//         if (response['statusCode'] >= 200 && response['statusCode'] < 400) {
//           emit(ApiSuccess(response));
//         } else {
//           emit(ApiError(response['message'] ?? 'Failed to mark attendance'));
//         }
//       } else {
//         emit(ApiError('User not logged in'));
//       }
//     } catch (e) {
//       emit(ApiError('Error: $e'));
//     }
//   }
//
//   Future<void> markAttendanceCheckout(String inOutFlag, String outLocation) async {
//     emit(ApiLoading());
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       int userId = prefs.getInt('user_Id') ?? 0;
//
//       if (userId != 0) {
//         final response = await ApiService().request(
//           method: 'post',
//           endpoint: 'attendance/MarkAttendnace',
//           body: {
//             'userId': userId,
//             'inOutFlag': inOutFlag,
//             'outLocation': outLocation,
//           },
//         );
//
//         if (response['statusCode'] >= 200 && response['statusCode'] < 400) {
//           emit(ApiSuccess(response));
//         } else {
//           emit(ApiError(response['message'] ?? 'Failed to mark attendance'));
//         }
//       } else {
//         emit(ApiError('User not logged in'));
//       }
//     } catch (e) {
//       emit(ApiError('Error: $e'));
//     }
//   }
//
//   Future<void> fetchAttendance() async {
//     emit(ApiLoading());
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       int? userId = prefs.getInt('user_Id');
//       final response = await ApiService().request(
//         method: 'get',
//         endpoint: 'attendance/GetAttendance?userId=$userId',
//       );
//
//       if (response['statusCode'] == 200 && response['apiResponse'] != null) {
//         emit(ApiSuccess(response['apiResponse']));
//       } else {
//         emit(ApiError(response['message'] ?? 'Failed to load attendance data'));
//       }
//     } catch (e) {
//       emit(ApiError('Error: $e'));
//     }
//   }
// }
