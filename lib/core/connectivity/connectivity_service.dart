import 'package:connectivity_plus/connectivity_plus.dart';

import '../core.dart';

class ConnectivityService {
  static Future<bool> hasConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      showToast("no_internet".tr(),isError: true);
      return false;
    }

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      showToast("no_internet".tr(),isError: true);
      return false;
    }
  }
  static Stream<List<ConnectivityResult>> get connectionStream =>
      Connectivity().onConnectivityChanged;
}