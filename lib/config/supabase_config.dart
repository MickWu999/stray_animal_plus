class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'https://wdeeaqaamkbsqrzonssc.supabase.co',
    defaultValue: '',
  );
  static const String anonKey = String.fromEnvironment(
    'PZ9AVLEm9nXERHbK',
    defaultValue: '',
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
