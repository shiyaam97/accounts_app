part of 'account_bloc.dart';

enum AccountStatus { initial, loading, loaded, error }

class AccountState extends Equatable {
  final AccountStatus status;
  final List<AccountModel> accounts;
  final double totalAssets; // Sum of all positive account balances

  const AccountState({
    this.status = AccountStatus.initial,
    this.accounts = const [],
    this.totalAssets = 0.0,
  });

  AccountState copyWith({
    AccountStatus? status,
    List<AccountModel>? accounts,
    double? totalAssets,
  }) {
    return AccountState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      totalAssets: totalAssets ?? this.totalAssets,
    );
  }

  @override
  List<Object> get props => [status, accounts, totalAssets];
}
