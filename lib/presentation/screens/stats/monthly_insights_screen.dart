import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/transaction.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:pocket_guard/presentation/widgets/stats/stat_card.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

class MonthlyInsightsScreen extends ConsumerWidget {
  const MonthlyInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Insights')),
      body: transactionsAsync.when(
        data: (transactions) => categoriesAsync.when(
          data: (categories) => accountsAsync.when(
            data: (accounts) => _InsightsContent(
              transactions: transactions,
              categories: categories,
              accounts: accounts,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading accounts: $e')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading categories: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading transactions: $e')),
      ),
    );
  }
}

class _InsightsContent extends StatefulWidget {
  final List<TransactionEntity> transactions;
  final List<CategoryEntity> categories;
  final List<AccountEntity> accounts;

  const _InsightsContent({
    required this.transactions,
    required this.categories,
    required this.accounts,
  });

  @override
  State<_InsightsContent> createState() => _InsightsContentState();
}

class _InsightsContentState extends State<_InsightsContent> {
  String? selectedCurrency;
  String? selectedAccountId;

  @override
  Widget build(BuildContext context) {
    final categoryMap = {for (var c in widget.categories) c.id: c};
    final accountMap = {for (var a in widget.accounts) a.id: a};

    final currencies = widget.accounts.map((a) => a.currency).toSet().toList();

    final accountsInCurrency = widget.accounts
        .where((a) => a.currency == selectedCurrency)
        .toList();

    final filteredTxs = widget.transactions.where((tx) {
      final account = accountMap[tx.accountId];
      if (account == null || account.currency != selectedCurrency) return false;
      return selectedAccountId == null || tx.accountId == selectedAccountId;
    }).toList();

    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> expenseByCategory = {};

    for (var tx in filteredTxs) {
      final cat = categoryMap[tx.categoryId];
      if (cat?.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else if (cat?.type == TransactionType.expense) {
        totalExpense += tx.amount;
        expenseByCategory.update(
          tx.categoryId,
          (v) => v + tx.amount,
          ifAbsent: () => tx.amount,
        );
      }
    }

    final currentCurrency = selectedCurrency ?? 'USD';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Currency", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildCurrencySelector(currencies),

          const SizedBox(height: 16),
          const Text("Account", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildAccountSelector(accountsInCurrency),

          const SizedBox(height: 24),
          _buildSummaryCards(
            context,
            income: totalIncome,
            expense: totalExpense,
            currency: currentCurrency,
          ),
          const SizedBox(height: 24),
          _buildLineChart(filteredTxs, currentCurrency),

          const SizedBox(height: 32),
          const Text(
            'Expenses by Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPieChart(expenseByCategory, categoryMap, currentCurrency),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.accounts.isNotEmpty) {
      selectedCurrency = widget.accounts.first.currency;
    }
  }

  Widget _buildAccountSelector(List<AccountEntity> accounts) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All Accounts'),
            selected: selectedAccountId == null,
            onSelected: (_) => setState(() => selectedAccountId = null),
          ),
          ...accounts.map(
            (account) => Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ChoiceChip(
                label: Text(account.name),
                selected: selectedAccountId == account.id,
                onSelected: (_) =>
                    setState(() => selectedAccountId = account.id),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(List<String> currencies) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: currencies
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c),
                  selected: selectedCurrency == c,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        selectedCurrency = c;
                        selectedAccountId =
                            null; // Reset account when switching currency
                      });
                    }
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildLineChart(List<TransactionEntity> txs, String currency) {
    final chartDate = txs.isNotEmpty ? txs.first.date : DateTime.now();
    final spots = _generateDailySpots(txs, chartDate);
    final colors = Theme.of(context).colorScheme;

    if (spots.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text("No data for this period")),
      );
    }

    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    double range = (maxY - minY).abs();
    maxY = maxY + (range * 0.1);
    minY = minY - (range * 0.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Balance Trend',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          padding: const EdgeInsets.only(
            right: 20,
            top: 10,
            bottom: 10,
            left: 10,
          ),
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) => colors.secondaryContainer,
                  getTooltipItems: (touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      return LineTooltipItem(
                        NumberFormatting.formatCurrencyWithSymbol(
                          barSpot.y,
                          currency,
                        ),
                        TextStyle(
                          color: colors.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: range > 0 ? range / 4 : 1,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: colors.outlineVariant.withAlpha(50),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 52,
                    interval: range > 0 ? range / 4 : 1,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      space: 8,
                      child: Text(
                        NumberFormatting.formatCompactCurrency(value, currency),
                        style: TextStyle(
                          color: colors.outline,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    interval: 7,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      space: 8,
                      child: Text(
                        value.toInt().toString(),
                        style: TextStyle(color: colors.outline, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: colors.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.primary.withAlpha(80),
                        colors.primary.withAlpha(0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(
    Map<String, double> data,
    Map<String, CategoryEntity> catMap,
    String currency,
  ) {
    if (data.isEmpty) return const Center(child: Text('No expenses found'));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: data.entries.map((entry) {
                final index = data.keys.toList().indexOf(entry.key);
                return PieChartSectionData(
                  value: entry.value,
                  title: '',
                  radius: 50,
                  color: Colors.primaries[index % Colors.primaries.length],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...data.entries.map((entry) {
          final index = data.keys.toList().indexOf(entry.key);
          final color = Colors.primaries[index % Colors.primaries.length];
          final label = catMap[entry.key]?.label ?? 'Other';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(label)),
                Text(
                  NumberFormatting.formatCompactCurrency(entry.value, currency),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSummaryCards(
    BuildContext context, {
    required double income,
    required double expense,
    required String currency,
  }) {
    final colors = Theme.of(context).colorScheme;

    final green = colors.brightness == Brightness.dark
        ? Colors.green.shade200
        : Colors.green.shade700;

    return Row(
      children: [
        StatCard(
          label: 'Total Income',
          value: income,
          color: green,
          currency: currency,
        ),
        const SizedBox(width: 16),
        StatCard(
          label: 'Total Expense',
          value: expense,
          color: colors.error,
          currency: currency,
        ),
      ],
    );
  }

  List<FlSpot> _generateDailySpots(
    List<TransactionEntity> txs,
    DateTime month,
  ) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final Map<int, double> dailyChanges = {};

    for (var tx in txs) {
      final day = tx.date.day;
      final isExpense =
          widget.categories.firstWhere((c) => c.id == tx.categoryId).type ==
          TransactionType.expense;
      final amount = isExpense ? -tx.amount : tx.amount;

      dailyChanges.update(day, (v) => v + amount, ifAbsent: () => amount);
    }

    double runningBalance =
        0; //TODO: Simplified for V0.3.0: Change from start of month
    List<FlSpot> spots = [];

    for (int i = 1; i <= lastDay; i++) {
      runningBalance += dailyChanges[i] ?? 0;
      spots.add(FlSpot(i.toDouble(), runningBalance));
    }
    return spots;
  }
}
