import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  String? selectedGender;
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController residentialAddressController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController chronicConditionsController = TextEditingController();
  final TextEditingController currentMedicationsController = TextEditingController();
  final TextEditingController pastMedicalHistoryController = TextEditingController();
  final TextEditingController familyMedicalHistoryController = TextEditingController();
  final TextEditingController nextOfKinController = TextEditingController();
  final TextEditingController nextOfKinContactController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dateOfBirthController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildCategoryCard("Personal Details", [
                  buildTextField("First Name", firstNameController),
                  buildTextField("Middle Name", middleNameController),
                  buildTextField("Last Name", lastNameController),
                  buildDatePicker("Date of Birth", dateOfBirthController),
                  buildDropdown("Gender", ["Male", "Female"]),
                ]),
                buildCategoryCard("Contact Details", [
                  buildTextField("Phone Number", phoneNumberController),
                  buildTextField("Email", emailController),
                  buildTextField("Residential Address", residentialAddressController),
                ]),
                buildCategoryCard("Medical Details", [
                  buildTextField("Blood Group", bloodGroupController),
                  buildTextField("Allergies", allergiesController, isMultiline: true),
                  buildTextField("Chronic Conditions", chronicConditionsController, isMultiline: true),
                  buildTextField("Current Medications", currentMedicationsController, isMultiline: true),
                  buildTextField("Past Medical History", pastMedicalHistoryController, isMultiline: true),
                  buildTextField("Family Medical History", familyMedicalHistoryController, isMultiline: true),
                ]),
                buildCategoryCard("Emergency Contact", [
                  buildTextField("Next of Kin", nextOfKinController),
                  buildTextField("Next of Kin Contact", nextOfKinContactController),
                ]),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile Saved!')),
                      );
                    }
                  },
                  child: const Text('Save Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCategoryCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green[800],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isMultiline ? TextInputType.multiline : TextInputType.text,
        textInputAction: isMultiline ? TextInputAction.newline : TextInputAction.done,
        maxLines: isMultiline ? null : 1,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget buildDatePicker(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }

  Widget buildDropdown(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        value: selectedGender,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedGender = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a gender';
          }
          return null;
        },
      ),
    );
  }
}
