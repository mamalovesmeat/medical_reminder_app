import 'package:flutter/material.dart';
import 'package:medical_reminder_app/reminder_page.dart';
import 'package:medical_reminder_app/services/dosage_tracking.dart';
import 'package:medical_reminder_app/services/symptom_tracker_page.dart';
import 'services/health_condition_tracking_page.dart';
import 'package:medical_reminder_app/services/profile_page.dart';
//import 'package:medical_reminder_app/services/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'data/reminder_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  final Map<String, Color> _medicineColors = {};
  final List<Color> _availableColors = [
    Colors.red, Colors.blue, Colors.green, Colors.orange,
    Colors.purple, Colors.pink, Colors.teal, Colors.brown,
  ];

  Color _getMedicineColor(String medicine) {
    if (!_medicineColors.containsKey(medicine)) {
      _medicineColors[medicine] = _availableColors[_medicineColors.length % _availableColors.length];
    }
    return _medicineColors[medicine]!;
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider = context.watch<ReminderProvider>();
    final remindersForSelectedDay = reminderProvider.getRemindersForDate(_selectedDay);

    Map<String, List<Reminder>> categorizedReminders = {
      "Morning": [],
      "Noon": [],
      "Night": [],
    };

    for (var reminder in remindersForSelectedDay) {
      reminder.selectedTimes.forEach((period, time) {
        if (time != null) {
          categorizedReminders[period]?.add(reminder);
        }
      });
    }
    void _showDeleteConfirmation(ReminderProvider reminderProvider, Reminder reminder) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Delete Reminder"),
        content: const Text("Are you sure you want to delete this reminder?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              reminderProvider.deleteReminder(reminder);
              Navigator.pop(context); // Close dialog
              setState(() {}); // Update UI
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

   Widget buildReminderSection(String title, List<Reminder> reminders) {
    final reminderProvider = context.read<ReminderProvider>();
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (reminders.isNotEmpty) ...[
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        ...reminders.map((reminder) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reminder.medicine, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Dosage: ${reminder.dosage}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green)),
                  const SizedBox(height:3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Time: ${reminder.selectedTimes[title]?.format(context) ?? 'N/A'}"),
                      Row(
                        children: [
                          Checkbox(
                            value: reminder.takenStatus[_selectedDay]?[title] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                reminderProvider.toggleTaken(reminder, _selectedDay, title);
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmation(reminderProvider, reminder);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    ],
  );
}


    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          onSelected: (value) {
            if (value == 'Profile') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
            } else if (value == 'Symptom Journal') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SymptomTrackerPage()));
            }
          },
          itemBuilder: (context) => ['Profile', 'Symptom Journal']
              .map((choice) => PopupMenuItem<String>(value: choice, child: Text(choice)))
              .toList(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => print("Settings Pressed")),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                "Welcome",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006400)),
              ),
              const Text("How do you feel today?", style: TextStyle(fontSize: 15)),
              const SizedBox(height: 20),
              TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => reminderProvider.getRemindersForDate(day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) => setState(() => _calendarFormat = format),
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        bottom: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: events
                              .cast<Reminder>()
                              .map((reminder) => Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: _getMedicineColor(reminder.medicine),
                                  ))
                              .toList(),
                        ),
                      );
                    }
                    return const SizedBox();
                    },
                ),
              ),
              const SizedBox(height: 20),
              buildReminderSection("Morning", categorizedReminders["Morning"]!),
              buildReminderSection("Noon", categorizedReminders["Noon"]!),
              buildReminderSection("Night", categorizedReminders["Night"]!),
              if (remindersForSelectedDay.isEmpty)
                const Text("No reminders today", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              heroTag: "dosage_tracking",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DosingTrackingPage()));
              },
              backgroundColor: Color(0xFF006400),
              foregroundColor: Colors.white,
              child: const Icon(Icons.history),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: "health_condition_tracking",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HealthConditionTrackingPage()));
              },
              backgroundColor: Color(0xFF006400),
              foregroundColor: Colors.white,
              child: const Icon(Icons.medical_services),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FloatingActionButton(
                heroTag: "add_reminder",
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => ReminderPage()));
                  setState(() {});
                },
                backgroundColor: Color(0xFF006400),
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
    
  }
}