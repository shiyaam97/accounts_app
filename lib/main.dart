import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/transaction_repository.dart';
import 'repositories/account_repository.dart';
import 'repositories/budget_repository.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/transaction/transaction_bloc.dart';
import 'blocs/account/account_bloc.dart';
import 'blocs/budget/budget_bloc.dart';
import 'blocs/settings/settings_cubit.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();

  final storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(dir.path),
  );

  HydratedBloc.storage = storage;

  HydratedBloc.storage = storage;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // HydratedBloc.storage = await HydratedStorage.build(
  //   // storageDirectory: await getApplicationDocumentsDirectory(),
  // );
  
  final authRepository = AuthRepository();
  final transactionRepository = TransactionRepository();
  final accountRepository = AccountRepository();
  final budgetRepository = BudgetRepository();
  
  runApp(MyApp(
    authRepository: authRepository,
    transactionRepository: transactionRepository,
    accountRepository: accountRepository,
    budgetRepository: budgetRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository _authRepository;
  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final BudgetRepository _budgetRepository;

  const MyApp({
    super.key,
    required AuthRepository authRepository,
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    required BudgetRepository budgetRepository,
  }) : _authRepository = authRepository,
       _transactionRepository = transactionRepository,
       _accountRepository = accountRepository,
       _budgetRepository = budgetRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _transactionRepository),
        RepositoryProvider.value(value: _accountRepository),
        RepositoryProvider.value(value: _budgetRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SettingsCubit()),
          BlocProvider(
            create: (_) => AuthBloc(authRepository: _authRepository)..add(AuthStarted()),
          ),
          BlocProvider(
            create: (context) => TransactionBloc(
              transactionRepository: _transactionRepository,
              authBloc: context.read<AuthBloc>(),
            ),
          ),
          BlocProvider(
            create: (context) => AccountBloc(
              accountRepository: _accountRepository,
              authBloc: context.read<AuthBloc>(),
            ),
          ),
          BlocProvider(
            create: (context) => BudgetBloc(
              budgetRepository: _budgetRepository,
              authBloc: context.read<AuthBloc>(),
            ),
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            return MaterialApp(
              title: 'Personal Finance App',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
                useMaterial3: true,
              ),
              themeMode: settings.themeMode,
              home: const AppView(),
            );
          },
        ),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
