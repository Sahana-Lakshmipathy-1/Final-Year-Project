class UserSession {
  // Static variables = accessible everywhere
  static String? name;
  static String? email;

  // Call this when the user logs in or signs up
  static void setSession({
    required String userName,
    required String userEmail,
  }) {
    name = userName;
    email = userEmail;
    print("🍪 Session Set: $name ($email)");
  }

  // Call this on Logout
  static void clear() {
    name = null;
    email = null;
  }
}
