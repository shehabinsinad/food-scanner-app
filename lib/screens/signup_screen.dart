import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _signUp() async {
    setState(() {
      _isLoading = true;
    });

    final user = await _authService.signUpWithEmail(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (user != null) {
      String allergies = selectedAllergies.join(", ");
      String conditions = selectedConditions.join(", ");

      await UserService().saveUserData(
        heightController.text.trim(),
        weightController.text.trim(),
        allergies,
        conditions,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sign up successful!')));

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sign up failed. Try again.')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: heightController,
              decoration: InputDecoration(labelText: "Height (cm)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: weightController,
              decoration: InputDecoration(labelText: "Weight (kg)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Text(
              "Select Allergens:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...allergensList.map((allergen) {
              return CheckboxListTile(
                title: Text(allergen),
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
            const SizedBox(height: 20),
            Text(
              "Select Health Conditions:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...conditionsList.map((condition) {
              return CheckboxListTile(
                title: Text(condition),
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
            const SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _signUp,
                    child: Text("Sign Up"),
                  ),
          ],
        ),
      ),
    );
  }
}
