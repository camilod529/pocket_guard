import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/domain/entities/savings_goal.dart';
import 'package:pocket_guard/domain/services/affordability_calculator.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:pocket_guard/presentation/providers/wishlist/wishlist_affordability_provider.dart';
import 'package:pocket_guard/presentation/providers/wishlist/wishlist_provider.dart';
import 'package:pocket_guard/presentation/widgets/shared/refreshable_placeholder.dart';
import 'package:pocket_guard/presentation/widgets/wishlist/purchase_flow.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:pocket_guard/utils/shared/dates/calendar_date_formatter.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

class WishlistView extends ConsumerWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affordabilityAsync = ref.watch(wishlistAffordabilityProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wishlist),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addWishlistItem,
            onPressed: () =>
                context.push(Routes.wishlistFormPage(GlobalConstants.createId)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(wishlistProvider.notifier).refresh(),
        child: affordabilityAsync.when(
          data: (items) => _buildList(context, ref, items, l10n),
          loading: () =>
              const RefreshablePlaceholder(child: CircularProgressIndicator()),
          error: (error, stack) => RefreshablePlaceholder(
            child: Text(l10n.error_unknown_data, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<Affordability> items,
    AppLocalizations l10n,
  ) {
    if (items.isEmpty) {
      return RefreshablePlaceholder(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noWishlistItemsMessage,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => context.push(
                Routes.wishlistFormPage(GlobalConstants.createId),
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.addWishlistItem),
            ),
          ],
        ),
      );
    }

    final goalsById = {
      for (final g
          in ref.watch(savingsGoalsProvider).value ??
              const <SavingsGoalEntity>[])
        g.id: g,
    };
    final wanted = items.where((a) => !a.item.isPurchased).toList();
    final bought = items.where((a) => a.item.isPurchased).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
      children: [
        for (final a in wanted)
          _WishlistCard(
            affordability: a,
            goalName: goalsById[a.item.goalId]?.name,
            onBuy: () => purchaseWishlistItem(context, ref, a.item),
          ),
        if (bought.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
            child: Text(
              l10n.wishlistPurchasedSection,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final a in bought)
            Opacity(
              opacity: 0.6,
              child: _WishlistCard(affordability: a, goalName: null),
            ),
        ],
      ],
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final Affordability affordability;
  final String? goalName;
  final VoidCallback? onBuy;

  const _WishlistCard({
    required this.affordability,
    required this.goalName,
    this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final item = affordability.item;
    String money(double value) =>
        NumberFormatting.formatCurrencyWithSymbol(value, item.currency);

    final (
      IconData icon,
      Color color,
      String text,
    ) = switch (affordability.status) {
      AffordabilityStatus.affordable => (
        Icons.check_circle,
        Colors.green,
        affordability.coveredByGoal && goalName != null
            ? l10n.wishlistCoveredByGoal(goalName!)
            : l10n.wishlistAffordable,
      ),
      AffordabilityStatus.overBudget => (
        Icons.warning_amber_rounded,
        Colors.orange,
        l10n.wishlistOverBudget(money(affordability.shortfall)),
      ),
      AffordabilityStatus.insufficientFunds => (
        Icons.cancel,
        Colors.red,
        l10n.wishlistInsufficientFunds(money(affordability.shortfall)),
      ),
      AffordabilityStatus.purchased => (
        Icons.shopping_bag,
        Theme.of(context).colorScheme.onSurfaceVariant,
        l10n.wishlistPurchasedOn(
          CalendarDateFormatter(
            Localizations.localeOf(context),
          ).formatFullDate(item.purchasedAt!),
        ),
      ),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(Routes.wishlistFormPage(item.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    money(item.price),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(color: color, fontSize: 13),
                    ),
                  ),
                  if (onBuy != null)
                    // Can't buy what the accounts can't cover - the
                    // transaction form's overdraft check would refuse it.
                    FilledButton.tonal(
                      onPressed:
                          affordability.status ==
                              AffordabilityStatus.insufficientFunds
                          ? null
                          : onBuy,
                      child: Text(l10n.buyWishlistItem),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
