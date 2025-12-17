import 'package:equatable/equatable.dart';

enum AccountType { bank, cash, card, other }

class AccountModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final double balance;
  final String accountNumber; // Last 4 digits or identifier

  const AccountModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    this.accountNumber = '',
  });

  factory AccountModel.fromMap(Map<String, dynamic> data, String id) {
    return AccountModel(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      type: AccountType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => AccountType.other,
      ),
      balance: (data['balance'] ?? 0.0).toDouble(),
      accountNumber: data['accountNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type.toString(),
      'balance': balance,
      'accountNumber': accountNumber,
    };
  }

  @override
  List<Object?> get props => [id, userId, name, type, balance, accountNumber];
}
