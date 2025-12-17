import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? profilePic;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.profilePic,
  });

  // Empty user for unauthenticated state
  static const empty = UserModel(id: '', email: '');

  bool get isEmpty => this == UserModel.empty;
  bool get isNotEmpty => this != UserModel.empty;

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      email: data['email'] ?? '',
      name: data['name'],
      profilePic: data['profilePic'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'profilePic': profilePic,
    };
  }

  @override
  List<Object?> get props => [id, email, name, profilePic];
}
