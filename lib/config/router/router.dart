import 'package:go_router/go_router.dart';
import 'package:money_manager_flutter/config/router/routes.dart';
import 'package:money_manager_flutter/presentation/screens/home_screen.dart';

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
  ],
);
