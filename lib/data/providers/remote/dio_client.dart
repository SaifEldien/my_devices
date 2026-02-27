import 'package:flutter/foundation.dart';

import '../../../core/core.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;
  factory DioClient() => _instance;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://my-devices-server.vercel.app/api",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['x-auth-token'] = token;
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) print("❌ API Error: ${e.response?.data ?? e.message}");
        return handler.next(e);
      },
    ));
  }
}