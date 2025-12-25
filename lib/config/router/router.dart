import 'package:go_router/go_router.dart';
import 'package:money_manager_flutter/config/router/routes.dart';
import 'package:money_manager_flutter/presentation/screens/account_form_screen.dart';
import 'package:money_manager_flutter/presentation/screens/home_screen.dart';
import 'package:money_manager_flutter/presentation/screens/transaction_form_screen.dart';
import 'package:money_manager_flutter/utils/constants/global_constants.dart';

final appRouter = GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) {
        final pageIndex =
            int.tryParse(state.pathParameters['page'] ?? '0') ?? 0;

        return HomeScreen(pageIndex: pageIndex);
      },
    ),

    GoRoute(
      path: Routes.accountForm,
      builder: (context, state) {
        final accountId = state.pathParameters['id'];
        return AccountFormScreen(
          accountId: accountId ?? GlobalConstants.createId,
        );
      },
    ),

    GoRoute(
      path: Routes.transactionForm,
      builder: (context, state) {
        final transactionId = state.pathParameters['id'];
        final extra = state.extra as Set<DateTime>?;
        final selectedDate = extra != null && extra.isNotEmpty
            ? extra.first
            : null;
        return TransactionFormScreen(
          transactionId: transactionId ?? GlobalConstants.createId,
          selectedDate: selectedDate,
        );
      },
    ),
  ],
);
