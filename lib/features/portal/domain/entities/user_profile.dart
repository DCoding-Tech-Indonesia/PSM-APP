import 'package:psm_mobile/features/portal/domain/entities/portal_menu.dart';

class UserProfile {
  final String id;
  final String username;
  final String email;
  final String name;
  final List<PortalMenu> menu;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.menu,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      menu: json['menu'] != null
          ? (json['menu'] as List).map((i) => PortalMenu.fromJson(i)).toList()
          : [],
    );
  }
}
