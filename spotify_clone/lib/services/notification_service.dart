// lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/song.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'music_player_channel';
  static const String _channelName = 'Music Player';
  static const String _channelDescription = 'Music Player Controls';

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.low,
      enableVibration: false,
      playSound: false,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showMusicNotification(Song song, bool isPlaying) async {
    final AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      showWhen: false,
      usesChronometer: false,
      category: AndroidNotificationCategory.transport,
      visibility: NotificationVisibility.public,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'play_pause',
          isPlaying ? 'Pause' : 'Play',
          icon: DrawableResourceAndroidBitmap(
            isPlaying ? 'ic_pause' : 'ic_play_arrow',
          ),
        ),
        AndroidNotificationAction(
          'stop',
          'Stop',
          icon: DrawableResourceAndroidBitmap('ic_stop'),
        ),
      ],
    );


    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
      categoryIdentifier: 'musicCategory',
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
    );


    await _flutterLocalNotificationsPlugin.show(
      1,
      song.title,
      song.artist,
      notificationDetails,
    );
  }

  Future<void> cancelNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(1);
  }

  void _onNotificationTapped(NotificationResponse response) {
    final String? actionId = response.actionId;
    
    if (actionId != null) {
      switch (actionId) {
        case 'play_pause':
          // Handle play/pause action
          _handlePlayPause();
          break;
        case 'stop':
          // Handle stop action
          _handleStop();
          break;
      }
    }
  }

  void _handlePlayPause() {
    // You'll need to implement this to communicate with your music player state
    // This could be done through a callback or by using a global state manager
  }

  void _handleStop() {
    // You'll need to implement this to communicate with your music player state
    // This could be done through a callback or by using a global state manager
  }
}