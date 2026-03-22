import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object> get props => [];
}

class LoadProductsEvent extends ProductEvent {}

class SearchProductsEvent extends ProductEvent {
  final String query;
  const SearchProductsEvent(this.query);
  @override
  List<Object> get props => [query];
}

class LoadProductDetailEvent extends ProductEvent {
  final String id;
  const LoadProductDetailEvent(this.id);
  @override
  List<Object> get props => [id];
}