import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppConnectionStatus { checking, online, offline }

class AppRuntimeState {
  const AppRuntimeState({
    this.connectionStatus = AppConnectionStatus.checking,
    this.lastError,
    this.isOfflineBannerDismissed = false,
  });

  final AppConnectionStatus connectionStatus;
  final Object? lastError;
  final bool isOfflineBannerDismissed;

  AppRuntimeState copyWith({
    AppConnectionStatus? connectionStatus,
    Object? lastError,
    bool? isOfflineBannerDismissed,
    bool clearError = false,
  }) {
    return AppRuntimeState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      lastError: clearError ? null : lastError ?? this.lastError,
      isOfflineBannerDismissed:
          isOfflineBannerDismissed ?? this.isOfflineBannerDismissed,
    );
  }
}

class AppRuntimeCubit extends Cubit<AppRuntimeState> {
  AppRuntimeCubit({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      super(const AppRuntimeState()) {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivity,
      onError: (Object error, StackTrace stackTrace) {
        emit(state.copyWith(lastError: error));
      },
    );
    checkConnection();
  }

  final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  Future<void> checkConnection() async {
    emit(state.copyWith(connectionStatus: AppConnectionStatus.checking));
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivity(results);
    } catch (error) {
      emit(
        state.copyWith(
          connectionStatus: AppConnectionStatus.offline,
          lastError: error,
        ),
      );
    }
  }

  void _handleConnectivity(List<ConnectivityResult> results) {
    final isOnline = results.any((result) => result != ConnectivityResult.none);
    emit(
      state.copyWith(
        connectionStatus: isOnline
            ? AppConnectionStatus.online
            : AppConnectionStatus.offline,
        isOfflineBannerDismissed: isOnline
            ? state.isOfflineBannerDismissed
            : false,
        clearError: true,
      ),
    );
  }

  void dismissOfflineBanner() {
    if (state.connectionStatus != AppConnectionStatus.offline) return;
    emit(state.copyWith(isOfflineBannerDismissed: true));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
