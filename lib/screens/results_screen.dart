import 'package:flutter/material.dart';
import 'package:food_scanner_app/services/product_service.dart';
import 'package:food_scanner_app/services/user_service.dart';
import 'package:food_scanner_app/services/history_service.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Future<Map<String, dynamic>> _resultFuture;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _resultFuture = _loadResult();
      _isInitialized = true;
    }
  }

  Future<Map<String, dynamic>> _loadResult() async {
    final barcodeData = ModalRoute.of(context)!.settings.arguments as String;
    print("Scanned barcode: $barcodeData");

    final productData = await ProductService().getProductDetails(barcodeData);
    print("Product data: $productData");

    final userData = await UserService().getUserData();
    print("User data: $userData");

    double height = double.tryParse(userData["height"] ?? "") ?? 170;
    double weight = double.tryParse(userData["weight"] ?? "") ?? 70;
    List<String> userAllergies = (userData["allergies"] ?? "")
        .toString()
        .toLowerCase()
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    List<String> userConditions = (userData["conditions"] ?? "")
        .toString()
        .toLowerCase()
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // If nutrient values are zero, navigate to Product Not Found.
    if (productData["calories"] == 0 &&
        productData["protein"] == 0 &&
        productData["carbs"] == 0 &&
        productData["fat"] == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/product_not_found');
      });
      return {};
    }

    // Process product allergens.
    List<String> productAllergens = [];
    if (productData["allergens"] != null &&
        productData["allergens"].toString().isNotEmpty) {
      productAllergens = productData["allergens"]
          .toString()
          .toLowerCase()
          .split(",")
          .map((e) => e.replaceAll("en:", "").trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    print("Product allergens: $productAllergens");

    // Calculate health score and check allergens.
    Map<String, dynamic> scoreResult = calculateHealthScore(
      height: height,
      weight: weight,
      userAllergies: userAllergies,
      userConditions: userConditions,
      calories: productData["calories"],
      protein: productData["protein"],
      carbs: productData["carbs"],
      fat: productData["fat"],
      sugars: productData["sugars"],
      productName: productData["name"],
      productAllergens: productAllergens,
    );
    int healthScore = scoreResult["score"];
    String allergenNote = scoreResult["allergenNote"];
    print("Calculated health score: $healthScore");
    if (allergenNote.isNotEmpty) {
      print("Detected allergens: $allergenNote");
    }

    await HistoryService().addScan({
      "productName": productData["name"],
      "healthScore": healthScore,
      "timestamp": DateTime.now().toIso8601String(),
    });

    return {
      "product": productData,
      "healthScore": healthScore,
      "allergenNote": allergenNote,
    };
  }

  /// Returns a map with keys:
  /// "score": the calculated health score (int)
  /// "allergenNote": a string note listing any detected allergens (empty if none)
  Map<String, dynamic> calculateHealthScore({
    required double height,
    required double weight,
    required List<String> userAllergies,
    required List<String> userConditions,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double sugars,
    required String productName,
    required List<String> productAllergens,
  }) {
    List<String> detectedAllergens = [];

    // Check product allergens using regex with word boundaries.
    for (var userAllergen in userAllergies) {
      final pattern = r'\b' + RegExp.escape(userAllergen) + r'\b';
      final regex = RegExp(pattern, caseSensitive: false);
      for (var prodAllergen in productAllergens) {
        if (regex.hasMatch(prodAllergen)) {
          if (!detectedAllergens.contains(userAllergen)) {
            detectedAllergens.add(userAllergen);
          }
        }
      }
      // Additional check on product name for soy/soya.
      if ((userAllergen == "soy" || userAllergen == "soya") &&
          (productName.toLowerCase().contains("soy") ||
           productName.toLowerCase().contains("soya"))) {
        if (!detectedAllergens.contains(userAllergen)) {
          detectedAllergens.add(userAllergen);
        }
      }
    }
    if (detectedAllergens.isNotEmpty) {
      String allergenNote = "Allergen present: " + detectedAllergens.join(", ");
      return {"score": 0, "allergenNote": allergenNote};
    }

    int score = 100;

    // Adjusted calorie penalty: for every 50 calories above 200, subtract 5 points.
    if (calories > 200) {
      score -= (((calories - 200) / 50).ceil() * 5);
    }

    // Adjusted sugar penalty: for every 5g of sugar above 10g, subtract 3 points.
    if (sugars > 10) {
      score -= (((sugars - 10) / 5).ceil() * 3);
    }

    // Adjusted BMI penalty based on user's BMI.
    double heightInMeters = height / 100;
    double bmi = weight / (heightInMeters * heightInMeters);
    if (bmi > 25) {
      score -= 5;
    } else if (bmi < 18.5) {
      score -= 3;
    }

    // Adjusted penalty for low protein relative to high carbs.
    if (protein < 10 && carbs > 30) {
      score -= 3;
    }

    // Adjusted penalty for specific health conditions.
    if (userConditions.contains("diabetes") && sugars > 15) {
      score -= 10;
    }
    if (userConditions.contains("hypertension") && fat > 10) {
      score -= 5;
    }

    // Adjusted extra penalty for junk food names.
    if (productName.toLowerCase().contains("snickers") ||
        productName.toLowerCase().contains("peanut")) {
      score -= 5;
    }

    if (score < 1) score = 1;
    if (score > 100) score = 100;

    return {"score": score, "allergenNote": ""};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _resultFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return Scaffold(
            appBar: AppBar(title: const Text("Scan Results")),
            body: const Center(child: CircularProgressIndicator()),
          );

        final product = snapshot.data!["product"];
        final healthScore = snapshot.data!["healthScore"];
        final allergenNote = snapshot.data!["allergenNote"] as String;
        return Scaffold(
          appBar: AppBar(title: const Text("Scan Results")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Product: ${product["name"]}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text("Calories: ${product["calories"]} kcal"),
                Text("Protein: ${product["protein"]}g, Carbs: ${product["carbs"]}g, Fat: ${product["fat"]}g"),
                Text("Sugars: ${product["sugars"]}g"),
                Text("Nutritional Info: ${product["nutrients"]}"),
                const SizedBox(height: 20),
                if (allergenNote.isNotEmpty)
                  Text(
                    allergenNote,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                Text(
                  "Health Score: $healthScore/100",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
