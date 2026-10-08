import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/localization/ku_fallback_localizations.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start Firebase if it is configured; otherwise the app runs offline.
  await FirebaseService.init();

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
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthServiceFactory.create()..init(),
        ),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
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
    final theme = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    // Swap the global palette BEFORE the app tree builds.
    AppColors.palette = theme.isDark ? AppPalette.dark : AppPalette.light;
    final locale = localeProvider.locale;

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
        textDirection: localeProvider.isRtl
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const SplashScreen(),
    );
  }
}
