import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device.dart';

class DioClient {
  late Dio _dio;
  // استخدم 10.0.2.2 للأندرويد إيموليتر أو IP جهازك للموبايل الحقيقي
  static const String baseUrl = "http://192.168.1.9:3000/api";
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );

    // إضافة Interceptor لإرسال التوكن تلقائياً مع كل طلب
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['x-auth-token'] = token;
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        print("❌ API Error: ${e.response?.data ?? e.message}");
        return handler.next(e);
      },
    ));
  }

  // --- العمليات (Endpoints) ---

  // 1. تسجيل الدخول وحفظ التوكن
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        "email": email,
        "password": password,
      });

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response.data['token']);
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString() + " login error ");
      return false;
    }
  }

  Future<void> syncDevices(List<Device> devices) async {
    try {
      final data = devices.map((d) => d.toJson()).toList();
      await _dio.post('/backup/sync', data: data);
      print("✅ Backup completed successfully!");
    } catch (e) {
      throw Exception("Backup failed: $e");
    }
  }

  Future<List<Device>> restoreDevices() async {
    try {
      final response = await _dio.get('/backup/restore');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Device.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception("Restore failed: $e");
    }
  }
  Future<Map<String, dynamic>?> retrieveUser(String email) async {
    try {
      final response = await _dio.get('/auth/user/$email');

      if (response.statusCode == 200) {
        return response.data; // هيرجع الـ User object كـ Map
      }
      return null;
    } catch (e) {
      print("Error retrieving user: $e");
      return null;
    }
  }
}