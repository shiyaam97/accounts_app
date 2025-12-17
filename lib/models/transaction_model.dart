import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

class TransactionModel extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final String category;
  final double amount;
  final DateTime date;
  final String notes;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.notes = '',
  });

  factory TransactionModel.fromMap(Map<String, dynamic> data, String id) {
    return TransactionModel(
      id: id,
      userId: data['userId'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => TransactionType.expense,
      ),
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.toString(),
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [id, userId, type, category, amount, date, notes];
}
