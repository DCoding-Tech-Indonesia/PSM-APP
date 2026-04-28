class PortalMenu {
  final int menuId;
  final String title;
  final String? icon;
  final String? route;
  final String typeMenu;

  PortalMenu({
    required this.menuId,
    required this.title,
    this.icon,
    this.route,
    required this.typeMenu,
  });

  factory PortalMenu.fromJson(Map<String, dynamic> json) {
    return PortalMenu(
      menuId: json['menuId'] ?? 0,
      title: json['title'] ?? '',
      icon: json['icon'],
      route: json['route'],
      typeMenu: json['typeMenu'] ?? '',
    );
  }
}
