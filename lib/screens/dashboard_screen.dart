import 'package:flutter/material.dart';
import 'package:food_scanner_app/services/history_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = HistoryService().getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Center(
                child: Text(
                  "Food Scanner App",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.scanner),
              title: const Text("Scan Product"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/scanner');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Scan History"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Update Preferences"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/update_preferences');
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snapshot.data!;
          double avgScore = 0;
          String lastScan = "No scans yet";
          if (history.isNotEmpty) {
            avgScore = history
                    .map((e) => e['healthScore'] as int)
                    .reduce((a, b) => a + b) /
                history.length;
            lastScan = history.last['productName'];
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Summary cards row.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryCard("Last Scan", lastScan, Colors.green),
                    _buildSummaryCard("Avg Health Score", avgScore.toStringAsFixed(0), Colors.orange),
                  ],
                ),
                const SizedBox(height: 20),
                // Recent scans list.
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final scan = history[history.length - index - 1];
                      return Card(
                        elevation: 3,
                        child: ListTile(
                          title: Text(scan['productName']),
                          subtitle: Text("Health Score: ${scan['healthScore']}"),
                          trailing: Text(scan['timestamp'].substring(0, 10)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
