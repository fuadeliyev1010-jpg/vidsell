import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/features/discover/models/engagement_item.dart';
import 'package:vidsell/features/discover/repositories/engagement_repository.dart';

class FollowingCubit extends Cubit<Map<String, EngagementItem>> {
  FollowingCubit(this._repository) : super(const {});

  final EngagementRepository _repository;
  int _loadVersion = 0;
  bool _isLoaded = false;
  Future<void>? _loadFuture;

  bool isFollowing(String storeId) => state.containsKey(storeId);
  bool get isLoaded => _isLoaded;

  Future<void> load() {
    if (_isLoaded) return Future<void>.value();
    final pendingLoad = _loadFuture;
    if (pendingLoad != null) return pendingLoad;

    final loadVersion = ++_loadVersion;
    late final Future<void> request;
    request = _repository
        .fetchFollowedStores()
        .then((stores) {
          if (isClosed || loadVersion != _loadVersion) return;
          emit({for (final store in stores) store.id: store});
          _isLoaded = true;
        })
        .whenComplete(() {
          if (identical(_loadFuture, request)) _loadFuture = null;
        });
    _loadFuture = request;
    return request;
  }

  void reset() {
    _loadVersion++;
    _isLoaded = false;
    _loadFuture = null;
    emit(const {});
  }

  Future<void> toggle({
    required String storeId,
    required bool enabled,
    EngagementItem? item,
  }) async {
    final wasLoaded = _isLoaded;
    final operationVersion = ++_loadVersion;
    _loadFuture = null;
    final previous = state;
    final next = Map<String, EngagementItem>.from(state);
    if (enabled) {
      next[storeId] =
          item ??
          EngagementItem(
            id: storeId,
            title: storeId,
            imageUrl: null,
            subtitle: 'Mağaza',
          );
    } else {
      next.remove(storeId);
    }
    emit(next);

    try {
      await _repository.setFollowing(storeId, enabled, item: item);
      _isLoaded = wasLoaded;
    } catch (_) {
      if (!isClosed && operationVersion == _loadVersion) emit(previous);
      rethrow;
    }
  }

  Future<void> clear() async {
    _loadVersion++;
    _loadFuture = null;
    await _repository.clearFollowedStores();
    if (!isClosed) {
      _isLoaded = true;
      emit(const {});
    }
  }
}
