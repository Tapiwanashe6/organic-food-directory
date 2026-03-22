import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:organic_food_directory/models/product_model.dart';
import 'package:organic_food_directory/bloc/product/product_bloc.dart';
import 'package:organic_food_directory/bloc/product/product_event.dart';
import 'package:organic_food_directory/bloc/product/product_state.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_bloc.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_event.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_state.dart';
import 'package:organic_food_directory/bloc/auth/auth_bloc.dart';
import 'package:organic_food_directory/bloc/auth/auth_state.dart';
import 'package:organic_food_directory/widgets/notification_icon_button.dart';
import 'package:organic_food_directory/utils/notification_dialog_helper.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductInitial) {
          context.read<ProductBloc>().add(SearchProductsEvent(''));
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is ProductLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final results = state is ProductLoaded ? state.products : [];
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Color(0xFF1B5E20)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: (value) {
                  context.read<ProductBloc>().add(SearchProductsEvent(value));
                },
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon:
                      Icon(Icons.search, color: Color(0xFF1B5E20)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: NotificationIconButton(
                  showBackground: false,
                  color: const Color(0xFF1B5E20),
                  onPressed: () => NotificationDialogHelper.showNotificationsDialog(context),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search Results',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    itemCount: results.isEmpty ? 5 : results.length,
                    itemBuilder: (context, index) {
                      final p = results.isEmpty
                          ? ProductModel(
                              id: '',
                              name: index % 2 == 0
                                  ? 'Organic Broccoli'
                                  : 'Green Lettuce',
                              sub: 'Fresh Vegetable',
                              price: index % 2 == 0 ? '\$3.50' : '\$2.00',
                              category: '',
                              image: '',
                            )
                          : results[index];
                      return _searchResultItem(
                        p.id,
                        p.name,
                        p.sub,
                        p.price,
                        context,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _searchResultItem(
    String id,
    String name,
    String category,
    String price,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Colors.green,
                size: 40,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                return BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, state) {
                    final isFavorite = state is FavoritesLoaded &&
                        state.favorites.any((p) => p.id == id);
                    final isGuest = authState is! AuthSuccess;
                    return GestureDetector(
                      onTap: () {
                        if (isGuest) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Sign in to save favorites'),
                              backgroundColor: Colors.orange[700],
                              action: SnackBarAction(
                                label: 'Sign In',
                                textColor: Colors.white,
                                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                              ),
                            ),
                          );
                        } else {
                          context.read<FavoritesBloc>().add(ToggleFavoriteEvent(id));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isFavorite ? Colors.red[50] : Colors.green[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : const Color(0xFF2E7D32),
                          size: 20,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
