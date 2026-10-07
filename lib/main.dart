import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/localization/ku_fallback_localizations.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/role_select_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers/orders_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TailorApp());
}

/// Root of the app. Owns the providers so tests can simply pump [TailorApp].
class TailorApp extends StatelessWidget {
  const TailorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: const _App(),
    );
  }
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    // Kurdish (Sorani) is the default.
    const locale = Locale('ku');
    final isRtl = locale.languageCode == 'ku' || locale.languageCode == 'ar';

    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        // Swap the global palette BEFORE the app tree builds.
        AppColors.palette = theme.isDark ? AppPalette.dark : AppPalette.light;

        return MaterialApp(
          title: 'Terz',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          // Flutter does not ship Kurdish localizations, so we use our own
          // delegate plus the small fallback delegates, and force RTL.
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
        );
      },
    );
  }
}
