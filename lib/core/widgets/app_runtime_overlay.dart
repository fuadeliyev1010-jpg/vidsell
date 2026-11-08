import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidsell/core/state/app_runtime_cubit.dart';
import 'package:vidsell/l10n/app_localizations.dart';

class AppRuntimeOverlay extends StatelessWidget {
  const AppRuntimeOverlay({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppRuntimeCubit, AppRuntimeState>(
      builder: (context, state) {
        final showOffline =
            state.connectionStatus == AppConnectionStatus.offline &&
            !state.isOfflineBannerDismissed;
        return Stack(
          children: [
            child,
            if (showOffline)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Material(
                    color: const Color(0xff3B2020),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(child: _OfflineMessage()),
                          TextButton(
                            onPressed: () => context
                                .read<AppRuntimeCubit>()
                                .dismissOfflineBanner(),
                            child: Text(AppLocalizations.of(context)!.close),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OfflineMessage extends StatelessWidget {
  const _OfflineMessage();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.offlineMessage,
      style: const TextStyle(color: Colors.white),
    );
  }
}
