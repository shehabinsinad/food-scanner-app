import 'package:flutter/material.dart';
import '../services/user_service.dart';

class UpdatePreferencesScreen extends StatefulWidget {
  const UpdatePreferencesScreen({Key? key}) : super(key: key);

  @override
  _UpdatePreferencesScreenState createState() => _UpdatePreferencesScreenState();
}

class _UpdatePreferencesScreenState extends State<UpdatePreferencesScreen> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  final List<String> allergensList = [
    "Peanuts",
    "Gluten",
    "Soy",
    "Dairy",
    "Eggs",
    "Tree Nuts"
  ];
  Set<String> selectedAllergies = {};

  final List<String> conditionsList = [
    "Diabetes",
    "Hypertension",
    "Gluten Intolerance",
    "Lactose Intolerance"
  ];
  Set<String> selectedConditions = {};

  bool _isLoading = true;

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[800],
      labelStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[600]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.yellow),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final data = await UserService().getUserData();
    setState(() {
      heightController.text = data["height"] ?? "";
      weightController.text = data["weight"] ?? "";
      selectedAllergies = (data["allergies"] ?? "")
          .split(",")
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toSet();
      selectedConditions = (data["conditions"] ?? "")
          .split(",")
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toSet();
      _isLoading = false;
    });
  }

  void _updatePreferences() async {
    // Ensure height and weight are provided.
    if (heightController.text.trim().isEmpty || weightController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Height and Weight are mandatory. Please enter both."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    String height = heightController.text.trim();
    String weight = weightController.text.trim();
    String allergies = selectedAllergies.join(", ");
    String conditions = selectedConditions.join(", ");
    await UserService().saveUserData(height, weight, allergies, conditions);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Preferences Updated")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Preferences")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  TextField(
                    controller: heightController,
                    decoration: _buildInputDecoration("Height (cm)"),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: weightController,
                    decoration: _buildInputDecoration("Weight (kg)"),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Select Allergens:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      checkboxTheme: CheckboxThemeData(
                        checkColor: MaterialStateProperty.all(Colors.black),
                        fillColor: MaterialStateProperty.all(Colors.yellow),
                      ),
                    ),
                    child: Column(
                      children: allergensList.map((allergen) {
                        return CheckboxListTile(
                          title: Text(allergen, style: const TextStyle(color: Colors.white)),
                          value: selectedAllergies.contains(allergen.toLowerCase()),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedAllergies.add(allergen.toLowerCase());
                              } else {
                                selectedAllergies.remove(allergen.toLowerCase());
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Select Health Conditions:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      checkboxTheme: CheckboxThemeData(
                        checkColor: MaterialStateProperty.all(Colors.black),
                        fillColor: MaterialStateProperty.all(Colors.yellow),
                      ),
                    ),
                    child: Column(
                      children: conditionsList.map((condition) {
                        return CheckboxListTile(
                          title: Text(condition, style: const TextStyle(color: Colors.white)),
                          value: selectedConditions.contains(condition.toLowerCase()),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedConditions.add(condition.toLowerCase());
                              } else {
                                selectedConditions.remove(condition.toLowerCase());
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updatePreferences,
                    child: const Text("Update Preferences"),
                  ),
                ],
              ),
            ),
    );
  }
}
