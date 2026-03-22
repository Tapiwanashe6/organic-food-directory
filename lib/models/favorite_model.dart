import 'package:equatable/equatable.dart';

class FavoriteModel extends Equatable {
  final String productId;

  const FavoriteModel({required this.productId});

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(productId: map['productId'] ?? '');
  }

  @override
  List<Object?> get props => [productId];
}