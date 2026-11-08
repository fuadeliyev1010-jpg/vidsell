import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vidsell/core/constants/app_color.dart';
import 'package:vidsell/core/constants/app_text_style.dart';
import 'package:vidsell/core/pager/context_go.dart';
import 'package:vidsell/core/utils/int_sizedbox_extention.dart';
import 'package:vidsell/core/widgets/app_icon_button.dart';
import 'package:vidsell/features/discover/pages/discover_page.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

/// Social login divider and Google/Apple sign-in buttons section.
class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        20.height,
        Row(
          children: [
            const Expanded(
              child: Divider(color: AppColor.tertiaryTextColor, thickness: 0.6),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(context.l10n.or, style: AppTextStyle.primaryText),
            ),
            const Expanded(
              child: Divider(color: AppColor.tertiaryTextColor, thickness: 0.6),
            ),
          ],
        ),
        34.height,
        Row(
          children: [
            Expanded(
              child: AppIconButton(
                onPressed: () {
                  context.goTo(const DiscoverPage());
                },
                iconPath: 'assets/images/devicon_google.svg',
              ),
            ),
            13.width,
            Expanded(
              child: AppIconButton(
                onPressed: () {
                  context.goTo(const DiscoverPage());
                },
                iconPath: 'assets/images/uiw_apple.svg',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
