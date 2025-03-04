import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/reminder_data.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController(); // Free-form dosage input
  DateTime? _startDate;

  final Map<String, TimeOfDay?> _selectedTimes = {
    "Morning": null,
    "Noon": null,
    "Night": null,
  };

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context, String period) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTimes[period] = picked);
    }
  }

  void _saveReminder() {
    if (_medicineController.text.isEmpty ||
        _startDate == null ||
        _durationController.text.isEmpty ||
        _dosageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final int duration = int.tryParse(_durationController.text) ?? 0;

    if (duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Duration must be greater than 0")),
      );
      return;
    }

    Reminder reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000), // Generates a unique ID
      medicine: _medicineController.text,
      startDate: _startDate!,
      duration: duration,
      dosage: _dosageController.text, // Store descriptive dosage
      selectedTimes: Map<String, TimeOfDay?>.from(_selectedTimes),
    );

    Provider.of<ReminderProvider>(context, listen: false).addReminder(reminder);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Reminder")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _medicineController,
              decoration: const InputDecoration(labelText: "Medicine Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    decoration: const InputDecoration(labelText: "Duration (days)", border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectStartDate(context),
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: _startDate == null ? "Start Date" : "${_startDate!.toLocal()}".split(' ')[0],
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: "Dosage Instructions (e.g., '1 tablet after/before a meal')",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: _selectedTimes.keys.map((period) {
                return CheckboxListTile(
                  title: Text(period),
                  value: _selectedTimes[period] != null,
                  onChanged: (bool? value) {
                    if (value == true) {
                      _selectTime(context, period);
                    } else {
                      setState(() => _selectedTimes[period] = null);
                    }
                  },
                  subtitle: _selectedTimes[period] != null
                      ? Text("Time: ${_selectedTimes[period]!.format(context)}")
                      : null,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveReminder,
              child: const Text("Save Reminder"),
            ),
          ],
        ),
      ),
    );
  }
}


