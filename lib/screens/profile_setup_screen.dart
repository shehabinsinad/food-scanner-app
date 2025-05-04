import 'package:flutter/material.dart';
import '../services/user_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final data = await UserService().getUserData();
    if (data["height"]!.isNotEmpty &&
        data["weight"]!.isNotEmpty &&
        data["allergies"]!.isNotEmpty &&
        data["conditions"]!.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/scanner');
    } else {
      setState(() {
        heightController.text = data["height"] ?? "";
        weightController.text = data["weight"] ?? "";
        _isLoading = false;
      });
    }
  }

  void _saveProfile() async {
    await UserService().saveUserData(
      heightController.text.trim(),
      weightController.text.trim(),
      "", // Allergens and conditions remain unchanged.
      "",
    );
    Navigator.pushReplacementNamed(context, '/scanner');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile Setup")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: Text("Save & Continue"),
                  ),
                ],
              ),
            ),
    );
  }
}
