import 'package:my_devices/data/providers/local/local_db.dart';

import '../../core/core.dart';
import '../providers/remote/dio_client.dart';
import 'device_repository.dart';

class DioDeviceRepository implements IDeviceRepository {
  final Dio _dio = DioClient().dio;
  @override
  Future<void> syncDevices(List<Device> devices) async {
    final data = devices.map((d) => d.toJson()).toList();
    await _dio.post('/backup/sync', data: data);
  }
  @override
  Future<List<Device>> restoreDevices() async {
    final response = await _dio.get('/backup/restore');
    return (response.data as List).map((json) => Device.fromJson(json)).toList();
  }
  @override
  Future<User> retrieveUser(String email) async {
    final response = await _dio.get('/auth/user/$email');
    return User.fromJson(response.data);
  }
  @override
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
    } on DioException catch (e) {
      if (!(e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout)) {
        return false;
      }
      rethrow;
    }
  }



  @override
  Future<void> logout() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
  }

  @override
  Future<User?> retrieveUserLocally(String email) async {
   return await LocalDB().retrieveUser(email);
  }

  @override
  Future<void> restPassword(String email) {
    // TODO: implement restPassword
    throw UnimplementedError();
  }

}

