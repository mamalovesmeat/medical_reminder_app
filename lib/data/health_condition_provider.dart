import 'package:flutter/material.dart';

class HealthCondition {
  final String name;
  final String symptoms;
  final DateTime dateLogged;

  HealthCondition({
    required this.name,
    required this.symptoms,
    required this.dateLogged,
  });
}

class HealthVitals {
  String temperature;
  String weight;
  String height;
  String bloodPressure;

  HealthVitals({
    this.temperature = '',
    this.weight = '',
    this.height = '',
    this.bloodPressure = '',
  });
}

class HealthConditionProvider extends ChangeNotifier {
  final List<HealthCondition> _conditions = [];
  HealthVitals _vitals = HealthVitals();

  List<HealthCondition> get conditions => _conditions;
  HealthVitals get vitals => _vitals;

  void addCondition(String name, String symptoms) {
    final newCondition = HealthCondition(
      name: name,
      symptoms: symptoms,
      dateLogged: DateTime.now(),
    );
    _conditions.add(newCondition);
    notifyListeners();
  }

  void removeCondition(int index) {
    _conditions.removeAt(index);
    notifyListeners();
  }

  void updateVitals({
    required String temperature,
    required String weight,
    required String height,
    required String bloodPressure,
  }) {
    _vitals = HealthVitals(
      temperature: temperature,
      weight: weight,
      height: height,
      bloodPressure: bloodPressure,
    );
    notifyListeners();
  }
}