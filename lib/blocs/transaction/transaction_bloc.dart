import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/transaction_repository.dart';
import '../../models/transaction_model.dart';
import '../auth/auth_bloc.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;
  final AuthBloc _authBloc;
  StreamSubscription<List<TransactionModel>>? _transactionsSubscription;
  StreamSubscription<AuthState>? _authSubscription;

  TransactionBloc({
    required TransactionRepository transactionRepository,
    required AuthBloc authBloc,
  })  : _transactionRepository = transactionRepository,
        _authBloc = authBloc,
        super(const TransactionState()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<TransactionsUpdated>(_onTransactionsUpdated);

    // Listen to Auth changes to reload transactions when user changes
    _authSubscription = _authBloc.stream.listen((state) {
      if (state.status == AuthStatus.authenticated) {
        add(LoadTransactions());
      } else {
         // Clear transactions on logout
         add(const TransactionsUpdated([]));
      }
    });
  }

  void _onLoadTransactions(LoadTransactions event, Emitter<TransactionState> emit) {
    emit(state.copyWith(status: TransactionStatus.loading));
    
    _transactionsSubscription?.cancel();
    final user = _authBloc.state.user;
    
    _transactionsSubscription = _transactionRepository.transactions(user).listen(
      (transactions) => add(TransactionsUpdated(transactions)),
    );
  }

  void _onAddTransaction(AddTransaction event, Emitter<TransactionState> emit) {
    _transactionRepository.addTransaction(event.transaction);
  }

  void _onDeleteTransaction(DeleteTransaction event, Emitter<TransactionState> emit) {
    _transactionRepository.deleteTransaction(event.id);
  }

  void _onTransactionsUpdated(TransactionsUpdated event, Emitter<TransactionState> emit) {
    double income = 0;
    double expense = 0;
    print("TransactionBloc: Processing ${event.transactions.length} transactions");
    for (var t in event.transactions) {
      print("  - ${t.type.toString()}: ${t.category} = ${t.amount}");
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    
    final newBalance = income - expense;
    print("TransactionBloc: Income=$income, Expense=$expense, Balance=$newBalance");
    
    emit(state.copyWith(
      status: TransactionStatus.loaded,
      transactions: event.transactions,
      totalIncome: income,
      totalExpense: expense,
      totalBalance: newBalance,
    ));
    print("TransactionBloc: State emitted - Balance in state: ${state.totalBalance}");
  }

  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
