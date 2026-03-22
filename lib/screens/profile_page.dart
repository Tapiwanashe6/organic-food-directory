import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:organic_food_directory/bloc/profile/profile_bloc.dart';
import 'package:organic_food_directory/bloc/profile/profile_event.dart';
import 'package:organic_food_directory/bloc/profile/profile_state.dart';
import 'package:organic_food_directory/bloc/auth/auth_bloc.dart';
import 'package:organic_food_directory/bloc/auth/auth_event.dart';
import 'package:organic_food_directory/bloc/auth/auth_state.dart';
import 'package:organic_food_directory/widgets/notification_icon_button.dart';
import 'package:organic_food_directory/widgets/guest_view_placeholder.dart';
import 'package:organic_food_directory/utils/notification_dialog_helper.dart';
import 'package:organic_food_directory/services/cloudinary_service.dart';
import 'package:organic_food_directory/repositories/user_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final UserRepository _userRepository = UserRepository();
  bool _isUploading = false;

  /// Handle profile picture upload
  /// Picks image from gallery, uploads to Cloudinary, and saves URL to Firestore
  Future<void> _uploadProfilePicture() async {
    try {
      if (mounted) {
        setState(() => _isUploading = true);
      }

      // Pick and upload image to Cloudinary
      final imageUrl = await _cloudinaryService.pickAndUploadImage();

      // Update user profile picture in Firestore
      await _userRepository.updateProfilePictureUrl(imageUrl);

      // Reload profile to show updated picture
      if (mounted) {
        context.read<ProfileBloc>().add(LoadProfileEvent());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture uploaded successfully!'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on Exception catch (e) {
      // Handle specific errors
      final errorString = e.toString();
      
      String errorMessage = 'Failed to upload profile picture';
      if (errorString.contains('No image selected')) {
        errorMessage = 'No image selected';
      } else if (errorString.contains('Network error')) {
        errorMessage = 'Network error: Unable to connect';
      } else if (errorString.contains('timeout')) {
        errorMessage = 'Upload timeout: Please try again';
      } else if (errorString.contains('status')) {
        errorMessage = 'Cloudinary error: ${errorString.substring(errorString.indexOf('status'))}';
      } else {
        // Show the actual error for debugging
        errorMessage = errorString;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isGuest = authState is! AuthSuccess;
        
        if (isGuest) {
          return GuestViewPlaceholder(
            iconType: 'person',
            message: 'Sign In to View Profile',
            submessage: 'Please sign in to view and manage your profile',
            onSignIn: () => Navigator.pushReplacementNamed(context, '/login'),
          );
        }
        
        context.read<ProfileBloc>().add(LoadProfileEvent());
        return BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded && state.user.notificationCount > 0 && state.user.notificationCount <= 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('New notification arrived! Check your notifications.'),
                  backgroundColor: const Color(0xFF2E7D32),
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'View',
                    textColor: Colors.white,
                    onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  ),
                ),
              );
            }
          },
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is ProfileLoaded) {
                final user = state.user;
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Profile'),
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: NotificationIconButton(
                          showBackground: false,
                          color: Colors.white,
                          onPressed: () {
                            NotificationDialogHelper.showNotificationsDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFFF8F9FA),
                  body: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(13),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    // Profile picture avatar
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.green[100],
                                      backgroundImage: user.profilePicture != null && user.profilePicture!.isNotEmpty
                                          ? NetworkImage(user.profilePicture!)
                                          : null,
                                      child: user.profilePicture == null || user.profilePicture!.isEmpty
                                          ? const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Color(0xFF2E7D32),
                                            )
                                          : null,
                                    ),
                                    // Upload button overlay
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _isUploading ? null : _uploadProfilePicture,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF2E7D32),
                                            shape: BoxShape.circle,
                                          ),
                                          child: _isUploading
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.cloud_upload_outlined,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B5E20),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap the upload icon to change profile picture',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        user.email,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                    ),
                                    if (user.isEmailVerified)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.verified, color: Color(0xFF2E7D32), size: 14),
                                              SizedBox(width: 4),
                                              Text(
                                                'Verified',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2E7D32),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _statItem('12', 'Orders'),
                                    Container(width: 1, height: 40, color: Colors.grey[200]),
                                    _statItem('5', 'Favorites'),
                                    Container(width: 1, height: 40, color: Colors.grey[200]),
                                    _statItem('3', 'My Lists'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _menuItem(context, icon: Icons.person_outline, label: 'Edit Profile', route: '/edit-profile'),
                          _menuItem(context, icon: Icons.favorite_outline, label: 'Favorites', route: '/favorites', isWhite: true),
                          _menuItem(context, icon: Icons.list_alt_outlined, label: 'My Lists', route: '/my-list'),
                          _menuItem(context, icon: Icons.open_in_new_outlined, label: 'External Links', route: '/external-link'),
                          const SizedBox(height: 24),
                          const Text(
                            'Preferences',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _menuItem(
                            context,
                            icon: Icons.notifications_outlined,
                            label: 'Notifications',
                            onTap: () => NotificationDialogHelper.showNotificationsDialog(context),
                          ),
                          _menuItem(context, icon: Icons.lock_outline, label: 'Privacy & Security', route: '/privacy-security'),
                          _menuItem(context, icon: Icons.help_outline, label: 'Help & Support', route: '/help-support'),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                context.read<AuthBloc>().add(LogoutEvent());
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              icon: const Icon(Icons.logout, color: Colors.red),
                              label: const Text('Log Out', style: TextStyle(color: Colors.red, fontSize: 16)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const Scaffold(
                body: Center(child: Text('Error loading profile')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? route,
    VoidCallback? onTap,
    bool isWhite = false,
  }) {
    return GestureDetector(
      onTap: onTap ?? (route != null ? () => Navigator.pushNamed(context, route) : null),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isWhite ? const Color(0xFF2E7D32) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isWhite ? Colors.white.withOpacity(0.2) : Colors.green[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isWhite ? Colors.white : const Color(0xFF2E7D32), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isWhite ? Colors.white : const Color(0xFF1B5E20),
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: isWhite ? Colors.white.withOpacity(0.7) : Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
