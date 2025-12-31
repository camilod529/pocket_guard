import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/presentation/screens/account_form_screen.dart';
import 'package:pocket_guard/presentation/screens/category_form_screen.dart';
import 'package:pocket_guard/presentation/screens/settings/language_settings_screen.dart';
import 'package:pocket_guard/presentation/screens/settings/theme_settings_screen.dart';
import 'package:pocket_guard/presentation/screens/stats/monthly_insights_screen.dart';
import 'package:pocket_guard/presentation/screens/transaction_form_screen.dart';
import 'package:pocket_guard/presentation/views/account_view.dart';
import 'package:pocket_guard/presentation/views/calendar_view.dart';
import 'package:pocket_guard/presentation/views/category_view.dart';
import 'package:pocket_guard/presentation/views/more_view.dart';
import 'package:pocket_guard/presentation/widgets/shared/shell_navigation.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.calendar,
  routes: [
    // 1. The Shell (With Bottom Nav)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ShellNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.calendar,
              builder: (context, state) => const CalendarView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.accounts,
              builder: (context, state) => const AccountView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.categories,
              builder: (context, state) => const CategoryView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.more,
              builder: (context, state) => const MoreView(),
            ),
          ],
        ),
      ],
    ),

    // 2. The Root Routes (Without Bottom Nav)
    // These are siblings to the ShellRoute, so they use the Root Navigator
    GoRoute(
      path: Routes.transactionForm,
      parentNavigatorKey: _rootNavigatorKey, // Explicitly use root
      builder: (context, state) {
        final transactionId = state.pathParameters['id'];
        final extra = state.extra as Set<DateTime>?;
        return TransactionFormScreen(
          transactionId: transactionId ?? GlobalConstants.createId,
          selectedDate: extra?.first,
        );
      },
    ),
    GoRoute(
      path: Routes.accountForm,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final accountId = state.pathParameters['id'];
        return AccountFormScreen(
          accountId: accountId ?? GlobalConstants.createId,
        );
      },
    ),
    GoRoute(
      path: Routes.categoryForm,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final categoryId = state.pathParameters['id'];
        return CategoryFormScreen(
          categoryId: categoryId ?? GlobalConstants.createId,
        );
      },
    ),
    GoRoute(
      path: Routes.insights,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        return MonthlyInsightsScreen();
      },
    ),
    GoRoute(
      path: Routes.themeSettings,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ThemeSettingsScreen(),
    ),
    GoRoute(
      path: Routes.languageSettings,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LanguageSettingsScreen(),
    ),
  ],
);

final _rootNavigatorKey = GlobalKey<NavigatorState>();
