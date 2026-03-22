import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:organic_food_directory/bloc/auth/auth_bloc.dart';
import 'package:organic_food_directory/bloc/auth/auth_event.dart';
import 'package:organic_food_directory/screens/home_page.dart';
import 'package:organic_food_directory/screens/search_results_page.dart';
import 'package:organic_food_directory/screens/favorites_page.dart';
import 'package:organic_food_directory/screens/profile_page.dart';
import 'package:organic_food_directory/bloc/profile/profile_bloc.dart';
import 'package:organic_food_directory/bloc/profile/profile_state.dart';
import 'package:organic_food_directory/services/notification_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _notificationsTriggered = false;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Check auth state when MainScreen loads - with a small delay to ensure widget is ready
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        context.read<AuthBloc>().add(const CheckAuthStateEvent());
        // Trigger notifications 10 seconds after sign in
        _triggerNotifications();
      }
    });
  }

  void _triggerNotifications() {
    if (!_notificationsTriggered) {
      _notificationsTriggered = true;
      _notificationService.simulateNotificationsAfterSignIn();
    }
  }

  final List<Widget> _pages = [
    const HomePage(),
    const SearchResultsPage(),
    const FavoritesPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: _pages),
          bottomNavigationBar: ListenableBuilder(
            listenable: _notificationService.notificationCountNotifier,
            builder: (context, child) {
              return BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: const Color(0xFF2E7D32),
                unselectedItemColor: Colors.grey,
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: [
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.home_filled), label: 'Home'),
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.search), label: 'Search'),
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.favorite_outline), label: 'Favorites'),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'Profile',
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
