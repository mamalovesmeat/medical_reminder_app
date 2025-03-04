import 'package:flutter/material.dart';

class Reminder {
  final int id;
  final String medicine;
  final DateTime startDate;
  final int duration;
  final String dosage;
  final Map<String, TimeOfDay?> selectedTimes;

  Map<DateTime, Map<String, bool>> takenStatus;

  Reminder({
    required this.id,
    required this.medicine,
    required this.startDate,
    required this.duration,
    required this.dosage,
    required this.selectedTimes,
  }) : takenStatus = {};

  bool isTakenForDate(DateTime date) {
    return takenStatus[DateTime(date.year, date.month, date.day)]
            ?.values
            .every((status) => status) ?? false;
  }
}

class SymptomEntry {
  final String medicine;
  final String symptom;
  final DateTime date;
  

  SymptomEntry({
    required this.medicine,
    required this.symptom,
    required this.date,
    
  });
}

class ReminderProvider extends ChangeNotifier {
  final List<Reminder> _reminders = [];
  final List<SymptomEntry> _symptomLogs = [];

  List<Reminder> get reminders => _reminders;
  List<SymptomEntry> get symptomLogs => _symptomLogs;

  // Add a new reminder
  void addReminder(Reminder reminder) {
    _reminders.add(reminder);
    notifyListeners();
  }

  // Get reminders for a specific date
  List<Reminder> getRemindersForDate(DateTime date) {
    return _reminders.where((reminder) {
      DateTime endDate = reminder.startDate.add(Duration(days: reminder.duration));
      return (date.isAtSameMomentAs(reminder.startDate) ||
          (date.isAfter(reminder.startDate) && date.isBefore(endDate)));
    }).toList();
  }

  // Mark a reminder as taken for a specific date and time period
  void markReminderAsTaken(Reminder reminder, DateTime date, String period, bool isTaken) {
    DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    if (!reminder.takenStatus.containsKey(normalizedDate)) {
      reminder.takenStatus[normalizedDate] = {};
    }
    reminder.takenStatus[normalizedDate]![period] = isTaken;
    notifyListeners();
  }

  // Toggle taken status for a specific date and time period
  void toggleTaken(Reminder reminder, DateTime date, String period) {
    if (!reminder.takenStatus.containsKey(date)) {
      reminder.takenStatus[date] = {};
    }
    reminder.takenStatus[date]![period] = !(reminder.takenStatus[date]![period] ?? false);
    notifyListeners();
  }

  // Mark all medicine doses for a specific day as taken
  void markReminderAsTakenForDay(Reminder reminder, DateTime date, bool isTaken) {
    DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    if (!reminder.takenStatus.containsKey(normalizedDate)) {
      reminder.takenStatus[normalizedDate] = {'Morning': false, 'Noon': false, 'Night': false};
    }
    reminder.takenStatus[normalizedDate]!.updateAll((key, value) => isTaken);
    notifyListeners();
  }

  // Update an existing reminder
  void updateReminder(Reminder updatedReminder) {
    int index = _reminders.indexWhere((r) => r.id == updatedReminder.id);
    if (index != -1) {
      _reminders[index] = updatedReminder;
      notifyListeners();
    }
  }

  // Delete a reminder
  void deleteReminder(Reminder reminder) {
    _reminders.remove(reminder);
    notifyListeners();
  }

  // Add a symptom entry (Fixed Syntax Error)
  void logSymptom(String medicine, String symptom,DateTime date) {
    _symptomLogs.add(SymptomEntry(
      medicine: medicine,
      symptom: symptom,
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  // Get symptom logs for a specific medicine
  List<SymptomEntry> getSymptomsForMedicine(String medicine) {
    return _symptomLogs.where((entry) => entry.medicine == medicine).toList();
  }

  // Delete a symptom entry
  void deleteSymptom(SymptomEntry entry) {
    _symptomLogs.remove(entry);
    notifyListeners();
  }

  // Update an existing symptom entry (Fixed missing `painIntensity`)
  void updateSymptom(int index, String newSymptom) {
    if (index >= 0 && index < _symptomLogs.length) {
      _symptomLogs[index] = SymptomEntry(
        medicine: _symptomLogs[index].medicine,
        symptom: newSymptom,
        date: _symptomLogs[index].date, // Keep the original date
         // Keep the pain level
      );
      notifyListeners();
    }
  }
}