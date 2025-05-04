import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:food_scanner_app/services/auth_service.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    await AuthService().signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan Product"),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: MobileScanner(
        onDetect: (BarcodeCapture barcodeCapture) {
          final barcodes = barcodeCapture.barcodes;
          if (barcodes.isNotEmpty && barcodes.first.displayValue != null) {
            Navigator.pushNamed(
              context,
              '/results',
              arguments: barcodes.first.displayValue,
            );
          }
        },
      ),
    );
  }
}
