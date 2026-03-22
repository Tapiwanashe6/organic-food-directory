import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;

  const CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(id: id, name: map['name'] ?? '');
  }

  @override
  List<Object?> get props => [id, name];
}