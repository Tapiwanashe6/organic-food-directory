import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_bloc.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_event.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_state.dart';
import 'package:organic_food_directory/bloc/auth/auth_bloc.dart';
import 'package:organic_food_directory/bloc/auth/auth_state.dart';
import 'package:organic_food_directory/models/product_model.dart';
import 'package:organic_food_directory/widgets/guest_view_placeholder.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesBloc>().add(LoadFavoritesEvent());
  }

  void _removeFavorite(String productId) {
    context.read<FavoritesBloc>().add(ToggleFavoriteEvent(productId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isGuest = authState is! AuthSuccess;
        
        if (isGuest) {
          return _buildGuestView();
        }
        
        return _buildLoggedInView();
      },
    );
  }

  Widget _buildGuestView() {
    return GuestViewPlaceholder(
      iconType: 'favorite',
      message: 'Sign In to View Favorites',
      submessage: 'Please sign in to see and manage your favorite products',
      onSignIn: () => Navigator.pushReplacementNamed(context, '/login'),
    );
  }

  Widget _buildLoggedInView() {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        if (state is FavoritesLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is FavoritesLoaded) {
          final favorites = state.favorites;
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Favorites',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${favorites.length} items',
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    favorites.isEmpty
                        ? _emptyState()
                        : Expanded(
                            child: ListView.builder(
                              itemCount: favorites.length,
                              itemBuilder: (context, index) {
                                final item = favorites[index];
                                return _favoriteCard(item, index);
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        }
        return const Scaffold(
          body: Center(child: Text('Error loading favorites')),
        );
      },
    );
  }

  Widget _favoriteCard(ProductModel item, int index) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _removeFavorite(item.id),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/product'),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(item.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${item.sub} • ${item.price}'),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _removeFavorite(item.id),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse products and add your favorites',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/home'),
            icon: const Icon(Icons.shopping_bag, color: Colors.white),
            label: const Text('Browse Products', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
