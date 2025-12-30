import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/hero/hero_tags.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/selected_date_range_provider.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';

class ShellNavigation extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ShellNavigation({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = navigationShell.currentIndex;
    final selectedDay = ref.watch(
      selectedDateRangeProvider.select((dateRange) => dateRange.selectedDay),
    );

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.calendar_month),
            label: l10n.calendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance),
            label: l10n.accounts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.category),
            label: l10n.categories,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            label: l10n.more,
          ),
        ],
      ),
      // Only show FAB if we aren't on the "More" tab (index 3)
      floatingActionButton: currentIndex == 3
          ? null
          : _buildDynamicFab(context, currentIndex, l10n, selectedDay),
    );
  }

  Widget _buildDynamicFab(
    BuildContext context,
    int index,
    AppLocalizations l10n,
    DateTime selectedDay,
  ) {
    final String label;
    final String heroTag;
    final VoidCallback onPressed;

    switch (index) {
      case 0: // Calendar
        label = l10n.createTransaction;
        heroTag = HeroTags.calendarFab;
        onPressed = () => context.push(
          Routes.transactionFormPage(GlobalConstants.createId),
          extra: {selectedDay},
        );
        break;
      case 1: // Accounts
        label = l10n.createAccount;
        heroTag = HeroTags.accountFab;
        onPressed = () =>
            context.push(Routes.accountFormPage(GlobalConstants.createId));
        break;
      case 2: // Categories
        label = l10n.createCategory;
        heroTag = HeroTags.categoryFab;
        onPressed = () =>
            context.push(Routes.categoryFormPage(GlobalConstants.createId));
        break;
      default:
        return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      heroTag: heroTag,
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Text(label, key: ValueKey<String>(label)),
      ),
    );
  }
}
