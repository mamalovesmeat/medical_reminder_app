import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SymptomTrackerPage extends StatefulWidget {
  @override
  _SymptomTrackerPageState createState() => _SymptomTrackerPageState();
}

class _SymptomTrackerPageState extends State<SymptomTrackerPage> {
  final List<Map<String, dynamic>> symptoms = [
    {"name": "Headache", "emoji": "🤕"},
    {"name": "Nausea", "emoji": "🤢"},
    {"name": "Dizziness", "emoji": "💫"},
    {"name": "Fatigue", "emoji": "😴"},
    {"name": "Fever", "emoji": "🤒"},
    {"name": "Stomach Pain", "emoji": "🤮"},
    {"name": "Swelling", "emoji": "🤕"},
    {"name": "Diarrhea", "emoji": "💩"},
    {"name": "Skin Rash", "emoji": "🌿"},
    {"name": "Bleeding", "emoji": "🩸"},
  ];
  Map<String, Set<String>> dailyRecords = {};
  Set<String> selectedSymptoms = {};
  TextEditingController otherSymptomController = TextEditingController();
  TextEditingController medicationController = TextEditingController();

  void _toggleSymptom(String symptom) {
    setState(() {
      if (selectedSymptoms.contains(symptom)) {
        selectedSymptoms.remove(symptom);
      } else {
        selectedSymptoms.add(symptom);
      }
    });
  }

  void _saveRecord() {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (otherSymptomController.text.isNotEmpty) {
      selectedSymptoms.add(otherSymptomController.text);
    }
    setState(() {
      dailyRecords[today] = Set.from(selectedSymptoms);
      selectedSymptoms.clear();
      otherSymptomController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Symptoms saved for $today"))
    );
  }

  void _deleteRecord(String date) {
    setState(() {
      dailyRecords.remove(date);
    });
  }

  void _editRecord(String date) {
    setState(() {
      selectedSymptoms = Set.from(dailyRecords[date] ?? {});
    });
  }

  void _showSummary() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Symptom Summary"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: dailyRecords.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  subtitle: Text("Symptoms: ${entry.value.join(", ")}\nMedication: ${medicationController.text}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _editRecord(entry.key);
                          Navigator.pop(context);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteRecord(entry.key);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: symptoms.length,
                      itemBuilder: (context, index) {
                        String symptom = symptoms[index]["name"];
                        String emoji = symptoms[index]["emoji"];
                        bool isSelected = selectedSymptoms.contains(symptom);
                        return GestureDetector(
                          onTap: () => _toggleSymptom(symptom),
                          child: Card(
                            color: isSelected ? Colors.green : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              //side: BorderSide(color: Colors.black),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  emoji,
                                  style: TextStyle(fontSize: 30),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  symptom,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: otherSymptomController,
                      decoration: InputDecoration(
                        labelText: "Other Symptoms",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: medicationController,
                      decoration: InputDecoration(
                        labelText: "Current Medications",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "If you experience severe allergies or symptoms, please seek or call a medical doctor.",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveRecord,
                      child: Text("Save Today's Symptoms"),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showSummary,
                      child: Text("View Summary"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
