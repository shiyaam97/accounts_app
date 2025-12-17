import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/account_repository.dart';
import '../../models/account_model.dart';
import '../auth/auth_bloc.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository _accountRepository;
  final AuthBloc _authBloc;
  StreamSubscription<List<AccountModel>>? _accountsSubscription;
  StreamSubscription<AuthState>? _authSubscription;

  AccountBloc({
    required AccountRepository accountRepository,
    required AuthBloc authBloc,
  })  : _accountRepository = accountRepository,
        _authBloc = authBloc,
        super(const AccountState()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<AddAccount>(_onAddAccount);
    on<UpdateAccountBalance>(_onUpdateAccountBalance);
    on<AccountsUpdated>(_onAccountsUpdated);

    _authSubscription = _authBloc.stream.listen((state) {
      if (state.status == AuthStatus.authenticated) {
        add(LoadAccounts());
      } else {
        add(const AccountsUpdated([]));
      }
    });
  }

  void _onLoadAccounts(LoadAccounts event, Emitter<AccountState> emit) {
    emit(state.copyWith(status: AccountStatus.loading));
    _accountsSubscription?.cancel();
    final user = _authBloc.state.user;
    _accountsSubscription = _accountRepository.accounts(user).listen(
      (accounts) => add(AccountsUpdated(accounts)),
    );
  }

  void _onAddAccount(AddAccount event, Emitter<AccountState> emit) {
    _accountRepository.addAccount(event.account);
  }

  void _onUpdateAccountBalance(UpdateAccountBalance event, Emitter<AccountState> emit) {
    _accountRepository.updateAccountBalance(event.accountId, event.newBalance);
  }

  void _onAccountsUpdated(AccountsUpdated event, Emitter<AccountState> emit) {
    double total = 0;
    for (var a in event.accounts) {
      total += a.balance;
    }
    emit(state.copyWith(
      status: AccountStatus.loaded,
      accounts: event.accounts,
      totalAssets: total,
    ));
  }

  @override
  Future<void> close() {
    _accountsSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
