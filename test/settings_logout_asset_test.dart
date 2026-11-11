import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('settings logout icon is bundled as an asset', () async {
    final asset = await rootBundle.load('assets/icons/ic_baseline-log-out.svg');

    expect(asset.lengthInBytes, greaterThan(0));
  });
}
