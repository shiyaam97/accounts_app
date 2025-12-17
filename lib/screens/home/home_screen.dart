import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../models/transaction_model.dart';
import '../transaction/add_transaction_screen.dart';
import '../../blocs/settings/settings_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.currency;

    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state.status == TransactionStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Balance Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                       const Text('Total Balance', style: TextStyle(fontSize: 16)),
                       const SizedBox(height: 8),
                       Text(
                         NumberFormat.currency(symbol: currency).format(state.totalBalance),
                         style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                       ),
                       const SizedBox(height: 20),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         children: [
                           _buildSummaryItem(context, 'Income', state.totalIncome, Colors.green, currency),
                           _buildSummaryItem(context, 'Expense', state.totalExpense, Colors.red, currency),
                         ],
                       )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Quick Actions
              const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(context, Icons.add, 'Add Income', Colors.green, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
                  }),
                  _buildActionButton(context, Icons.remove, 'Add Expense', Colors.red, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())); // Defaults to expense
                  }),
                ],
              ),

              const SizedBox(height: 24),
              
              // Recent Transactions Header
              const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              if (state.transactions.isEmpty)
                 const Padding(
                   padding: EdgeInsets.all(16.0),
                   child: Center(child: Text('No transactions yet.')),
                 )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.transactions.length > 5 ? 5 : state.transactions.length, // Show top 5
                  itemBuilder: (context, index) {
                    final transaction = state.transactions[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: transaction.type == TransactionType.income ? Colors.green[100] : Colors.red[100],
                          child: Icon(
                            transaction.type == TransactionType.income ? Icons.arrow_downward : Icons.arrow_upward,
                            color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(transaction.category),
                        subtitle: Text(DateFormat.yMMMd().format(transaction.date)),
                        trailing: Text(
                          '${transaction.type == TransactionType.income ? '+' : '-'}${NumberFormat.currency(symbol: currency).format(transaction.amount)}',
                          style: TextStyle(
                            color: transaction.type == TransactionType.income ? Colors.green[700] : Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, double amount, Color color, String currency) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          NumberFormat.currency(symbol: currency).format(amount), 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: color.withOpacity(0.1),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
