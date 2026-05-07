class PortalMenu {
  final int menuId;
  final String title;
  final String? icon;
  final String? route;
  final int orderIndex;
  final String typeMenu;
  final List<PortalMenu> children;

  PortalMenu({
    required this.menuId,
    required this.title,
    this.icon,
    this.route,
    required this.orderIndex,
    required this.typeMenu,
    required this.children,
  });

  factory PortalMenu.fromJson(Map<String, dynamic> json) {
    return PortalMenu(
      menuId: json['menuId'] ?? 0,
      title: json['title'] ?? '',
      icon: json['icon'],
      route: json['route'],
      orderIndex: json['orderIndex'] ?? 0,
      typeMenu: json['typeMenu'] ?? '',
      children: json['children'] != null
          ? (json['children'] as List).map((i) => PortalMenu.fromJson(i)).toList()
          : [],
    );
  }
}
