import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'data/reminder_data.dart'; // Import ReminderProvider

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medication_channel',
      'Medication Reminders',
      description: 'Reminders for medication',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  Future<void> onDidReceiveNotificationResponse(NotificationResponse response) async {
    if (response.payload != null) {
      // Handle the notification payload here
      print('Notification payload: ${response.payload}');
    }
  }

  Future<void> _scheduleNotification(Reminder reminder, String period, TimeOfDay? time) async {
    if (time == null) return;

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the scheduled time is in the past, schedule it for the next day
    final tzScheduledDate = scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        reminder.id, // Ensure unique ID for each reminder
        'Medication Reminder',
        'Time to take your medicine!',
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_channel',
            'Medication Reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  void _scheduleAllReminders(List<Reminder> reminders) {
    for (var reminder in reminders) {
      reminder.selectedTimes.forEach((period, time) {
        _scheduleNotification(reminder, period, time);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminders = Provider.of<ReminderProvider>(context).getRemindersForDate(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text("Medication Reminder")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return Card(
                  child: ListTile(
                    title: Text(reminder.medicine),
                    subtitle: Text("Dosage: ${reminder.dosage}"),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _scheduleAllReminders([reminder]);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Reminder Scheduled!")),
                        );
                      },
                      child: Text("Schedule"),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}