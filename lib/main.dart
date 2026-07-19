import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/config/router/router.dart';
import 'package:pocket_guard/config/theme/app_theme.dart';
import 'package:pocket_guard/infrastructure/background/recurring_transaction_background_task.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transaction_catch_up_provider.dart';
import 'package:pocket_guard/presentation/providers/settings_providers.dart';
import 'package:workmanager/workmanager.dart';

import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Best-effort periodic catch-up while the app is closed - see
  // recurring_transaction_background_task.dart for why this is a
  // supplement to (not a replacement for) the foreground trigger, and the
  // native iOS setup (AppDelegate.swift + Info.plist) this call depends on.
  await Workmanager().initialize(recurringTransactionCallbackDispatcher);
  await Workmanager().registerPeriodicTask(
    recurringTransactionsTaskName,
    recurringTransactionsTaskName,
    frequency: const Duration(hours: 12),
  );

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // keepAlive - runs once per app process, not on every rebuild. A
    // periodic background task (lib/infrastructure/background/) is a
    // best-effort supplement for while the app is closed; this is the
    // guaranteed trigger. ref.read (not watch): MainApp shouldn't rebuild
    // when catch-up finishes, it just needs to be kicked off once. A
    // failure here must never block app render (the provider logs
    // internally rather than throwing).
    ref.read(recurringTransactionCatchUpProvider);

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
