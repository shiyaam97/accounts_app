import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../blocs/account/account_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../models/account_model.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  void _showAddAccountDialog(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    AccountType selectedType = AccountType.bank;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Account Name')),
              TextField(
                controller: balanceController,
                decoration: const InputDecoration(labelText: 'Initial Balance'),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<AccountType>(
                value: selectedType,
                items: AccountType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.toString().split('.').last.toUpperCase()))).toList(),
                onChanged: (val) => setState(() => selectedType = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && balanceController.text.isNotEmpty) {
                  final user = context.read<AuthBloc>().state.user;
                  final account = AccountModel(
                    id: const Uuid().v4(), // Optimistic ID
                    userId: user.id,
                    name: nameController.text,
                    type: selectedType,
                    balance: double.tryParse(balanceController.text) ?? 0.0,
                  );
                  context.read<AccountBloc>().add(AddAccount(account));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state.status == AccountStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.accounts.isEmpty) {
            return const Center(child: Text("No accounts added."));
          }
          return ListView.builder(
            itemCount: state.accounts.length,
            itemBuilder: (context, index) {
              final account = state.accounts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.account_balance)),
                  title: Text(account.name),
                  subtitle: Text(account.type.toString().split('.').last.toUpperCase()),
                  trailing: Text(
                    NumberFormat.currency(symbol: context.watch<SettingsCubit>().state.currency).format(account.balance),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
