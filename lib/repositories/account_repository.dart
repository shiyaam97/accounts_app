import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account_model.dart';
import '../models/user_model.dart';

class AccountRepository {
  final FirebaseFirestore _firestore;

  AccountRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addAccount(AccountModel account) async {
    await _firestore.collection('accounts').add(account.toMap());
  }

  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    await _firestore.collection('accounts').doc(accountId).update({'balance': newBalance});
  }

  Future<void> deleteAccount(String id) async {
    await _firestore.collection('accounts').doc(id).delete();
  }

  Stream<List<AccountModel>> accounts(UserModel user) {
    if (user.isEmpty) {
      return Stream.value([]);
    }
    return _firestore
        .collection('accounts')
        .where('userId', isEqualTo: user.id)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AccountModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
