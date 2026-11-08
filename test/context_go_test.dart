import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vidsell/core/pager/app_router.dart';
import 'package:vidsell/core/pager/context_go.dart';

void main() {
  testWidgets('returns to root when a routed page is opened without extras', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/page/_Destination',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
        routedPageRoute(),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/');
  });

  testWidgets('context go helpers push, return results, and clear history', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const _Launcher()),
        routedPageRoute(),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.tap(find.text('Push page'));
    await tester.pumpAndSettle();
    expect(find.text('Destination'), findsOneWidget);

    await tester.tap(find.text('Return value'));
    await tester.pumpAndSettle();
    expect(find.text('Returned: complete'), findsOneWidget);

    await tester.tap(find.text('Clear history'));
    await tester.pumpAndSettle();
    expect(find.text('Destination'), findsOneWidget);
    expect(router.canPop(), isFalse);
  });
}

class _Launcher extends StatefulWidget {
  const _Launcher();

  @override
  State<_Launcher> createState() => _LauncherState();
}

class _LauncherState extends State<_Launcher> {
  String? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Returned: ${_result ?? 'none'}'),
          TextButton(
            onPressed: () async {
              final result = await context.goTo<String>(const _Destination());
              if (mounted) setState(() => _result = result);
            },
            child: const Text('Push page'),
          ),
          TextButton(
            onPressed: () => context.goAndClear(const _Destination()),
            child: const Text('Clear history'),
          ),
        ],
      ),
    );
  }
}

class _Destination extends StatelessWidget {
  const _Destination();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Destination'),
          TextButton(
            onPressed: () => context.goBack('complete'),
            child: const Text('Return value'),
          ),
        ],
      ),
    );
  }
}
