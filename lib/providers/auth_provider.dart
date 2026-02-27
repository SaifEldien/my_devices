import 'package:flutter/foundation.dart';

import '../core/core.dart';
import '../core/funcs/set_app_language_from_device.dart';
import '../data/providers/local/local_db.dart';
import '../data/repositories/device_repository.dart';

class AuthProvider extends ChangeNotifier {
  final IDeviceRepository _repo;
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = true;
  bool _isFirst = true;

  AuthProvider(this._repo) {
    _init();
  }
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isFirst => _isFirst;

  Future<void> _init() async {
    await _checkIsFirst();
    if (!_isFirst) {
      await _checkAuthStatus();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future <void> _checkIsFirst () async {
    _isFirst = await getPref('isFirst') ?? true;
    notifyListeners();
  }

  void setIsFirst ({required bool newIsFirst}) {
      _isFirst = newIsFirst;
      notifyListeners();
  }

  /// if the server is reached but explicitly rejects the credentials,
  /// it sets authentication to false and wipes local data for security.
  /// If a network error or timeout occurs,
  /// it triggers the catch block to bypass the deletion and allow the user to log in via the offline local database instead

  Future<void> _checkAuthStatus() async {
    if (isFirst) return;
    _setLoading(true);
    String? email = await getPref('email');
    String? password = await getPref('password');
    if (email != null && password != null) {
      try {
        bool onlineSuccess = await _repo.login(email, password).timeout(Duration(seconds: 2));
        if (onlineSuccess) {
          _currentUser = await _repo.retrieveUser(email);
          _isAuthenticated = true;
        } else {
          _isAuthenticated = false;
          debugPrint("Security Action: Deleting local user $email due to invalid credentials.");
          await LocalDB().delete('users', (await LocalDB().retrieveUser(email))?.id);
        }
      } catch (e) {
        debugPrint("${e.toString()} , 🌐 Online login failed or timeout, checking offline status...");
        _isAuthenticated = await _checkOfflineStatus(email);
      }
    } else {
      _isAuthenticated = false;
    }
    _setLoading(false);
  }

  Future<bool> manualLogin(String email, String password) async {
    try {
      bool success = await _repo.login(email, password);
      if (success) {
        _currentUser = await _repo.retrieveUser(email);
        _isAuthenticated = true;
        await setPref('email', email);
        await setPref('password', password);
        await LocalDB().insertData('users', _currentUser!.toJson());
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Manual login error: $e");
    }
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> _checkOfflineStatus(String email) async {
    try {
      final localUser = await _repo.retrieveUserLocally(email);
      if (localUser != null) {
        _currentUser = localUser;
        if (kDebugMode) print("✔ Authenticated via Local Data (Offline Mode)");
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print("❌ Offline check failed: $e");
      return false;
    }
  }

  Future<void> refreshUserData() async {
    if (_currentUser == null) return;
    try {
      final updatedUser = await _repo.retrieveUser(_currentUser!.email);
      _currentUser = updatedUser;
      await LocalDB().insertData('users', _currentUser!.toJson());
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Failed to refresh user: $e");
    }
  }

  Future<void> logout(BuildContext context) async {
    await _repo.logout();
    _currentUser = null;
    _isAuthenticated = false;
    await removePref('email');
    await removePref('password');
    if (context.mounted) {
      setAppLanguageFromDevice(context);
    }
    notifyListeners();

  }

  Future<void> restPassword(String email) async {
    try {
      await _repo.restPassword(email);
    }
    catch (e){ rethrow;}
  }
}