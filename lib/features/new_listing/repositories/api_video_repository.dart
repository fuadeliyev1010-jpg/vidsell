import 'dart:async';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:vidsell/core/network/api_client.dart';
import 'package:vidsell/features/new_listing/repositories/video_repository.dart';
import 'package:vidsell/models/enums/video_status.dart';
import 'package:vidsell/models/video/video.dart';

class ApiVideoRepository implements VideoRepository {
  ApiVideoRepository(this._client);

  final ApiClient _client;

  @override
  Future<Video> upload(String filePath) async {
    final data = await _client.postMultipart(
      '/videos',
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: path.basename(filePath),
        ),
      }),
    );
    return _parse(data);
  }

  @override
  Future<Video> get(String videoId) async =>
      _parse(await _client.get('/videos/$videoId'));

  @override
  Future<Video> waitUntilProcessed(String videoId) async {
    for (var attempt = 0; attempt < 30; attempt++) {
      final video = await get(videoId);
      switch (video.status) {
        case VideoStatus.processed:
          return video;
        case VideoStatus.failed:
          throw StateError('video_processing_failed');
        case VideoStatus.uploaded:
        case VideoStatus.processing:
        case VideoStatus.paused:
        case VideoStatus.unknown:
        case null:
          await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
    throw TimeoutException('Video processing timed out.');
  }

  @override
  Future<void> tagProduct(String videoId, String productId) async {
    await _client.post('/videos/$videoId/products/$productId');
  }

  @override
  Future<Video> pause(String videoId) async =>
      _parse(await _client.post('/videos/$videoId/pause'));

  @override
  Future<Video> resume(String videoId) async =>
      _parse(await _client.post('/videos/$videoId/resume'));

  Video _parse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid video response.');
    }
    final nested = data['video'];
    return Video.fromJson(
      nested is Map<String, dynamic> ? nested : data,
      mediaOrigin: _client.mediaOrigin,
    );
  }
}
