import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String name;
  final String userId;


  AdminModel({
    required this.name,
    required this.userId,

  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'userId': userId,

      };

  AdminModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        userId = json['userId'];

  factory AdminModel.fromDoc(DocumentSnapshot doc) {
    return AdminModel(
      name: doc['name'],
      userId: doc['userId'],

    );
  }
}
