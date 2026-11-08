import 'package:flutter_test/flutter_test.dart';
import 'package:vidsell/features/discover/utils/video_slot_pool.dart';

void main() {
  test('plays the visible videos in the nearest row', () async {
    final pool = VideoSlotPool.instance;
    final active = <String>{};
    final distances = <String, double>{'left': 30, 'right': 32, 'below': 180};

    void register(String owner, String group) {
      pool.updateVisibility(
        owner,
        1,
        playbackGroup: group,
        centerDistance: () => distances[owner]!,
        onActivate: () => active.add(owner),
        onDeactivate: () => active.remove(owner),
      );
    }

    register('left', 'row-one');
    register('right', 'row-one');
    register('below', 'row-two');
    await Future<void>.delayed(Duration.zero);
    expect(active, {'left', 'right'});

    distances['below'] = 10;
    pool.refresh();
    await Future<void>.delayed(Duration.zero);
    expect(active, {'below'});

    pool.setSuspended(true);
    await Future<void>.delayed(Duration.zero);
    expect(active, isEmpty);

    pool.setSuspended(false);
    await Future<void>.delayed(Duration.zero);
    expect(active, {'below'});

    pool
      ..release('left')
      ..release('right')
      ..release('below');
    await Future<void>.delayed(Duration.zero);
  });
}
