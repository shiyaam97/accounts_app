import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../models/transaction_model.dart';
import 'dart:math';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Breakdown'),
              Tab(text: 'Trends'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ExpenseBreakdownTab(),
            _TrendsTab(),
          ],
        ),
      ),
    );
  }
}

class _ExpenseBreakdownTab extends StatelessWidget {
  const _ExpenseBreakdownTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state.transactions.isEmpty) {
           return const Center(child: Text('No data available'));
        }

        // 1. Filter Expenses
        final expenses = state.transactions.where((t) => t.type == TransactionType.expense).toList();
        if (expenses.isEmpty) return const Center(child: Text('No expenses recorded'));

        // 2. Group by Category
        final Map<String, double> categoryTotals = {};
        double totalExpense = 0;
        for (var t in expenses) {
          categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
          totalExpense += t.amount;
        }

        // 3. Prepare Chart Data
        final List<PieChartSectionData> sections = categoryTotals.entries.map((entry) {
          final percentage = (entry.value / totalExpense) * 100;
          return PieChartSectionData(
            color: Colors.primaries[categoryTotals.keys.toList().indexOf(entry.key) % Colors.primaries.length],
            value: entry.value,
            title: '${percentage.toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList();

        return Column(
          children: [
            const SizedBox(height: 20),
            Text('Total Expense: ${NumberFormat.currency(symbol: context.watch<SettingsCubit>().state.currency).format(totalExpense)}', style: Theme.of(context).textTheme.titleLarge),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            // Legend
            SizedBox(
              height: 150,
              child: ListView(
                children: categoryTotals.entries.map((e) {
                  final color = Colors.primaries[categoryTotals.keys.toList().indexOf(e.key) % Colors.primaries.length];
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: color, radius: 8),
                    title: Text(e.key),
                    trailing: Text(NumberFormat.currency(symbol: context.watch<SettingsCubit>().state.currency).format(e.value)),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TrendsTab extends StatelessWidget {
  const _TrendsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state.transactions.isEmpty) return const Center(child: Text('No data available'));

        // Last 7 days
        final now = DateTime.now();
        final List<DateTime> days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
        
        final List<BarChartGroupData> barGroups = [];
        
        double maxY = 0;

        for (int i = 0; i < days.length; i++) {
          final date = days[i];
          final dayTransactions = state.transactions.where((t) => 
            t.date.year == date.year && t.date.month == date.month && t.date.day == date.day
          );

          double income = 0;
          double expense = 0;
          for (var t in dayTransactions) {
            if (t.type == TransactionType.income) income += t.amount;
            else expense += t.amount;
          }
          
          if (income > maxY) maxY = income;
          if (expense > maxY) maxY = expense;

          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(toY: income, color: Colors.green, width: 8),
                BarChartRodData(toY: expense, color: Colors.red, width: 8),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
               const Align(alignment: Alignment.centerLeft, child: Text('Income vs Expense (Last 7 Days)')),
               const SizedBox(height: 20),
               Expanded(
                 child: BarChart(
                   BarChartData(
                     maxY: maxY * 1.2,
                     barGroups: barGroups,
                     titlesData: FlTitlesData(
                       bottomTitles: AxisTitles(
                         sideTitles: SideTitles(
                           showTitles: true,
                           getTitlesWidget: (value, meta) {
                             final index = value.toInt();
                             if (index >= 0 && index < days.length) {
                               return Text(DateFormat.E().format(days[index]), style: const TextStyle(fontSize: 10));
                             }
                             return const Text('');
                           },
                         ),
                       ),
                       leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide Y axis for clean look
                       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     ),
                     borderData: FlBorderData(show: false),
                     gridData: const FlGridData(show: false),
                   ),
                 ),
               ),
               const SizedBox(height: 10),
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Container(width: 12, height: 12, color: Colors.green),
                   const SizedBox(width: 4),
                   const Text('Income'),
                   const SizedBox(width: 16),
                   Container(width: 12, height: 12, color: Colors.red),
                   const SizedBox(width: 4),
                   const Text('Expense'),
                 ],
               )
            ],
          ),
        );
      },
    );
  }
}
