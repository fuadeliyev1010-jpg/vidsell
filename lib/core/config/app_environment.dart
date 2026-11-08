import 'package:flutter/foundation.dart';

enum AppEnvironment { development, staging, production }

class AppConfig {
  const AppConfig({
    this.environment = AppEnvironment.development,
    this.apiBaseUrl = 'https://api.example.com',
    this.useMockBackend = true,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;
  final bool useMockBackend;

  factory AppConfig.fromEnvironment() {
    const environmentName = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );
    const defaultBackendMode = environmentName == 'development'
        ? 'mock'
        : 'api';
    const backendMode = String.fromEnvironment(
      'BACKEND_MODE',
      defaultValue: defaultBackendMode,
    );
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.example.com/api',
    );
    if (backendMode != 'api' && backendMode != 'mock') {
      throw StateError('BACKEND_MODE must be either "api" or "mock".');
    }

    const useMockBackend = backendMode == 'mock';
    if (kReleaseMode && useMockBackend) {
      throw StateError('Mock backend mode is not allowed in release builds.');
    }

    final environment = switch (environmentName) {
      'production' => AppEnvironment.production,
      'staging' => AppEnvironment.staging,
      _ => AppEnvironment.development,
    };
    final config = AppConfig(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      useMockBackend: useMockBackend,
    );
    final uri = Uri.tryParse(config.apiBaseUrl);
    if (uri == null || uri.host.isEmpty) {
      throw StateError('API_BASE_URL must be a valid URL.');
    }
    if (environment != AppEnvironment.development &&
        (uri.scheme != 'https' || uri.host.contains('example.com'))) {
      throw StateError(
        'Staging and production require a real HTTPS API_BASE_URL.',
      );
    }
    return config;
  }

  static const development = AppConfig(
    environment: AppEnvironment.development,
    apiBaseUrl: 'http://10.0.2.2:8080/api',
    useMockBackend: true,
  );

  static const staging = AppConfig(
    environment: AppEnvironment.staging,
    apiBaseUrl: 'https://staging-api.vidsell.az/api',
    useMockBackend: false,
  );

  static const production = AppConfig(
    environment: AppEnvironment.production,
    apiBaseUrl: 'https://api.vidsell.az/api',
    useMockBackend: false,
  );
}
