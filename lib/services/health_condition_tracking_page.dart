import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/data/health_condition_provider.dart';

class HealthConditionTrackingPage extends StatefulWidget {
  @override
  _HealthConditionTrackingPageState createState() => _HealthConditionTrackingPageState();
}

class _HealthConditionTrackingPageState extends State<HealthConditionTrackingPage> {
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _bloodPressureController = TextEditingController();

  void _saveVitals(BuildContext context) {
    if (_temperatureController.text.isNotEmpty &&
        _weightController.text.isNotEmpty &&
        _heightController.text.isNotEmpty &&
        _bloodPressureController.text.isNotEmpty) {
      Provider.of<HealthConditionProvider>(context, listen: false).updateVitals(
        temperature: _temperatureController.text,
        weight: _weightController.text,
        height: _heightController.text,
        bloodPressure: _bloodPressureController.text,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final vitals = Provider.of<HealthConditionProvider>(context).vitals;

    return Scaffold(
      appBar: AppBar(title: const Text("Health Vitals Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _temperatureController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Temperature (°C)"),
            ),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Weight (kg)"),
            ),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: "Height (cm or inches)"),
            ),
            TextField(
              controller: _bloodPressureController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: "Blood Pressure (e.g., 120/80)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveVitals(context),
              child: const Text("Save Vitals"),
            ),
            const SizedBox(height: 20),
            if (vitals.temperature.isNotEmpty)
              Card(
                color: Colors.green[800],
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Health Report", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      Divider(color: Colors.white),
                      Text("Temperature: ${vitals.temperature} °C", style: TextStyle(fontSize: 16, color: Colors.white)),
                      Text("Weight: ${vitals.weight} kg", style: TextStyle(fontSize: 16, color: Colors.white)),
                      Text("Height: ${vitals.height}", style: TextStyle(fontSize: 16, color: Colors.white)),
                      Text("Blood Pressure: ${vitals.bloodPressure}", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}




