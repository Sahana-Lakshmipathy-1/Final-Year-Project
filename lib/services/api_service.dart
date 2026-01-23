import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ✅ Your Actual API Gateway URL
  static const String baseUrl =
      "https://j9g0v8wjm6.execute-api.us-east-2.amazonaws.com/dev/routine";

  // --- 1. SMART HELPER METHOD (Unwraps AWS Response) ---
  Future<dynamic> _post(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      // 200 = OK, 201 = Created, 202 = Accepted
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // A. Decode the outer layer (The AWS Wrapper)
        final dynamic outerData = jsonDecode(response.body);

        // B. CHECK: Is the real data hidden inside a "body" string?
        // (This happens with AWS Lambda Proxy Integration)
        if (outerData is Map &&
            outerData.containsKey('body') &&
            outerData['body'] is String) {
          // 🚀 UNWRAP IT: Parse the inner JSON string to get user data
          return jsonDecode(outerData['body']);
        }

        // C. Otherwise, just return the data as is (if backend sends raw JSON)
        return outerData;
      } else {
        throw Exception(
          "Server Error: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("API Error: $e");
      rethrow;
    }
  }

  // --- 2. AUTHENTICATION ---

  Future<Map<String, dynamic>> logIn(String email, String password) async {
    return await _post({
      "event_type": "log_in",
      "email": email,
      "password": password,
    });
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
    required double weight,
    required double height,
    // Optional lists (default to empty if not provided)
    List<String>? healthConditions,
    List<String>? fitnessGoals,
    List<String>? nutritionGoals,
  }) async {
    return await _post({
      "event_type": "sign_in", // Matches your backend event name
      "email": email,
      "password": password,
      "name": name,
      "age": age,
      "weight": weight,
      "height": height,
      // ✅ STRICT SCHEMA MAPPING for your backend
      "conditions": healthConditions ?? [],
      "fitness_goals": fitnessGoals ?? [],
      "nutritional_goals": nutritionGoals ?? [],
    });
  }

  // --- 3. MOOD LOG FUNCTION ---
  Future<Map<String, dynamic>> logMood({
    required String email,
    required String mood,
    required int score,
    String note = "",
  }) async {
    return await _post({
      "event_type": "mood_log",
      "user_id": email,
      "payload": {
        "mood_id": "MOOD_${DateTime.now().millisecondsSinceEpoch}",
        "mood": mood,
        "score": score,
        "note": note,
      },
    });
  }
}
