import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/features/discover/models/engagement_item.dart';
import 'package:vidsell/features/discover/repositories/engagement_repository.dart';

class FavoritesCubit extends Cubit<Map<String, EngagementItem>> {
  FavoritesCubit(this._repository) : super(const {});

  final EngagementRepository _repository;
  int _loadVersion = 0;
  bool _isLoaded = false;
  Future<void>? _loadFuture;

  bool isFavorite(String listingId) => state.containsKey(listingId);
  bool get isLoaded => _isLoaded;

  Future<void> load() {
    if (_isLoaded) return Future<void>.value();
    final pendingLoad = _loadFuture;
    if (pendingLoad != null) return pendingLoad;

    final loadVersion = ++_loadVersion;
    late final Future<void> request;
    request = _repository
        .fetchFavorites()
        .then((favorites) {
          if (isClosed || loadVersion != _loadVersion) return;
          emit({for (final item in favorites) item.id: item});
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

  Future<bool> toggle({
    required String listingId,
    required bool enabled,
    EngagementItem? item,
  }) async {
    final wasLoaded = _isLoaded;
    final operationVersion = ++_loadVersion;
    _loadFuture = null;
    final previous = state;
    final next = Map<String, EngagementItem>.from(state);
    if (enabled) {
      next[listingId] =
          item ??
          state[listingId] ??
          EngagementItem(
            id: listingId,
            title: 'Seçilmiş elan',
            imageUrl: null,
            subtitle: '',
          );
    } else {
      next.remove(listingId);
    }
    emit(next);

    try {
      await _repository.setFavorite(listingId, enabled, item: item);
      _isLoaded = wasLoaded;
      return enabled;
    } catch (_) {
      if (!isClosed && operationVersion == _loadVersion) emit(previous);
      rethrow;
    }
  }

  Future<void> clear() async {
    _loadVersion++;
    _loadFuture = null;
    await _repository.clearFavorites();
    if (!isClosed) {
      _isLoaded = true;
      emit(const {});
    }
  }
}
