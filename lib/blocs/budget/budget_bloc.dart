import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/budget_repository.dart';
import '../../models/budget_model.dart';
import '../auth/auth_bloc.dart';

part 'budget_event.dart';
part 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository _budgetRepository;
  final AuthBloc _authBloc;
  StreamSubscription<List<BudgetModel>>? _budgetsSubscription;
  StreamSubscription<AuthState>? _authSubscription;

  BudgetBloc({
    required BudgetRepository budgetRepository,
    required AuthBloc authBloc,
  })  : _budgetRepository = budgetRepository,
        _authBloc = authBloc,
        super(const BudgetState()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<AddBudget>(_onAddBudget);
    on<DeleteBudget>(_onDeleteBudget);
    on<BudgetsUpdated>(_onBudgetsUpdated);

    _authSubscription = _authBloc.stream.listen((state) {
        if (state.status == AuthStatus.authenticated) {
            add(LoadBudgets());
        } else {
            add(const BudgetsUpdated([]));
        }
    });
  }

  void _onLoadBudgets(LoadBudgets event, Emitter<BudgetState> emit) {
    emit(state.copyWith(status: BudgetStatus.loading));
    _budgetsSubscription?.cancel();
    final user = _authBloc.state.user;
    _budgetsSubscription = _budgetRepository.budgets(user).listen(
      (budgets) => add(BudgetsUpdated(budgets)),
    );
  }

  void _onAddBudget(AddBudget event, Emitter<BudgetState> emit) {
    _budgetRepository.addBudget(event.budget);
  }

  void _onDeleteBudget(DeleteBudget event, Emitter<BudgetState> emit) {
    _budgetRepository.deleteBudget(event.id);
  }

  void _onBudgetsUpdated(BudgetsUpdated event, Emitter<BudgetState> emit) {
    emit(state.copyWith(
      status: BudgetStatus.loaded,
      budgets: event.budgets,
    ));
  }

  @override
  Future<void> close() {
    _budgetsSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
