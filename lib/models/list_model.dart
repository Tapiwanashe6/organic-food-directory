import 'package:equatable/equatable.dart';

class ListModel extends Equatable {
  final String id;
  final String title;
  final List<String> items;
  final String color;
  final String icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ListModel({
    required this.id,
    required this.title,
    required this.items,
    this.color = 'green',
    this.icon = 'shopping_basket_outlined',
    required this.createdAt,
    required this.updatedAt,
  });

  ListModel copyWith({
    String? id,
    String? title,
    List<String>? items,
    String? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ListModel(
      id: id ?? this.id,
      title: title ?? this.title,
      items: items ?? this.items,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'items': items,
      'color': color,
      'icon': icon,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ListModel.fromMap(Map<String, dynamic> map) {
    return ListModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      items: List<String>.from(map['items'] ?? []),
      color: map['color'] ?? 'green',
      icon: map['icon'] ?? 'shopping_basket_outlined',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is DateTime 
              ? map['createdAt'] as DateTime
              : (map['createdAt'].runtimeType.toString().contains('Timestamp')
                  ? (map['createdAt'] as dynamic).toDate()
                  : DateTime.parse(map['createdAt'].toString())))
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is DateTime 
              ? map['updatedAt'] as DateTime
              : (map['updatedAt'].runtimeType.toString().contains('Timestamp')
                  ? (map['updatedAt'] as dynamic).toDate()
                  : DateTime.parse(map['updatedAt'].toString())))
          : DateTime.now(),
    );
  }

  @override
  List<Object> get props => [id, title, items, color, icon, createdAt, updatedAt];
}
