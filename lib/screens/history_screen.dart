import 'package:flutter/material.dart';
import 'package:food_scanner_app/services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = HistoryService().getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan History")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          final history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final scan = history[history.length - index - 1];
              return Card(
                elevation: 3,
                child: ListTile(
                  title: Text("Product: ${scan['productName']}"),
                  subtitle: Text("Health Score: ${scan['healthScore']}"),
                  trailing: Text("Date: ${scan['timestamp'].substring(0, 10)}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
