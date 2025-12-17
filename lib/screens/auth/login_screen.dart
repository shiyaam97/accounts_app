import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import '../../blocs/auth/auth_bloc.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_tabController.index == 0) {
        // Sign In
        context.read<AuthBloc>().add(AuthLoginRequested(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        ));
      } else {
        // Sign Up
        context.read<AuthBloc>().add(AuthSignUpRequested(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet, size: 80, color: Colors.teal),
                  const SizedBox(height: 24),
                  const Text(
                    'Personal Finance',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 48),
                  
                  // Google Sign In Button
                  ElevatedButton.icon(
                    onPressed: () {
                       context.read<AuthRepository>().logInWithGoogle();
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Continue with Google'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("OR")), Expanded(child: Divider())]),
                  const SizedBox(height: 24),

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Sign In'),
                      Tab(text: 'Sign Up'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Fields
                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      return Column(
                        children: [
                          if (_tabController.index == 1) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                              validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value!.isEmpty || !value.contains('@') ? 'Invalid email' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                            obscureText: true,
                            validator: (value) => value!.length < 6 ? 'Password too short' : null,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(_tabController.index == 0 ? 'Sign In' : 'Create Account'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
