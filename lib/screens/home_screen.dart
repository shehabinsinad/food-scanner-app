import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_scanner_app/services/auth_service.dart';
import 'package:food_scanner_app/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, String>? userData;
  bool _isLoading = true;
  String email = "";

  Future<void> _loadUserData() async {
    userData = await UserService().getUserData();
    email = FirebaseAuth.instance.currentUser?.email ?? "";
    setState(() {
      _isLoading = false;
    });
  }

  void _logout() async {
    await AuthService().signOut();
    Navigator.pushReplacementNamed(context, '/landing');
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade800, Colors.indigo.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          image: DecorationImage(
            image: const AssetImage("assets/images/home_bg.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadUserData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const Divider(),
                              Text("Email: $email", style: const TextStyle(fontSize: 16)),
                              Text("Height: ${userData?['height'] ?? 'Not set'} cm", style: const TextStyle(fontSize: 16)),
                              Text("Weight: ${userData?['weight'] ?? 'Not set'} kg", style: const TextStyle(fontSize: 16)),
                              Text("Allergies: ${userData?['allergies'] ?? 'None'}", style: const TextStyle(fontSize: 16)),
                              Text("Health Conditions: ${userData?['conditions'] ?? 'None'}", style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/update_preferences')
                                      .then((_) => _loadUserData());
                                },
                                child: const Text("Update Preferences"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/scanner');
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text("Scan Barcode"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
