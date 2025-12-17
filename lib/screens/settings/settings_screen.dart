import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/settings/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              ListTile(
                title: const Text('Theme'),
                trailing: DropdownButton<ThemeMode>(
                  value: state.themeMode,
                  underline: const SizedBox(),
                  onChanged: (ThemeMode? mode) {
                    if (mode != null) {
                      context.read<SettingsCubit>().toggleTheme(mode);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              ListTile(
                title: const Text('Currency'),
                trailing: DropdownButton<String>(
                  value: state.currency,
                  underline: const SizedBox(),
                  onChanged: (String? val) {
                    if (val != null) {
                      context.read<SettingsCubit>().updateCurrency(val);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: '\$', child: Text('USD(\$)')),
                    DropdownMenuItem(value: 'A\$', child: Text('AUD(A\$)')),
                    DropdownMenuItem(value: 'Rs', child: Text('LKR (Rs)')),
                    DropdownMenuItem(value: '₹', child: Text('INR (₹)')),
                    DropdownMenuItem(value: '¥', child: Text('CN(¥)')),
                    DropdownMenuItem(value: '£', child: Text('GBP (£)')),

                  ],
                ),
              ),
              SwitchListTile(
                title: const Text('Daily Notifications'),
                subtitle: const Text('Remind me to log transactions at 8 PM'),
                value: state.enableNotifications,
                onChanged: (bool value) {
                  context.read<SettingsCubit>().toggleNotifications(value);
                  // TODO: Implement actual local notification scheduling logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(value ? 'Daily reminders enabled' : 'Daily reminders disabled')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                subtitle: const Text('Personal Finance App v1.0.0'),
              ),
            ],
          );
        },
      ),
    );
  }
}
