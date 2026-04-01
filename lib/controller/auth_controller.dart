import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/admin_wrapper.dart';
import 'package:managementt/login_page.dart';
import 'package:managementt/members/user_wrapper.dart';
import 'package:managementt/model/auth_response.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final accessToken = ''.obs;
  final refreshToken = ''.obs;
  final role = ''.obs;
  final username = ''.obs;
  final isLoggedIn = false.obs;
  final isLoading = false.obs;
  final currentUserId = ''.obs;

  // Storage keys
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyRole = 'role';
  static const _keyUsername = 'username';
  static const _keyCurrentUserId = 'current_user_id';

  @override
  void onInit() {
    super.onInit();
    restoreSession();
  }

  /// Restore saved session from secure storage on app startup.
  Future<void> restoreSession() async {
    isLoading.value = true;
    try {
      final storedAccess = await _storage.read(key: _keyAccessToken);
      final storedRefresh = await _storage.read(key: _keyRefreshToken);
      final storedRole = await _storage.read(key: _keyRole);
      final storedUsername = await _storage.read(key: _keyUsername);
      final storedUserId = await _storage.read(key: _keyCurrentUserId);

      if (storedAccess != null && storedRefresh != null && storedRole != null) {
        accessToken.value = storedAccess;
        refreshToken.value = storedRefresh;
        role.value = storedRole;
        username.value = storedUsername ?? '';
        currentUserId.value = storedUserId ?? '';
        isLoggedIn.value = true;
        // SplashScreen reacts to isLoggedIn + role and renders the right widget.
        // Do NOT call Get.offAll here — the navigator isn't ready yet.
      }
    } catch (e) {
      print('AuthController: Failed to restore session — $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Store auth data received from the backend after login.
  Future<void> setAuthData(
    AuthResponse authResponse, {
    String? loginUsername,
  }) async {
    accessToken.value = authResponse.accessToken;
    refreshToken.value = authResponse.refreshToken;
    role.value = authResponse.role;

    if (loginUsername != null) {
      username.value = loginUsername;
    }

    currentUserId.value = (authResponse.userId ?? '').trim();

    isLoggedIn.value = true;

    print(
      'AuthController: Storing auth data for userId=${currentUserId.value}, username=${username.value}, role=${role.value}',
      
    );

    await _storage.write(key: _keyAccessToken, value: authResponse.accessToken);
    await _storage.write(
      key: _keyRefreshToken,
      value: authResponse.refreshToken,
    );
    await _storage.write(key: _keyRole, value: authResponse.role);
    if (loginUsername != null) {
      await _storage.write(key: _keyUsername, value: loginUsername);
    }

    await _storage.write(key: _keyCurrentUserId, value: currentUserId.value);

    _navigateByRole();
  }

  /// Update only the access token (used after a refresh).
  Future<void> updateAccessToken(String newToken) async {
    accessToken.value = newToken;
    await _storage.write(key: _keyAccessToken, value: newToken);
  }

  /// Full logout — clears storage, resets state, navigates to login.
  Future<void> logout() async {
    accessToken.value = '';
    refreshToken.value = '';
    role.value = '';
    username.value = '';
    currentUserId.value = '';
    isLoggedIn.value = false;

    await _storage.deleteAll();

    Get.offAll(() => LoginPage());
  }

  /// Navigate based on role.
  void _navigateByRole() {
    if (role.value == 'ADMIN') {
      Get.offAll(() => AdminWrapper());
    } else {
      Get.offAll(() => UserWrapper());
    }
  }
}
