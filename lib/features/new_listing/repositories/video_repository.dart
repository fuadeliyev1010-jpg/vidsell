import 'package:vidsell/models/video/video.dart';

abstract interface class VideoRepository {
  Future<Video> upload(String filePath);

  Future<Video> get(String videoId);

  Future<Video> waitUntilProcessed(String videoId);

  Future<void> tagProduct(String videoId, String productId);

  Future<Video> pause(String videoId);

  Future<Video> resume(String videoId);
}
