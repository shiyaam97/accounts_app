import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';

part 'settings_state.dart';

class SettingsCubit extends HydratedCubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void toggleTheme(ThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
  }

  void updateCurrency(String currency) {
    emit(state.copyWith(currency: currency));
  }

  void toggleNotifications(bool enable) {
    emit(state.copyWith(enableNotifications: enable));
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    return SettingsState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return state.toMap();
  }
}
