import 'package:equatable/equatable.dart';

class BudgetModel extends Equatable {
  final String id;
  final String userId;
  final String category;
  final double limit;
  final DateTime month; // Usage: just storing Month/Year

  const BudgetModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.limit,
    required this.month,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> data, String id) {
    return BudgetModel(
      id: id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      limit: (data['limit'] ?? 0.0).toDouble(),
      month: data['month'] != null ? DateTime.parse(data['month']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'category': category,
      'limit': limit,
      'month': month.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, userId, category, limit, month];
}
