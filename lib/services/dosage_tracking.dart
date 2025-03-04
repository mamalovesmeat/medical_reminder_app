import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/reminder_data.dart';

class DosingTrackingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reminderProvider = context.watch<ReminderProvider>();
    final List<Reminder> reminders = reminderProvider.reminders;

    // Map to store medicine-wise tracking
    Map<String, int> medicineTakenDays = {};
    Map<String, int> medicineTotalDuration = {};
    
    // Collect all days where at least one medicine was taken
    for (var reminder in reminders) {
      int duration = reminder.duration; // Fixed issue
      medicineTotalDuration[reminder.medicine] = duration;

      int takenCount = reminder.takenStatus.values
          .where((status) => status.containsValue(true))
          .length;
      
      medicineTakenDays[reminder.medicine] = takenCount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dosage Tracking"),
      ),
      body: medicineTakenDays.isEmpty
          ? const Center(
              child: Text(
                "No medicines have been taken yet",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          : ListView(
              children: medicineTakenDays.entries.map((entry) {
                String medicineName = entry.key;
                int takenDays = entry.value;
                int totalDuration = medicineTotalDuration[medicineName] ?? 30; // Ensure default is 30
                double completionRate = (takenDays / totalDuration) * 100;
                bool achievedGoal = takenDays >= totalDuration;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      medicineName, // Display Medicine Name
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Completed: $takenDays / $totalDuration days"),
                        Text("Progress: ${completionRate.toStringAsFixed(1)}%"), // Display percentage
                        LinearProgressIndicator(value: takenDays / totalDuration),
                        achievedGoal
                            ? Text(
                                "🎉 Congrats! You've completed your dosage! 🔥",
                                style: TextStyle(fontSize: 16, color: Colors.green),
                              )
                            : Text(
                                "Keep going! You're making great progress! 😊",
                                style: TextStyle(fontSize: 14, color: Colors.orange),
                              ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
