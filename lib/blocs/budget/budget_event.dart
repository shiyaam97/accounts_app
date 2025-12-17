part of 'budget_bloc.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object> get props => [];
}

class LoadBudgets extends BudgetEvent {}

class AddBudget extends BudgetEvent {
  final BudgetModel budget;

  const AddBudget(this.budget);

  @override
  List<Object> get props => [budget];
}

class DeleteBudget extends BudgetEvent {
  final String id;

  const DeleteBudget(this.id);

  @override
  List<Object> get props => [id];
}

class BudgetsUpdated extends BudgetEvent {
  final List<BudgetModel> budgets;

  const BudgetsUpdated(this.budgets);

  @override
  List<Object> get props => [budgets];
}
