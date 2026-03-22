import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String sub;
  final String price;
  final String category;
  final String image;

  const ProductModel({
    required this.id,
    required this.name,
    required this.sub,
    required this.price,
    required this.category,
    required this.image,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      sub: map['sub'] ?? '',
      price: map['price'] ?? '',
      category: map['category'] ?? '',
      image: map['image'] ?? 'assets/placeholder.png',
    );
  }

  @override
  List<Object?> get props => [id, name, sub, price, category, image];
}