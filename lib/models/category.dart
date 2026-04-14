class WishCategory {
  final String id;
  final String name;
  final String icon;
  final int colorValue;

  WishCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'icon': icon,
    'color_value': colorValue,
  };

  factory WishCategory.fromMap(Map<String, dynamic> map) => WishCategory(
    id: map['id'],
    name: map['name'],
    icon: map['icon'],
    colorValue: map['color_value'],
  );
}
