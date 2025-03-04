import 'package:flutter/material.dart';
import 'package:medical_reminder_app/data/health_condition_provider.dart';
import 'package:medical_reminder_app/notification_page.dart';
import 'package:provider/provider.dart';
import 'data/reminder_data.dart';
import 'login_page.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Global instance of FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Global navigator key for handling notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _initializeNotifications() async {
  tz.initializeTimeZones(); // Ensure timezones are initialized

  // Create Android notification channel
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
    const AndroidNotificationChannel(
      'medication_channel',
      'Medication Reminders',
      description: 'Reminders for medication',
      importance: Importance.high,
    ),
  );

  // Android-specific initialization
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // General initialization settings
  final InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
  );

  // Initialize notifications plugin
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle the notification response here
      if (response.payload != null) {
        print('Notification payload: ${response.payload}');
        // Navigate to the desired page
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => NotificationPage()),
        );
      }
    },
  );
}

void requestNotificationPermission() async {
  final bool? granted = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  if (granted != null && granted) {
    print("Notification permission granted");
  } else {
    print("Notification permission denied");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  requestNotificationPermission();
  await _initializeNotifications(); // Initialize before app runs

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (context) => HealthConditionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      theme: ThemeData(primarySwatch: Colors.green),
      navigatorKey: navigatorKey, // Use navigator key
      home: const LoginPage(),
    );
  }
}
