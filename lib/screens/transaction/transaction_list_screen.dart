import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../models/transaction_model.dart';
import 'add_transaction_screen.dart';
import 'package:flutter/material.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  TransactionType? _filterType; // null = All, or specific type

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterType == null,
                  onSelected: (selected) => setState(() => _filterType = null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Income'),
                  selected: _filterType == TransactionType.income,
                  checkmarkColor: Colors.white,
                  selectedColor: Colors.green[100],
                  onSelected: (selected) => setState(() => _filterType = selected ? TransactionType.income : null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Expense'),
                  selected: _filterType == TransactionType.expense,
                  checkmarkColor: Colors.white,
                  selectedColor: Colors.red[100],
                  onSelected: (selected) => setState(() => _filterType = selected ? TransactionType.expense : null),
                ),
              ],
            ),
          ),
          
          // List
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state.status == TransactionStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Apply local filter
                final transactions = state.transactions.where((t) {
                   if (_filterType == null) return true;
                   return t.type == _filterType;
                }).toList();

                if (transactions.isEmpty) {
                  return const Center(child: Text('No transactions found.'));
                }

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Dismissible(
                      key: Key(transaction.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                         return await showDialog(
                           context: context,
                           builder: (ctx) => AlertDialog(
                             title: const Text("Delete Transaction?"),
                             content: const Text("Are you sure you want to remove this item?"),
                             actions: [
                               TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancel")),
                               TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                             ],
                           ),
                         );
                      },
                      onDismissed: (direction) {
                        context.read<TransactionBloc>().add(DeleteTransaction(transaction.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${transaction.category} deleted')),
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: transaction.type == TransactionType.income ? Colors.green[100] : Colors.red[100],
                          child: Icon(
                            transaction.type == TransactionType.income ? Icons.arrow_downward : Icons.arrow_upward,
                            color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(transaction.category),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(DateFormat.yMMMd().format(transaction.date)),
                             if (transaction.notes.isNotEmpty) Text(transaction.notes, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                          ],
                        ),
                        trailing: Text(
                          '${transaction.type == TransactionType.income ? '+' : '-'}${NumberFormat.currency(symbol: context.watch<SettingsCubit>().state.currency).format(transaction.amount)}',
                          style: TextStyle(
                            color: transaction.type == TransactionType.income ? Colors.green[700] : Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
