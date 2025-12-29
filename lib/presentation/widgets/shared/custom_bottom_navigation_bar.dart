import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavigationBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BottomNavigationBar(
      elevation: 0,
      currentIndex: currentIndex,
      onTap: (value) => _onItemTap(context, value),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: localizations.calendar,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined),
          label: localizations.accounts,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          label: localizations.more,
        ),
      ],
    );
  }

  void _onItemTap(BuildContext context, int index) {
    context.go(Routes.changeViewPage(index));
  }
}
