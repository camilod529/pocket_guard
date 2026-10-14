import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/domain/entities/backup.dart';
import 'package:pocket_guard/presentation/screens/account_form_screen.dart';
import 'package:pocket_guard/presentation/screens/backup_restore_screen.dart';
import 'package:pocket_guard/presentation/screens/backup_screen.dart';
import 'package:pocket_guard/presentation/screens/budget_form_screen.dart';
import 'package:pocket_guard/presentation/screens/goal_detail_screen.dart';
import 'package:pocket_guard/presentation/screens/savings_goal_form_screen.dart';
import 'package:pocket_guard/presentation/screens/category_form_screen.dart';
import 'package:pocket_guard/presentation/screens/recurring_transaction_form_screen.dart';
import 'package:pocket_guard/presentation/screens/settings/language_settings_screen.dart';
import 'package:pocket_guard/presentation/screens/settings/theme_settings_screen.dart';
import 'package:pocket_guard/presentation/screens/stats/monthly_insights_screen.dart';
import 'package:pocket_guard/presentation/providers/transaction/transaction_prefill.dart';
import 'package:pocket_guard/presentation/screens/transaction_form_screen.dart';
import 'package:pocket_guard/presentation/screens/wishlist_form_screen.dart';
import 'package:pocket_guard/presentation/views/account_view.dart';
import 'package:pocket_guard/presentation/views/budget_view.dart';
import 'package:pocket_guard/presentation/views/goal_view.dart';
import 'package:pocket_guard/presentation/views/calendar_view.dart';
import 'package:pocket_guard/presentation/views/category_view.dart';
import 'package:pocket_guard/presentation/views/more_view.dart';
import 'package:pocket_guard/presentation/views/wishlist_view.dart';
import 'package:pocket_guard/presentation/views/recurring_transaction_view.dart';
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
        // extra is either a Set<DateTime> (the calendar's selected day) or
        // a TransactionPrefill (e.g. buying a wishlist item).
        final extra = state.extra;
        return TransactionFormScreen(
          transactionId: transactionId ?? GlobalConstants.createId,
          selectedDate: extra is Set<DateTime> ? extra.first : null,
          prefill: extra is TransactionPrefill ? extra : null,
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
      path: Routes.recurringTransactions,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RecurringTransactionView(),
    ),
    GoRoute(
      path: Routes.recurringTransactionForm,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return RecurringTransactionFormScreen(
          recurringTransactionId: id ?? GlobalConstants.createId,
        );
      },
    ),
    GoRoute(
      path: Routes.budgets,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BudgetView(),
    ),
    GoRoute(
      path: Routes.budgetForm,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return BudgetFormScreen(budgetId: id ?? GlobalConstants.createId);
      },
    ),
    GoRoute(
      path: Routes.goals,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const GoalView(),
    ),
    // Before goalDetail: '/goal/:id' would otherwise also match
    // '/goal/form/...'.
    GoRoute(
      path: Routes.savingsGoalForm,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return SavingsGoalFormScreen(goalId: id ?? GlobalConstants.createId);
      },
    ),
    GoRoute(
      path: Routes.goalDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          GoalDetailScreen(goalId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: Routes.wishlist,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WishlistView(),
    ),
    GoRoute(
      path: Routes.wishlistForm,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return WishlistFormScreen(itemId: id ?? GlobalConstants.createId);
      },
    ),
    GoRoute(
      path: Routes.backup,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BackupScreen(),
    ),
    GoRoute(
      path: Routes.backupRestore,
      parentNavigatorKey: _rootNavigatorKey,
      // Only reachable from BackupScreen, which passes the decoded backup.
      builder: (context, state) =>
          BackupRestoreScreen(contents: state.extra! as BackupContents),
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
