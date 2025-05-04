import 'package:flutter/material.dart';
import '../services/user_service.dart';

class SignupPreferencesScreen extends StatefulWidget {
  const SignupPreferencesScreen({Key? key}) : super(key: key);

  @override
  _SignupPreferencesScreenState createState() => _SignupPreferencesScreenState();
}

class _SignupPreferencesScreenState extends State<SignupPreferencesScreen> {
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

  bool _isLoading = false;

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

  void _finishSignup() async {
    if (heightController.text.trim().isEmpty || weightController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Height and Weight are mandatory. Please enter both."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    String allergies = selectedAllergies.join(", ");
    String conditions = selectedConditions.join(", ");
    await UserService().saveUserData(
      heightController.text.trim(),
      weightController.text.trim(),
      allergies,
      conditions,
    );
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Sign up successful!")));
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up - Preferences")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: heightController,
              decoration: _buildInputDecoration("Height (cm) *"),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              decoration: _buildInputDecoration("Weight (kg) *"),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              "Select Allergens:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                checkboxTheme: CheckboxThemeData(
                  // When selected, the box (fill) will be yellow
                  fillColor: MaterialStateProperty.all(Colors.yellow),
                  // The tick mark will be black
                  checkColor: MaterialStateProperty.all(Colors.black),
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
            const SizedBox(height: 24),
            const Text(
              "Select Health Conditions:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                checkboxTheme: CheckboxThemeData(
                  fillColor: MaterialStateProperty.all(Colors.yellow),
                  checkColor: MaterialStateProperty.all(Colors.black),
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
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _finishSignup,
                    child: const Text("Finish Sign Up", style: TextStyle(fontSize: 18)),
                  ),
          ],
        ),
      ),
    );
  }
}
