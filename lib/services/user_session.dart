class UserSession {
  static String? name;
  static String? email;
  static String? lastJournalId; // Holds the ID for AI Reflection

  /// Call this when the user logs in
  static void setSession({
    required String userName,
    required String userEmail,
  }) {
    name = userName;
    email = userEmail;
    print("🍪 Session Established: $name ($email)");
  }

  /// Call this after saving a Daily Log to store the ID for the Insight page
  static void setLastJournalId(String id) {
    lastJournalId = id;
    print("🍪 lastJournalId Updated: $lastJournalId");
  }

  /// Call this on logout
  static void clear() {
    name = null;
    email = null;
    lastJournalId = null;
  }
}
