class AppConstants {
  AppConstants._();

  /// Backend base URL – overridden per environment.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  /// OAuth2 / OIDC settings
  static const String oidcIssuer = String.fromEnvironment(
    'OIDC_ISSUER',
    defaultValue: 'http://localhost:8180/realms/neupay',
  );

  static const String oidcClientId = String.fromEnvironment(
    'OIDC_CLIENT_ID',
    defaultValue: 'neupay-flutter',
  );

  static const String oidcRedirectUri = String.fromEnvironment(
    'OIDC_REDIRECT_URI',
    defaultValue: 'com.neupay.app://callback',
  );

  /// Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
}
