import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(),
      body: Column(
        children: [
          _buildMonthCalendar(),
          const Divider(height: 1),
          Expanded(child: _buildTransactionsList()),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    );

    // Get the weekday of the first day (1 = Monday, 7 = Sunday)
    int firstWeekday = firstDayOfMonth.weekday;

    // Calculate how many days to show from previous month
    final daysFromPreviousMonth = firstWeekday - 1;

    // Calculate total cells needed
    final totalDays = lastDayOfMonth.day;
    final totalCells = daysFromPreviousMonth + totalDays;
    final rows = (totalCells / 7).ceil();

    final today = DateTime.now();

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
              _selectedMonth.year,
              _selectedMonth.month,
              dayNumber,
            );
            final isToday =
                cellDate.year == today.year &&
                cellDate.month == today.month &&
                cellDate.day == today.day;

            // Placeholder: Check if day has transactions
            final hasTransactions = dayNumber % 3 == 0; // Mock data

            return Expanded(
              child: _buildDayCell(
                dayNumber: dayNumber,
                isToday: isToday,
                hasTransactions: hasTransactions,
              ),
            );
          }),
        );
      }),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    final monthYear = DateFormat.yMMMM().format(_selectedMonth);
    final isCurrentMonth =
        _selectedMonth.year == DateTime.now().year &&
        _selectedMonth.month == DateTime.now().month;

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
    required int dayNumber,
    required bool isToday,
    required bool hasTransactions,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 48,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isToday ? colors.primaryContainer : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '$dayNumber',
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : null,
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
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWeekdayHeaders(),
          const SizedBox(height: 8),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final type = transaction['type'] as String;
    final amount = transaction['amount'] as double;
    final description = transaction['description'] as String;
    final date = transaction['date'] as DateTime;
    final category = transaction['category'] as String;
    final colors = Theme.of(context).colorScheme;

    IconData icon;
    Color iconColor = colors.onSurface;
    String amountPrefix;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final income = isDark ? Colors.green.shade300 : Colors.green.shade700;
    final expense = isDark ? Colors.red.shade300 : Colors.red.shade700;
    final transfer = colors.tertiary;

    switch (type) {
      case 'in':
        icon = Icons.arrow_downward;
        iconColor = income;
        amountPrefix = '+';
        break;
      case 'out':
        icon = Icons.arrow_upward;
        iconColor = expense;
        amountPrefix = '-';
        break;
      case 'transfer':
        icon = Icons.swap_horiz;
        iconColor = transfer;
        amountPrefix = '';
        break;
      default:
        icon = Icons.help_outline;
        iconColor = Colors.grey;
        amountPrefix = '';
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withAlpha(30),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(description),
      subtitle: Text('${DateFormat.MMMd().format(date)} • $category'),
      trailing: Text(
        '$amountPrefix\$${amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: type == 'out'
              ? Colors.red
              : (type == 'in' ? Colors.green : null),
        ),
      ),
      onTap: () {
        // TODO: Navigate to transaction detail
      },
    );
  }

  Widget _buildTransactionsList() {
    // Placeholder transaction data
    final transactions = _generatePlaceholderTransactions();

    if (transactions.isEmpty) {
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
              'No transactions this month',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(transaction);
      },
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

  List<Map<String, dynamic>> _generatePlaceholderTransactions() {
    return List.generate(15, (index) {
      final dayOffset = (index * 2) % 28 + 1;
      final transactionDate = DateTime(
        _selectedMonth.year,
        _selectedMonth.month,
        dayOffset,
      );

      final types = ['in', 'out', 'transfer'];
      final type = types[index % 3];

      final descriptions = {
        'in': [
          'Salary',
          'Freelance payment',
          'Gift',
          'Refund',
          'Investment return',
        ],
        'out': ['Groceries', 'Restaurant', 'Gas', 'Shopping', 'Utilities'],
        'transfer': [
          'Savings',
          'Investment',
          'Credit card payment',
          'To checking',
        ],
      };

      final categories = {
        'in': ['Income', 'Work', 'Gift', 'Investment'],
        'out': ['Food', 'Transport', 'Shopping', 'Bills'],
        'transfer': ['Savings', 'Investment', 'Credit'],
      };

      final amounts = {
        'in': [1500.00, 2500.00, 500.00, 150.00, 3000.00],
        'out': [45.50, 125.00, 60.75, 200.00, 150.25],
        'transfer': [500.00, 1000.00, 300.00, 750.00],
      };

      return {
        'type': type,
        'amount': amounts[type]![index % amounts[type]!.length],
        'description': descriptions[type]![index % descriptions[type]!.length],
        'date': transactionDate,
        'category': categories[type]![index % categories[type]!.length],
      };
    })..sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );
  }

  void _goToToday() {
    setState(() {
      _selectedMonth = DateTime.now();
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }
}
