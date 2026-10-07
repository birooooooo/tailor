import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/localization/ku_fallback_localizations.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'features/auth/role_select_screen.dart';
import 'providers/orders_provider.dart';

void main() {
  runApp(const TailorApp());
}

class TailorApp extends StatelessWidget {
  const TailorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Kurdish (Sorani) is the default. Change this later from a settings provider.
    const locale = Locale('ku');
    final isRtl = locale.languageCode == 'ku' || locale.languageCode == 'ar';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: MaterialApp(
        title: 'Terz',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        // Flutter does not ship Kurdish localizations, so we use our own
        // delegate plus the small fallback delegates above, and force RTL
        // ourselves in `builder` below.
        localizationsDelegates: const [
          AppLocalizations.delegate,
          KuMaterialLocalizationsDelegate(),
          KuCupertinoLocalizationsDelegate(),
        ],
        builder: (context, child) => Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const RoleSelectScreen(),
      ),
    );
  }
}
