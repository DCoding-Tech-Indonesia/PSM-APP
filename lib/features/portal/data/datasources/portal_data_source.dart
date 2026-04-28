import 'package:dio/dio.dart';
import 'package:psm_mobile/features/portal/domain/entities/user_profile.dart';

class PortalDataSource {
  final Dio dio;

  PortalDataSource({required this.dio});

  Future<UserProfile> getProfile() async {
    try {
      final response = await dio.get('/auth/my/profile');
      
      print('[PROFILE RESPONSE]');
      print(response.data);

      if (response.data['status'] == true && response.data['data'] != null && response.data['data'].isNotEmpty) {
        return UserProfile.fromJson(response.data['data'][0]);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      throw Exception('Failed to get profile: ${e.toString()}');
    }
  }
}
