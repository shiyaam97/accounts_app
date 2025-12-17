import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../blocs/budget/budget_bloc.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../models/budget_model.dart';
import '../../models/transaction_model.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  void _showAddBudgetDialog(BuildContext context) {
    final limitController = TextEditingController();
    String selectedCategory = 'Groceries';
    final List<String> categories = ['Groceries', 'Transport', 'Rent', 'Bills', 'Entertainment', 'General'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set Monthly Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => selectedCategory = val!),
              ),
              TextField(
                controller: limitController,
                decoration: const InputDecoration(labelText: 'Limit Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (limitController.text.isNotEmpty) {
                  final user = context.read<AuthBloc>().state.user;
                  final budget = BudgetModel(
                    id: const Uuid().v4(),
                    userId: user.id,
                    category: selectedCategory,
                    limit: double.parse(limitController.text),
                    month: DateTime.now(), // Defaults to current month for simplicity
                  );
                  context.read<BudgetBloc>().add(AddBudget(budget));
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateSpent(List<TransactionModel> transactions, String category) {
    double spent = 0;
    final now = DateTime.now();
    for (var t in transactions) {
      // Must match category, type expense, and current month/year
      if (t.category == category && 
          t.type == TransactionType.expense &&
          t.date.month == now.month &&
          t.date.year == now.year) {
        spent += t.amount;
      }
    }
    return spent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar handled by dashboard if embedded, but if standalone we need one?
      // Dashboard uses BottomNav, so main content is this body. 
      // But we can have a header here.
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, budgetState) {
          return BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, transactionState) {
              if (budgetState.status == BudgetStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (budgetState.budgets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No budgets set for this month.'),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: () => _showAddBudgetDialog(context), child: const Text('Create Budget')),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                   const Padding(
                     padding: EdgeInsets.only(bottom: 16.0),
                     child: Text('Monthly Budgets', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                   ),
                   ...budgetState.budgets.map((budget) {
                     final spent = _calculateSpent(transactionState.transactions, budget.category);
                     final progress = (spent / budget.limit).clamp(0.0, 1.0);
                     final isOver = spent > budget.limit;
                     final color = isOver ? Colors.red : (progress > 0.8 ? Colors.orange : Colors.green);

                     return Card(
                       child: Padding(
                         padding: const EdgeInsets.all(16.0),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Text(budget.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                 Text(
                                   '${NumberFormat.currency(symbol: context.watch<SettingsCubit>().state.currency).format(spent)} / ${NumberFormat.currency(symbol: context.watch<SettingsCubit>().state.currency).format(budget.limit)}',
                                   style: TextStyle(color: isOver ? Colors.red : Colors.grey[800]),
                                 ),
                               ],
                             ),
                             const SizedBox(height: 12),
                             LinearProgressIndicator(
                               value: progress,
                               color: color,
                               backgroundColor: Colors.grey[200],
                               minHeight: 8,
                               borderRadius: BorderRadius.circular(4),
                             ),
                             const SizedBox(height: 8),
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                  Text(
                                    isOver ? 'Over budget!' : '${((1-progress)*100).toStringAsFixed(0)}% remaining',
                                    style: TextStyle(fontSize: 12, color: color),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 16, color: Colors.grey),
                                    onPressed: () {
                                       context.read<BudgetBloc>().add(DeleteBudget(budget.id));
                                    },
                                  )
                               ],
                             )
                           ],
                         ),
                       ),
                     );
                   }),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
