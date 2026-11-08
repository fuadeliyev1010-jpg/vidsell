import 'package:vidsell/core/config/app_environment.dart';

class VideoUrlResolver {
  const VideoUrlResolver._();

  static String? selectPlaybackUrl({String? hlsUrl, String? rawUrl}) {
    final hls = hlsUrl?.trim();
    if (hls != null && hls.isNotEmpty) return hls;
    final raw = rawUrl?.trim();
    return raw == null || raw.isEmpty ? null : raw;
  }

  static Uri? resolveNetworkUrl(String? value, {String? apiBaseUrl}) {
    final url = value?.trim();
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.hasScheme) {
      return uri.scheme == 'http' || uri.scheme == 'https' ? uri : null;
    }

    final baseUrl = apiBaseUrl ?? AppConfig.fromEnvironment().apiBaseUrl;
    final baseUri = Uri.tryParse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');
    if (baseUri == null || baseUri.host.isEmpty) return null;
    final relativePath = url.startsWith('/') ? url.substring(1) : url;
    return baseUri.resolve(relativePath);
  }
}
