import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Get user name from AuthBloc
        String userName = 'User';
        if (authState is AuthSuccess) {
          userName = authState.user.name;
        }

        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductInitial) {
              context.read<ProductBloc>().add(LoadProductsEvent());
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is ProductLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final products = state is ProductLoaded ? state.products : [];
        
            return Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $userName👋',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              Text(
                                'Find your fresh organic food',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: NotificationIconButton(
                              showBackground: false,
                              color: const Color(0xFF1B5E20),
                              onPressed: () {
                                NotificationDialogHelper.showNotificationsDialog(context);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/search-results'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
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
                              const Icon(Icons.search,
                                  color: Color(0xFF1B5E20)),
                              const SizedBox(width: 10),
                              Text(
                                'Search organic products...',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 16),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.tune,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/category'),
                            child: const Text(
                              'See All',
                              style: TextStyle(color: Color(0xFF2E7D32)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _categoryItem(
                                'Vegetables',
                                Icons.eco_outlined,
                                Colors.green[50]!,
                                context),
                            _categoryItem(
                                'Fruits',
                                Icons.apple_outlined,
                                Colors.orange[50]!,
                                context),
                            _categoryItem(
                                'Dairy',
                                Icons.egg_outlined,
                                Colors.yellow[50]!,
                                context),
                            _categoryItem(
                                'Grains',
                                Icons.grass_outlined,
                                Colors.brown[50]!,
                                context),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Featured Products',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'See All',
                              style: TextStyle(color: Color(0xFF2E7D32)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.75,
                        children: products.isEmpty
                            ? [
                                _productItem('Organic Spinach', 'Fresh greens',
                                    '\$4.50', 'assets/spinach.png', 'spinach-1', context),
                                _productItem('Red Tomatoes', 'Organic farm',
                                    '\$3.20', 'assets/tomatoes.png', 'tomato-1', context),
                                _productItem('Sweet Apples', 'Fresh fruits',
                                    '\$5.10', 'assets/apples.png', 'apple-1', context),
                                _productItem('Brown Eggs', 'Cage free', '\$6.50',
                                    'assets/eggs.png', 'eggs-1', context),
                              ]
                            : products
                                .take(4)
                                .map((p) => _productItem(p.name, p.sub, p.price,
                                    p.image, p.id, context))
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }



  Widget _categoryItem(
    String name,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/category'),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: const Color(0xFF1B5E20), size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _productItem(
    String name,
    String sub,
    String price,
    String img,
    String productId,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product'),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                width: double.infinity,
                child: const Center(
                  child: Icon(Icons.image, size: 50, color: Colors.green),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Row(
                        children: [
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              return BlocBuilder<FavoritesBloc, FavoritesState>(
                                builder: (context, state) {
                                  final isFavorite = state is FavoritesLoaded &&
                                      state.favorites.any((p) => p.id == productId);
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
                                        context
                                            .read<FavoritesBloc>()
                                            .add(ToggleFavoriteEvent(productId));
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE8F5E9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: const Color(0xFF2E7D32),
                                        size: 18,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/product'),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

