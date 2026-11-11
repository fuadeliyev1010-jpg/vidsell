import 'package:vidsell/core/config/app_environment.dart';

String? resolveMediaUrl(String? raw, {String? origin, String? apiBaseUrl}) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;

  final uri = Uri.tryParse(value);
  if (uri == null) return null;
  if (uri.scheme == 'http' || uri.scheme == 'https') return value;
  if (uri.hasScheme) return value;

  final resolvedOrigin = origin == null
      ? mediaOriginFromApiBaseUrl(
          apiBaseUrl ?? AppConfig.fromEnvironment().apiBaseUrl,
        )
      : _normalizeOrigin(origin);
  if (resolvedOrigin == null) return null;
  final path = value.startsWith('/') ? value.substring(1) : value;
  return Uri.parse('$resolvedOrigin/').resolve(path).toString();
}

String? _normalizeOrigin(String origin) {
  final uri = Uri.tryParse(origin.trim());
  if (uri == null || uri.host.isEmpty || uri.scheme.isEmpty) return null;
  return Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
  ).origin;
}

String? mediaOriginFromApiBaseUrl(String apiBaseUrl) {
  return _normalizeOrigin(apiBaseUrl);
}
