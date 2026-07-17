import 'package:dio/dio.dart';
import 'wear_api_client.dart';

class WearLoginResult {
  final String token;
  final String userId;
  final String userName;
  final String role;
  final String? profilePicture;

  const WearLoginResult({
    required this.token,
    required this.userId,
    required this.userName,
    this.role = 'otro',
    this.profilePicture,
  });
}

class WearFamilyMember {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profilePicture;

  const WearFamilyMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePicture,
  });

  factory WearFamilyMember.fromJson(Map<String, dynamic> j) => WearFamilyMember(
        id: j['id'] as String,
        name: j['name'] as String,
        email: j['email'] as String,
        role: j['role'] as String? ?? '',
        profilePicture: j['profilePicture'] as String?,
      );
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

  Future<WearLoginResult> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? familyName,
    String? inviteCode,
  }) async {
    await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      if (familyName != null) 'familyName': familyName,
      if (inviteCode != null) 'inviteCode': inviteCode,
    });
    // Después de registrar, hacer login para obtener el token
    return login(email, password);
  }

  Future<List<WearFamilyMember>> getFamilyMembers() async {
    final response = await _dio.get('/users');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => WearFamilyMember.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  WearLoginResult _parse(Map<String, dynamic> data) {
    final token =
        (data['accessToken'] ?? data['access_token'] ?? data['token'])
            as String?;
    final user = data['user'] as Map<String, dynamic>?;
    final userId = (user?['id'] ?? data['userId'] ?? data['id']) as String?;
    final userName = (user?['name'] ?? data['name'] ?? '') as String;
    final profilePicture = user?['profilePicture'] as String?;
    final role = user?['role'] as String? ?? 'otro';

    if (token == null || userId == null) {
      throw Exception('Respuesta de login inesperada.');
    }

    return WearLoginResult(
      token: token,
      userId: userId,
      userName: userName,
      role: role,
      profilePicture: profilePicture,
    );
  }

  Future<WearLoginResult> getFirstUser() async {
    const email = 'cynthiajanethgranados@gmail.com';
    const password = 'EsTrada12#';
    return login(email, password);
  }
}
