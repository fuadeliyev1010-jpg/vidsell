import 'dart:async';
import 'dart:collection';

/// Keeps playback focused on visible cards in the row nearest the screen center.
class VideoSlotPool {
  VideoSlotPool._();
  static final VideoSlotPool instance = VideoSlotPool._();

  static const double minVisibleFraction = 0.1;
  static const double centerTieTolerance = 1;

  final LinkedHashMap<Object, _VideoCandidate> _candidates = LinkedHashMap();
  final Set<Object> _activeOwners = <Object>{};
  Object? _activeGroup;
  bool _isSuspended = false;
  bool _reconcileScheduled = false;

  void updateVisibility(
    Object owner,
    double visibleFraction, {
    Object? playbackGroup,
    required double Function() centerDistance,
    required void Function() onActivate,
    required void Function() onDeactivate,
  }) {
    _candidates[owner] = _VideoCandidate(
      playbackGroup: playbackGroup ?? owner,
      visibleFraction: visibleFraction,
      centerDistance: centerDistance,
      onActivate: onActivate,
      onDeactivate: onDeactivate,
    );
    _scheduleReconcile();
  }

  void refresh() => _scheduleReconcile();

  void setSuspended(bool suspended) {
    if (_isSuspended == suspended) return;
    _isSuspended = suspended;
    _scheduleReconcile();
  }

  void release(Object owner, {bool deactivate = true}) {
    final candidate = _candidates.remove(owner);
    if (_activeOwners.remove(owner)) {
      if (deactivate) candidate?.onDeactivate();
    }
    _scheduleReconcile();
  }

  void _scheduleReconcile() {
    if (_reconcileScheduled) return;
    _reconcileScheduled = true;
    scheduleMicrotask(() {
      _reconcileScheduled = false;
      _reconcile();
    });
  }

  void _reconcile() {
    Object? nextGroup;
    var closestDistance = double.infinity;
    if (!_isSuspended) {
      for (final candidate in _candidates.values) {
        if (candidate.visibleFraction < minVisibleFraction) continue;
        final distance = candidate.centerDistance();
        if (distance.isFinite && distance < closestDistance) {
          nextGroup = candidate.playbackGroup;
          closestDistance = distance;
        }
      }
    }

    final activeGroupDistance = _isSuspended
        ? null
        : _groupCenterDistance(_activeGroup);
    if (activeGroupDistance != null &&
        activeGroupDistance <= closestDistance + centerTieTolerance) {
      nextGroup = _activeGroup;
    }

    final nextOwners = <Object>{};
    if (!_isSuspended && nextGroup != null) {
      for (final entry in _candidates.entries) {
        final candidate = entry.value;
        if (candidate.playbackGroup == nextGroup &&
            candidate.visibleFraction >= minVisibleFraction) {
          nextOwners.add(entry.key);
        }
      }
    }

    final previousOwners = _activeOwners.toList(growable: false);
    _activeGroup = nextGroup;
    _activeOwners
      ..clear()
      ..addAll(nextOwners);

    for (final owner in previousOwners) {
      if (!nextOwners.contains(owner)) {
        _candidates[owner]?.onDeactivate();
      }
    }
    for (final owner in nextOwners) {
      if (!previousOwners.contains(owner)) {
        _candidates[owner]?.onActivate();
      }
    }
  }

  double? _groupCenterDistance(Object? group) {
    if (group == null) return null;
    var closestDistance = double.infinity;
    for (final candidate in _candidates.values) {
      if (candidate.playbackGroup != group ||
          candidate.visibleFraction < minVisibleFraction) {
        continue;
      }
      final distance = candidate.centerDistance();
      if (distance.isFinite && distance < closestDistance) {
        closestDistance = distance;
      }
    }
    return closestDistance.isFinite ? closestDistance : null;
  }
}

class _VideoCandidate {
  const _VideoCandidate({
    required this.playbackGroup,
    required this.visibleFraction,
    required this.centerDistance,
    required this.onActivate,
    required this.onDeactivate,
  });

  final Object playbackGroup;
  final double visibleFraction;
  final double Function() centerDistance;
  final void Function() onActivate;
  final void Function() onDeactivate;
}
