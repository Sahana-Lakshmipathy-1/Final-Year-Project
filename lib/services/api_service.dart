import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lumora/services/user_session.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class ApiService {
  // ✅ Your Actual API Gateway URL
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";

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
  String hashPassword(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);
  return digest.toString(); // This is the hashed password
}


  Future<Map<String, dynamic>> logIn(String email, String password) async {
    final hashedpassword = hashPassword(password);
    print("HASH SENT TO BACKEND: $hashedpassword");
    return await _post({
      "event_type": "log_in",
      "email": email,
      "password": hashedpassword,
    });
  }

  Future<Map<String, dynamic>> logOut(String? email) async {
    if (email == null) {
      return {"message": "No active session"};
    }

    return await _post({
      "event_type": "log_out",
      "email": email,
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
      "password": hashPassword(password),
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

  // --- MANUAL ROUTINE ---
  Future<Map<String, dynamic>> createManualRoutine(
    Map<String, dynamic> payload,
  ) async {
    // We reuse the _post helper we wrote earlier
    return await _post(payload);
  }

  /// Fetches all exercise routines for the user.
  /// Backend returns: {"routines": [...]}
  Future<Map<String, dynamic>> fetchExerciseRoutines() async {
    return await _post({
      "event_type": "get_exercise_routine",
      "user_id": UserSession.email,
    });
  }

  /// Updates a specific exercise routine (e.g., marking as complete).
  /// [routineId] is the Partition Key (ROUTINE#...)
  /// [updates] is a Map like {"weekly_schedule": [...], "status": "..."}
  Future<Map<String, dynamic>> updateExerciseRoutine({
    required String routineId,
    required Map<String, dynamic> updates,
  }) async {
    return await _post({
      "event_type": "update_exercise",
      "routine_id": routineId,
      "payload": updates,
    });
  }

  /// Fetches all meal routines for the user.
  /// Backend returns: {"meals": [...]}
  Future<Map<String, dynamic>> fetchMealRoutines() async {
    return await _post({
      "event_type": "get_meal_routine",
      "user_id": UserSession.email,
    });
  }

  /// Updates a specific meal routine (e.g., changing 'completed' status).
  /// [mealRoutineId] is the Partition Key (MEAL#...)
  /// [updates] is a Map like {"weekly_meals": [...], "status": "..."}
  Future<Map<String, dynamic>> updateMealRoutine({
    required String mealRoutineId,
    required Map<String, dynamic> updates,
  }) async {
    return await _post({
      "event_type": "update_meal",
      "meal_routine_id": mealRoutineId,
      "payload": updates,
    });
  }

  // --- MANUAL MEAL PLAN ---
  Future<Map<String, dynamic>> createManualMealPlan(
    Map<String, dynamic> payload,
  ) async {
    return await _post(payload);
  }

  // --- AI GENERATION ---
  Future<Map<String, dynamic>> generateWeeklyRoutine(
    Map<String, dynamic> payload,
  ) async {
    // Reusing the smart _post method
    return await _post(payload);
  }

  // --- CHECK STATUS ---
  Future<Map<String, dynamic>> checkRoutineStatus(
    String email,
    String routineId,
  ) async {
    return await _post({
      "event_type": "check_routine_status",
      "user_id": email,
      "routine_id": routineId,
    });
  }

  // --- MEAL PLAN API ---
  Future<Map<String, dynamic>> generateWeeklyMealPlan(
    Map<String, dynamic> payload,
  ) async {
    return await _post(payload);
  }

  Future<Map<String, dynamic>> checkMealPlanStatus(
    String email,
    String routineId,
  ) async {
    return await _post({
      "event_type": "check_meal_plan_status",
      "user_id": email,
      "meal_routine_id": routineId,
    });
  }

  // --- DAILY LOGGING ---
  Future<Map<String, dynamic>> logAdherence(
    Map<String, dynamic> payload,
  ) async {
    return await _post(payload);
  }

  // --- WELLNESS REFLECTION API ---
  Future<Map<String, dynamic>> generateWellnessReflection(
    String journalId,
  ) async {
    return await _post({
      "event_type": "generate_wellness_reflection",
      "user_id": UserSession.email,
      "journal_id": journalId,
    });
  }

  Future<Map<String, dynamic>> checkReflectionStatus(
    String reflectionId,
  ) async {
    return await _post({
      "event_type": "check_reflection_status",
      "reflection_id": reflectionId,
    });
  }

  // --- CHAT TRIGGER ---
  Future<void> askBotQuestion({
    required String question,
    required String connectionId,
    required String botType,
  }) async {
    final payload = {
      "event_type": "ask_question",
      "connection_id": connectionId,
      "session_id": "SESSION#${UserSession.email}",
      "message_id": "MSG#${DateTime.now().millisecondsSinceEpoch}",
      "question": question,
      "bot_type": botType,
    };

    // Standard POST call to your REST endpoint
    await _post(payload);
  }
}
