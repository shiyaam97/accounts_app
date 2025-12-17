part of 'budget_bloc.dart';

enum BudgetStatus { initial, loading, loaded, error }

class BudgetState extends Equatable {
  final BudgetStatus status;
  final List<BudgetModel> budgets;

  const BudgetState({
    this.status = BudgetStatus.initial,
    this.budgets = const [],
  });

  BudgetState copyWith({
    BudgetStatus? status,
    List<BudgetModel>? budgets,
  }) {
    return BudgetState(
      status: status ?? this.status,
      budgets: budgets ?? this.budgets,
    );
  }

  @override
  List<Object> get props => [status, budgets];
}
