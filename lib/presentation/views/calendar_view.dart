import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/selected_date_range_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transaction_filter_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/ui_visibility_provider.dart';
import 'package:pocket_guard/presentation/widgets/transactions/transaction_filter_sheet.dart';
import 'package:pocket_guard/utils/shared/dates/calendar_date_formatter.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  // Key to trigger animation on day selection
  Key _selectedDayKey = UniqueKey();
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final dateRange = ref.watch(selectedDateRangeProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final selectedDay = dateRange.selectedDay;

    return Scaffold(
      appBar: _buildCustomAppBar(dateRange),
      body: Column(
        children: [
          _buildMonthCalendar(transactionsAsync),
          const Divider(height: 1),
          Expanded(
            child: _buildTransactionsList(
              transactionsAsync,
              categoriesAsync,
              accountsAsync,
              selectedDay,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      ref
          .read(selectedDateRangeProvider.notifier)
          .selectMonth(now.year, now.month);
    });
  }

  Widget _buildCalendarGrid(List<TransactionEntity> transactions) {
    final dateRange = ref.read(selectedDateRangeProvider);
    final firstDayOfMonth = dateRange.start;
    final lastDayOfMonth = dateRange.end;
    final selectedDay = dateRange.selectedDay;

    int firstWeekday = firstDayOfMonth.weekday;

    final daysFromPreviousMonth = firstWeekday - 1;

    // Calculate total cells needed
    final totalDays = lastDayOfMonth.day;
    final totalCells = daysFromPreviousMonth + totalDays;
    final rows = (totalCells / 7).ceil();

    final today = DateTime.now();

    final transactionsByDay = <int, List<TransactionEntity>>{};
    for (final transaction in transactions) {
      final day = transaction.date.day;
      transactionsByDay.putIfAbsent(day, () => []).add(transaction);
    }

    return Column(
      children: List.generate(rows, (weekIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (dayIndex) {
            final cellIndex = weekIndex * 7 + dayIndex;
            final dayNumber = cellIndex - daysFromPreviousMonth + 1;

            if (dayNumber < 1 || dayNumber > totalDays) {
              return const Expanded(child: SizedBox(height: 48));
            }

            final cellDate = DateTime(
              firstDayOfMonth.year,
              firstDayOfMonth.month,
              dayNumber,
            );
            final isToday =
                cellDate.year == today.year &&
                cellDate.month == today.month &&
                cellDate.day == today.day;

            final isSelected =
                cellDate.year == selectedDay.year &&
                cellDate.month == selectedDay.month &&
                cellDate.day == selectedDay.day;

            final hasTransactions = transactionsByDay.containsKey(dayNumber);

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(selectedDateRangeProvider.notifier)
                      .selectDay(cellDate);
                  setState(() {
                    _selectedDayKey = UniqueKey();
                  });
                },
                child: _buildDayCell(
                  key: isSelected ? _selectedDayKey : null,
                  dayNumber: dayNumber,
                  isToday: isToday,
                  isSelected: isSelected,
                  hasTransactions: hasTransactions,
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(DateRangeSelection dateRange) {
    if (_isSearching) {
      return AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          onChanged: (val) => ref
              .read(transactionSearchFilterProvider.notifier)
              .updateSearchQuery(val),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() => _isSearching = false);
            ref
                .read(transactionSearchFilterProvider.notifier)
                .updateSearchQuery('');
          },
        ),
      );
    }
    return AppBar(
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => setState(() => _isSearching = true),
        ),
        IconButton(
          icon: Badge(
            isLabelVisible:
                !(ref
                        .watch(transactionSearchFilterProvider)
                        .categoryIds
                        ?.isEmpty ??
                    true) ||
                (ref
                        .watch(transactionSearchFilterProvider)
                        .searchQuery
                        ?.isNotEmpty ??
                    false),
            child: const Icon(Icons.filter_list),
          ),
          onPressed: () => _showFilterSheet(context),
        ),
        IconButton(
          onPressed: () => context.push(Routes.insights),
          icon: const Icon(Icons.bar_chart_rounded),
        ),
      ],
    );
  }

  Widget _buildDayCell({
    Key? key,
    required int dayNumber,
    required bool isToday,
    required bool isSelected,
    required bool hasTransactions,
  }) {
    final colors = Theme.of(context).colorScheme;

    Color? backgroundColor;
    Color? textColor;

    if (isSelected) {
      backgroundColor = colors.primary;
      textColor = colors.onPrimary;
    } else if (isToday) {
      backgroundColor = colors.primaryContainer;
      textColor = colors.onPrimaryContainer;
    }

    final cell = Container(
      height: 48,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: colors.primary, width: 2) : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '$dayNumber',
              style: TextStyle(
                fontWeight: isToday || isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
          if (hasTransactions)
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isSelected ? colors.onPrimary : colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (isSelected && key != null) {
      return FadeIn(
        key: key,
        duration: const Duration(milliseconds: 250),
        child: cell,
      );
    }

    return cell;
  }

  Widget _buildMonthCalendar(
    AsyncValue<List<TransactionEntity>> transactionsAsync,
  ) {
    final dateRange = ref.watch(selectedDateRangeProvider);
    final dateFormatter = CalendarDateFormatter(
      Localizations.localeOf(context),
    );
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
                tooltip: l10n.calendarPreviousMonth,
              ),
              Text(
                dateFormatter.formatMonthYear(dateRange.start),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              IconButton(
                onPressed: _goToToday,
                icon: const Icon(Icons.today),
                tooltip: l10n.calendarToday,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
                tooltip: l10n.calendarNextMonth,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildWeekdayHeaders(),
          const SizedBox(height: 8),
          transactionsAsync.when(
            data: (transactions) => _buildCalendarGrid(transactions),
            loading: () => const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SizedBox(
              height: 300,
              child: Center(
                child: Text(l10n.errorLoadingCalendar(error.toString())),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    TransactionEntity transaction,
    CategoryEntity? category,
    AccountEntity? account,
    Map<String, AccountEntity> accountMap,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final TransactionType type =
        category?.type ??
        (transaction.amount > 0
            ? TransactionType.income
            : TransactionType.expense);

    IconData icon;
    Color iconColor;

    final income = isDark ? Colors.green.shade300 : Colors.green.shade700;
    final expense = isDark ? Colors.red.shade300 : Colors.red.shade700;
    final transfer = colors.tertiary;

    switch (type) {
      case TransactionType.income:
        icon = Icons.arrow_downward;
        iconColor = income;
        break;
      case TransactionType.expense:
        icon = Icons.arrow_upward;
        iconColor = expense;
        break;
      case TransactionType.transfer:
        icon = Icons.swap_horiz;
        iconColor = transfer;
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withAlpha(30),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(transaction.description ?? l10n.noDescription),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${DateFormat.jm().format(transaction.date)} • ${category?.label ?? l10n.unknownCategory}',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          Text(
            account != null
                ? l10n.accountLabel(account.name)
                : l10n.noAccountInfo,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: Builder(
        builder: (context) {
          final account = accountMap[transaction.accountId];
          final currency = account?.currency ?? 'USD';

          final displayAmount = NumberFormatting.formatCurrencyWithSymbol(
            transaction.amount.abs(),
            currency,
          );

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                displayAmount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: type == TransactionType.expense
                      ? expense
                      : (type == TransactionType.income ? income : null),
                ),
              ),
              if (account != null)
                Text(
                  account.currency.toUpperCase(),
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
            ],
          );
        },
      ),

      onTap: () {
        context.push(Routes.transactionFormPage(transaction.id));
      },
    );
  }

  Widget _buildTransactionsList(
    AsyncValue<List<TransactionEntity>> transactionsAsync,
    AsyncValue<List<CategoryEntity>> categoriesAsync,
    AsyncValue<List<AccountEntity>> accountsAsync,
    DateTime selectedDay,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormatter = CalendarDateFormatter(
      Localizations.localeOf(context),
    );

    return transactionsAsync.when(
      data: (allTransactions) {
        final selectedDayTransactions = allTransactions.where((transaction) {
          return transaction.date.year == selectedDay.year &&
              transaction.date.month == selectedDay.month &&
              transaction.date.day == selectedDay.day;
        }).toList()..sort((a, b) => b.date.compareTo(a.date));

        if (selectedDayTransactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noTransactionsOnDate(
                    dateFormatter.formatShortDate(selectedDay),
                  ),
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return categoriesAsync.when(
          data: (categories) {
            final categoryMap = {for (var cat in categories) cat.id: cat};

            return accountsAsync.when(
              data: (accounts) {
                final accountMap = {for (var acc in accounts) acc.id: acc};

                return ListView.builder(
                  // ADDED PADDING: 80px at bottom to clear the FAB
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: selectedDayTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = selectedDayTransactions[index];
                    final category = categoryMap[transaction.categoryId];
                    final account = accountMap[transaction.accountId];
                    return _buildTransactionItem(
                      transaction,
                      category,
                      account,
                      accountMap,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(l10n.errorLoadingAccounts(error.toString())),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(l10n.errorLoadingCategories(error.toString())),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text(l10n.errorLoadingTransactions(error.toString()))),
    );
  }

  Widget _buildWeekdayHeaders() {
    final l10n = AppLocalizations.of(context)!;
    final weekdays = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _goToToday() {
    final now = DateTime.now();
    ref.read(selectedDateRangeProvider.notifier).selectDay(now);
    setState(() {
      _selectedDayKey = UniqueKey();
    });
    ref
        .read(selectedDateRangeProvider.notifier)
        .selectMonth(now.year, now.month);
  }

  void _nextMonth() {
    final dateRange = ref.read(selectedDateRangeProvider);
    final nextMonth = DateTime(dateRange.start.year, dateRange.start.month + 1);
    final now = DateTime.now();

    setState(() {
      if (nextMonth.year == now.year && nextMonth.month == now.month) {
        ref.read(selectedDateRangeProvider.notifier).selectDay(now);
      } else {
        ref
            .read(selectedDateRangeProvider.notifier)
            .selectDay(DateTime(nextMonth.year, nextMonth.month, 1));
      }
      _selectedDayKey = UniqueKey();
    });

    ref
        .read(selectedDateRangeProvider.notifier)
        .selectMonth(nextMonth.year, nextMonth.month);
  }

  void _previousMonth() {
    final dateRange = ref.read(selectedDateRangeProvider);
    final prevMonth = DateTime(dateRange.start.year, dateRange.start.month - 1);
    final now = DateTime.now();

    setState(() {
      if (prevMonth.year == now.year && prevMonth.month == now.month) {
        ref.read(selectedDateRangeProvider.notifier).selectDay(now);
      } else {
        ref
            .read(selectedDateRangeProvider.notifier)
            .selectDay(DateTime(prevMonth.year, prevMonth.month, 1));
      }
      _selectedDayKey = UniqueKey();
    });

    ref
        .read(selectedDateRangeProvider.notifier)
        .selectMonth(prevMonth.year, prevMonth.month);
  }

  void _showFilterSheet(BuildContext context) {
    ref.read(filterSheetVisibilityProvider.notifier).show();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const TransactionFilterSheet(),
    ).whenComplete(() {
      // 2. Notify that sheet is closed (FAB returns)
      ref.read(filterSheetVisibilityProvider.notifier).hide();
    });
  }
}
