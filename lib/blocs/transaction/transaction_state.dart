part of 'transaction_bloc.dart';

enum TransactionStatus { initial, loading, loaded, error }

class TransactionState extends Equatable {
  final TransactionStatus status;
  final List<TransactionModel> transactions;
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.totalBalance = 0.0,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
  });

  TransactionState copyWith({
    TransactionStatus? status,
    List<TransactionModel>? transactions,
    double? totalBalance,
    double? totalIncome,
    double? totalExpense,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      totalBalance: totalBalance ?? this.totalBalance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
    );
  }

  @override
  List<Object> get props => [status, transactions, totalBalance, totalIncome, totalExpense];
}
