import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:money_manager_flutter/config/router/routes.dart';
import 'package:money_manager_flutter/domain/entities/account.dart';
import 'package:money_manager_flutter/domain/entities/category.dart';
import 'package:money_manager_flutter/domain/entities/transaction.dart';
import 'package:money_manager_flutter/presentation/providers/account/accounts_provider.dart';
import 'package:money_manager_flutter/presentation/providers/category/categories_provider.dart';
import 'package:money_manager_flutter/presentation/providers/selected_date_range_provider.dart';
import 'package:money_manager_flutter/presentation/providers/transaction/transactions_provider.dart';
import 'package:money_manager_flutter/utils/constants/global_constants.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  DateTime _selectedDay = DateTime.now();
  // Key to trigger animation on day selection
  Key _selectedDayKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final dateRange = ref.watch(selectedDateRangeProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final accountsAsync = ref.watch(accountsProvider);

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
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(
            Routes.transactionFormPage(GlobalConstants.createId),
            extra: {_selectedDay},
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Set initial month view
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

    // Get the weekday of the first day (1 = Monday, 7 = Sunday)
    int firstWeekday = firstDayOfMonth.weekday;

    // Calculate how many days to show from previous month
    final daysFromPreviousMonth = firstWeekday - 1;

    // Calculate total cells needed
    final totalDays = lastDayOfMonth.day;
    final totalCells = daysFromPreviousMonth + totalDays;
    final rows = (totalCells / 7).ceil();

    final today = DateTime.now();

    // Group transactions by day
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

            // Check if this cell should show a day from current month
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
                cellDate.year == _selectedDay.year &&
                cellDate.month == _selectedDay.month &&
                cellDate.day == _selectedDay.day;

            final hasTransactions = transactionsByDay.containsKey(dayNumber);

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = cellDate;
                    _selectedDayKey = UniqueKey(); // Trigger animation
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
    final monthYear = DateFormat.yMMMM().format(dateRange.start);
    final isCurrentMonth =
        dateRange.start.year == DateTime.now().year &&
        dateRange.start.month == DateTime.now().month;

    return AppBar(
      title: Text(monthYear),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: _previousMonth,
        tooltip: 'Previous month',
      ),
      actions: [
        if (!isCurrentMonth)
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: _goToToday,
            tooltip: 'Go to today',
          ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _nextMonth,
          tooltip: 'Next month',
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

    // Animate only when selected
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
              child: Center(child: Text('Error loading calendar: $error')),
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
  ) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    // Determine transaction type from amount or category
    final TransactionType type =
        category?.type ??
        (transaction.amount > 0
            ? TransactionType.income
            : TransactionType.expense);

    IconData icon;
    Color iconColor;
    String amountPrefix;

    final income = isDark ? Colors.green.shade300 : Colors.green.shade700;
    final expense = isDark ? Colors.red.shade300 : Colors.red.shade700;
    final transfer = colors.tertiary;

    switch (type) {
      case TransactionType.income:
        icon = Icons.arrow_downward;
        iconColor = income;
        amountPrefix = '+';
        break;
      case TransactionType.expense:
        icon = Icons.arrow_upward;
        iconColor = expense;
        amountPrefix = '-';
        break;
      case TransactionType.transfer:
        icon = Icons.swap_horiz;
        iconColor = transfer;
        amountPrefix = '';
        break;
    }

    final displayAmount = transaction.amount.abs();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withAlpha(30),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(transaction.description ?? 'No description'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${DateFormat.jm().format(transaction.date)} • ${category?.label ?? 'Unknown'}',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          Text(
            account != null ? 'Account: ${account.name}' : 'No account info',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: Text(
        '$amountPrefix\$${displayAmount.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: type == TransactionType.expense
              ? expense
              : (type == TransactionType.income ? income : null),
        ),
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
  ) {
    return transactionsAsync.when(
      data: (allTransactions) {
        // Filter transactions for selected day
        final selectedDayTransactions = allTransactions.where((transaction) {
          return transaction.date.year == _selectedDay.year &&
              transaction.date.month == _selectedDay.month &&
              transaction.date.day == _selectedDay.day;
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
                  'No transactions on ${DateFormat.MMMd().format(_selectedDay)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return categoriesAsync.when(
          data: (categories) {
            // Create a map for quick category lookup
            final categoryMap = {for (var cat in categories) cat.id: cat};

            return accountsAsync.when(
              data: (accounts) {
                final accountMap = {for (var acc in accounts) acc.id: acc};
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: selectedDayTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = selectedDayTransactions[index];
                    final category = categoryMap[transaction.categoryId];
                    final account = accountMap[transaction.accountId];
                    return _buildTransactionItem(
                      transaction,
                      category,
                      account,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Error loading accounts: $error')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Error loading categories: $error')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading transactions: $error')),
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
    setState(() {
      _selectedDay = now;
      _selectedDayKey = UniqueKey(); // Trigger animation
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
      // If navigating to current month, select current day
      if (nextMonth.year == now.year && nextMonth.month == now.month) {
        _selectedDay = now;
      } else {
        _selectedDay = DateTime(nextMonth.year, nextMonth.month, 1);
      }
      _selectedDayKey = UniqueKey(); // Trigger animation
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
      // If navigating to current month, select current day
      if (prevMonth.year == now.year && prevMonth.month == now.month) {
        _selectedDay = now;
      } else {
        _selectedDay = DateTime(prevMonth.year, prevMonth.month, 1);
      }
      _selectedDayKey = UniqueKey(); // Trigger animation
    });

    ref
        .read(selectedDateRangeProvider.notifier)
        .selectMonth(prevMonth.year, prevMonth.month);
  }
}
