import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // Callback for notification tap
  Function(String?)? onNotificationTap;

  // Notification counter for unique IDs
  int _notificationId = 0;

  // List of pending notifications
  final List<Map<String, dynamic>> _notificationsList = [];

  // Count notifier for UI updates
  final ValueNotifier<int> _notificationCountNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> get notificationCountNotifier => _notificationCountNotifier;

  // Notifier for notifications list changes
  final ValueNotifier<List<Map<String, dynamic>>> _notificationsListNotifier = 
      ValueNotifier<List<Map<String, dynamic>>>([]);
  ValueNotifier<List<Map<String, dynamic>>> get notificationsListNotifier => _notificationsListNotifier;

  // Helper method to update both list and count notifiers
  void _updateNotifiers() {
    _notificationsListNotifier.value = List.from(_notificationsList);
    _notificationCountNotifier.value = _notificationsList.length;
  }

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (onNotificationTap != null) {
      onNotificationTap!(response.payload);
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final id = ++_notificationId;
    
    const androidDetails = AndroidNotificationDetails(
      'organic_food_channel',
      'Organic Food Notifications',
      channelDescription: 'Notifications for organic food updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
    
    // Add to notifications list
    _notificationsList.add({
      'id': id,
      'title': title,
      'body': body,
      'time': DateTime.now(),
    });
    
    // Update notifiers
    _updateNotifiers();
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
    String? payload,
  }) async {
    final id = ++_notificationId;
    final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);

    const androidDetails = AndroidNotificationDetails(
      'organic_food_channel',
      'Organic Food Notifications',
      channelDescription: 'Notifications for organic food updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    // Add to notifications list
    _notificationsList.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledTime': DateTime.now().add(delay),
    });
    
    // Update notifiers
    _updateNotifiers();
  }

  // Simulate 2 notifications 10 seconds apart after sign in
  Future<void> simulateNotificationsAfterSignIn() async {
    // First notification after 10 seconds
    await Future.delayed(const Duration(seconds: 10), () {
      showNotification(
        title: 'Welcome to Organic Food Directory!',
        body: 'Thank you for joining us. Explore fresh organic products now!',
        payload: 'welcome',
      );
    });

    // Second notification 10 seconds after the first
    await Future.delayed(const Duration(seconds: 10), () {
      showNotification(
        title: 'Special Offer Available!',
        body: 'Check out our latest deals on organic vegetables and fruits.',
        payload: 'offer',
      );
    });
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    _notificationsList.clear();
    _updateNotifiers();
  }

  // Clear notifications (mark as read) - removes badge but keeps history
  void clearBadge() {
    _notificationCountNotifier.value = 0;
  }

  // Delete a specific notification
  Future<void> deleteNotification(int id) async {
    _notificationsList.removeWhere((notification) => notification['id'] == id);
    await _notifications.cancel(id);
    _updateNotifiers();
  }

  // Get notifications list
  List<Map<String, dynamic>> getNotificationsList() {
    return List.from(_notificationsList);
  }

  // Dispose
  void dispose() {
    // Cleanup if needed
  }
}
