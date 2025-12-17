part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final String currency;
  final bool enableNotifications;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.currency = '\$',
    this.enableNotifications = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? currency,
    bool? enableNotifications,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      enableNotifications: enableNotifications ?? this.enableNotifications,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'currency': currency,
      'enableNotifications': enableNotifications,
    };
  }

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(
      themeMode: ThemeMode.values[map['themeMode'] ?? 0],
      currency: map['currency'] ?? '\$',
      enableNotifications: map['enableNotifications'] ?? false,
    );
  }

  @override
  List<Object> get props => [themeMode, currency, enableNotifications];
}
