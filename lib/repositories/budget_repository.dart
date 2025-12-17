import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';
import '../models/user_model.dart';

class BudgetRepository {
  final FirebaseFirestore _firestore;

  BudgetRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addBudget(BudgetModel budget) async {
    // Check if budget exists for this category/month? For simplicity, allow one.
    await _firestore.collection('budgets').add(budget.toMap());
  }

  Future<void> deleteBudget(String id) async {
    await _firestore.collection('budgets').doc(id).delete();
  }

  Stream<List<BudgetModel>> budgets(UserModel user) {
    if (user.isEmpty) return Stream.value([]);
    return _firestore
        .collection('budgets')
        .where('userId', isEqualTo: user.id)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BudgetModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
