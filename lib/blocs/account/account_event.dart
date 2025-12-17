part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class LoadAccounts extends AccountEvent {}

class AddAccount extends AccountEvent {
  final AccountModel account;

  const AddAccount(this.account);

  @override
  List<Object> get props => [account];
}

class UpdateAccountBalance extends AccountEvent {
  final String accountId;
  final double newBalance;

  const UpdateAccountBalance({required this.accountId, required this.newBalance});

  @override
  List<Object> get props => [accountId, newBalance];
}

class AccountsUpdated extends AccountEvent {
  final List<AccountModel> accounts;

  const AccountsUpdated(this.accounts);

  @override
  List<Object> get props => [accounts];
}
