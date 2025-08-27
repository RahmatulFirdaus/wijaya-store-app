import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Panggil ini di main() sebelum runApp()
  static Future<void> init() async {
    await Firebase.initializeApp();

    // Request permission Android 13+ dan iOS
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Setup plugin local notification
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotifications.initialize(initSettings);

    // Listener notifikasi ketika app di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(
          message.notification?.title ?? '',
          message.notification?.body ?? '',
        );
      }
    });

    // 🔑 Tambahkan listener untuk refresh token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("[DEBUG] Refresh FCM token: $newToken");
      await saveTokenToBackend();
    });
  }

  /// Tampilkan notifikasi lokal (foreground)
  static Future<void> _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'promo_channel',
      'Promosi',
      channelDescription: 'Notifikasi promosi dan update data',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notifDetails = NotificationDetails(android: androidDetails);
    await _localNotifications.show(0, title, body, notifDetails);
  }

  /// Ambil token FCM terbaru
  static Future<String?> getToken() => _messaging.getToken();

  /// Simpan token FCM ke backend setelah login
  static Future<void> saveTokenToBackend() async {
    const storage = FlutterSecureStorage();
    final tokenJwt = await storage.read(key: 'token'); // JWT login
    final userId = await storage.read(key: 'id'); // ID user dari login
    final fcmToken = await getToken();

    print('[DEBUG] tokenJwt: $tokenJwt, userId: $userId, fcmToken: $fcmToken');

    final url = Uri.parse(
      'http://192.168.1.96:3000/api/users/$userId/fcm-token',
    );

    await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tokenJwt',
      },
      body: jsonEncode({'fcm_token': fcmToken}),
    );
  }
}
