import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager_flutter/config/router/router.dart';
import 'package:money_manager_flutter/config/theme/app_theme.dart';
import 'package:money_manager_flutter/presentation/providers/settings_providers.dart';

import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeIndexAsync = ref.watch(themeIndexProvider);
    final localeAsync = ref.watch(localeProvider);

    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      locale: localeAsync.when(
        data: (localeCode) => Locale(localeCode),
        loading: () => const Locale('es'),
        error: (_, _) => const Locale('es'),
      ),
      theme: themeIndexAsync.when(
        data: (themeIndex) =>
            AppTheme(selectedColorIndex: themeIndex).lightTheme,
        loading: () => AppTheme().lightTheme,
        error: (_, _) => AppTheme().lightTheme,
      ),
      darkTheme: themeIndexAsync.when(
        data: (themeIndex) =>
            AppTheme(selectedColorIndex: themeIndex).darkTheme,
        loading: () => AppTheme().darkTheme,
        error: (_, _) => AppTheme().darkTheme,
      ),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
