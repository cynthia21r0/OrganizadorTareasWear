import 'package:dio/dio.dart';
import 'wear_api_client.dart';

class WearLoginResult {
  final String token;
  final String userId;
  final String userName;
  final String? profilePicture;

  const WearLoginResult({
    required this.token,
    required this.userId,
    required this.userName,
    this.profilePicture,
  });
}

class WearAuthRepository {
  final Dio _dio = WearApiClient.instance.dio;

  Future<WearLoginResult> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return _parse(response.data as Map<String, dynamic>);
  }

  WearLoginResult _parse(Map<String, dynamic> data) {
    final token =
        (data['accessToken'] ?? data['access_token'] ?? data['token'])
            as String?;
    final user = data['user'] as Map<String, dynamic>?;
    final userId = (user?['id'] ?? data['userId'] ?? data['id']) as String?;
    final userName = (user?['name'] ?? data['name'] ?? '') as String;

    final profilePicture = user?['profilePicture'] as String?;

    if (token == null || userId == null) {
      throw Exception(
        'Respuesta de login inesperada. Revisa los nombres de campo '
        'en WearAuthRepository._parse contra la respuesta real de tu backend.',
      );
    }

    return WearLoginResult(
      token: token,
      userId: userId,
      userName: userName,
      profilePicture: profilePicture,
    );
  }

  Future<WearLoginResult> getFirstUser() async {
    const email = 'cynthiajanethgranados@gmail.com';
    const password = 'EsTrada12#';

    return await login(email, password);
  }
}
