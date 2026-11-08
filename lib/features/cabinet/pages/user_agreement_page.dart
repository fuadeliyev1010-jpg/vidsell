import 'package:flutter/material.dart';
import 'package:vidsell/features/cabinet/pages/static_content_page.dart';

import 'package:vidsell/l10n/app_localizations_extensions.dart';

class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticContentPage(
      title: context.l10n.userAgreement,
      sections: userAgreementSections(context.l10n),
    );
  }
}
