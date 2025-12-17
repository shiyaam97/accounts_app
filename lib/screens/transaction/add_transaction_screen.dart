import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/account/account_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../models/transaction_model.dart';
import '../../models/account_model.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  String _category = 'General';
  String? _selectedAccountId;

  final List<String> _expenseCategories = ['Groceries', 'Transport', 'Rent', 'Bills', 'Entertainment', 'General'];

  final List<String> _incomeCategories = ['Salary', 'Freelance', 'Business', 'Gift', 'Other'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final user = context.read<AuthBloc>().state.user;

      final transaction = TransactionModel(
        id: const Uuid().v4(),
        userId: user.id,
        type: _type,
        category: _category,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        notes: _notesController.text,
      );

      context.read<TransactionBloc>().add(AddTransaction(transaction));

      if (_selectedAccountId != null) {
        final accounts = context.read<AccountBloc>().state.accounts;
        final account =
        accounts.firstWhere((a) => a.id == _selectedAccountId);

        double newBalance = account.balance;
        if (_type == TransactionType.income) {
          newBalance += transaction.amount;
        } else {
          newBalance -= transaction.amount;
        }

        context.read<AccountBloc>().add(
          UpdateAccountBalance(
            accountId: _selectedAccountId!,
            newBalance: newBalance,
          ),
        );
      }

      // ✅ SHOW SUCCESS MESSAGE
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Transaction added successfully"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // ✅ CLOSE AFTER SHORT DELAY
      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.pop(context);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Type Selection
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.expense, label: Text('Expense'), icon: Icon(Icons.remove_circle_outline)),
                  ButtonSegment(value: TransactionType.income, label: Text('Income'), icon: Icon(Icons.add_circle_outline)),
                ],
                selected: {_type},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _type = newSelection.first;
                    _category = _type == TransactionType.expense ? _expenseCategories.first : _incomeCategories.first;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount', prefixText: context.watch<SettingsCubit>().state.currency),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter amount';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: (_type == TransactionType.expense ? _expenseCategories : _incomeCategories)
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 16),

              // Account Selection
              BlocBuilder<AccountBloc, AccountState>(
                builder: (context, state) {
                  if (state.accounts.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedAccountId,
                        decoration: const InputDecoration(labelText: 'Account / Wallet'),
                        items: state.accounts.map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text('${a.name} (${context.watch<SettingsCubit>().state.currency}${a.balance.toStringAsFixed(2)})'),
                        )).toList(),
                        onChanged: (val) => setState(() => _selectedAccountId = val),
                        validator: (value) => value == null ? 'Please select an account' : null,
                      ),
                    );
                  }
                  return const SizedBox.shrink(); // Or show "Add Account" button hint
                },
              ),

              // Date
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)'),
              ),
              const SizedBox(height: 32),

              // Submit
              FilledButton(
                onPressed: _submit,
                child: const Text('Save Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
