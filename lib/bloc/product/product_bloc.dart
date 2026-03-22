import 'package:bloc/bloc.dart';
import '../../repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repository;

  ProductBloc({required ProductRepository repository})
      : _repository = repository,
        super(ProductInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<SearchProductsEvent>(_onSearch);
    on<LoadProductDetailEvent>(_onLoadDetail);
  }

  Future<void> _onLoadProducts(LoadProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _repository.getAllProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearch(SearchProductsEvent event, Emitter<ProductState> emit) async {
    try {
      String query = event.query.toLowerCase().trim();
      
      // If query is empty, load all products
      if (query.isEmpty) {
        final allProducts = await _repository.getAllProducts();
        emit(ProductLoaded(allProducts));
        return;
      }
      
      // Try repository search first
      final products = await _repository.searchProducts(query);
      
      // If repository search returns results, use them
      if (products.isNotEmpty) {
        emit(ProductLoaded(products));
      } else {
        // Fallback: filter all products locally
        final allProducts = await _repository.getAllProducts();
        final filtered = allProducts.where((product) {
          return product.name.toLowerCase().contains(query) ||
                 product.sub.toLowerCase().contains(query) ||
                 product.category.toLowerCase().contains(query);
        }).toList();
        emit(ProductLoaded(filtered));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadDetail(LoadProductDetailEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final product = await _repository.getProduct(event.id);
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}