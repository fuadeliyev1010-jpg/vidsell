import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/features/discover/models/engagement_item.dart';
import 'package:vidsell/features/discover/repositories/engagement_repository.dart';

class FavoritesCubit extends Cubit<Map<String, EngagementItem>> {
  FavoritesCubit(this._repository) : super(const {});

  final EngagementRepository _repository;
  int _loadVersion = 0;
  int _userVersion = 0;
  int _operationVersion = 0;
  bool _isLoaded = false;
  Future<void>? _loadFuture;
  Map<String, EngagementItem> _serverFavorites = const {};
  final Map<String, _PendingFavorite> _pendingChanges = {};

  bool isFavorite(String listingId) => state.containsKey(listingId);
  bool get isLoaded => _isLoaded;

  Future<void> load() {
    if (_isLoaded) return Future<void>.value();
    final pendingLoad = _loadFuture;
    if (pendingLoad != null) return pendingLoad;

    final loadVersion = ++_loadVersion;
    final userVersion = _userVersion;
    late final Future<void> request;
    request = _repository
        .fetchFavorites()
        .then((favorites) {
          if (isClosed ||
              userVersion != _userVersion ||
              loadVersion != _loadVersion) {
            return;
          }
          _serverFavorites = {for (final item in favorites) item.id: item};
          _emitFavorites();
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
    _userVersion++;
    _isLoaded = false;
    _loadFuture = null;
    _serverFavorites = const {};
    _pendingChanges.clear();
    emit(const {});
  }

  Future<bool> toggle({
    required String listingId,
    required bool enabled,
    EngagementItem? item,
  }) async {
    final userVersion = _userVersion;
    final operationVersion = ++_operationVersion;
    ++_loadVersion;
    _loadFuture = null;
    final pendingItem =
        item ??
        state[listingId] ??
        EngagementItem(
          id: listingId,
          title: 'Seçilmiş elan',
          imageUrl: null,
          subtitle: '',
        );
    _pendingChanges[listingId] = _PendingFavorite(
      version: operationVersion,
      enabled: enabled,
      item: pendingItem,
    );
    _emitFavorites();

    try {
      await _repository.setFavorite(listingId, enabled, item: item);
      if (isClosed ||
          userVersion != _userVersion ||
          _pendingChanges[listingId]?.version != operationVersion) {
        return enabled;
      }
      _pendingChanges.remove(listingId);
      _serverFavorites = Map<String, EngagementItem>.from(_serverFavorites);
      if (enabled) {
        _serverFavorites[listingId] = pendingItem;
      } else {
        _serverFavorites.remove(listingId);
      }
      ++_loadVersion;
      _loadFuture = null;
      _isLoaded = false;
      _emitFavorites();
      return enabled;
    } catch (_) {
      if (!isClosed &&
          userVersion == _userVersion &&
          _pendingChanges[listingId]?.version == operationVersion) {
        _pendingChanges.remove(listingId);
        _emitFavorites();
      }
      rethrow;
    }
  }

  Future<void> clear() async {
    _loadVersion++;
    _userVersion++;
    _loadFuture = null;
    _pendingChanges.clear();
    await _repository.clearFavorites();
    if (!isClosed) {
      _serverFavorites = const {};
      _isLoaded = true;
      emit(const {});
    }
  }

  void _emitFavorites() {
    final favorites = Map<String, EngagementItem>.from(_serverFavorites);
    for (final change in _pendingChanges.values) {
      if (change.enabled) {
        favorites[change.item.id] = change.item;
      } else {
        favorites.remove(change.item.id);
      }
    }
    emit(favorites);
  }
}

class _PendingFavorite {
  const _PendingFavorite({
    required this.version,
    required this.enabled,
    required this.item,
  });

  final int version;
  final bool enabled;
  final EngagementItem item;
}
