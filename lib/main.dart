import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager_flutter/config/router/router.dart';
import 'package:money_manager_flutter/config/theme/app_theme.dart';

import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final int selectedColorIndex = 0;
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      // locale: Locale('es'), // Uncomment to test a specific locale
      theme: AppTheme(selectedColorIndex: selectedColorIndex).lightTheme,
      darkTheme: AppTheme(selectedColorIndex: selectedColorIndex).darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.inversePrimary,
        title: Text(localizations.appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(localizations.helloWorld, style: textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
