import 'package:cloud_firestore/cloud_firestore.dart';

class CarModel {
  final String carName;
  final String carId;
  final String carPrice;
  final List carColor;
  final String carImg;
  final String userId;

  CarModel({
    required this.carName,
    required this.carId,
    required this.carColor,
    required this.carPrice,
    required this.carImg,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'carName': carName,
        'carId': carId,
        'carColor': carColor,
        'carPrice': carPrice,
        'carImg': carImg,
        'userId': userId,
      };

  CarModel.fromJson(Map<String, dynamic> json)
      : carName = json['carName'],
        carId = json['carId'],
        carColor = json['carColor'],
        carPrice = json['carPrice'],
        carImg = json['carImg'],
        userId = json['userId'];

  factory CarModel.fromDoc(DocumentSnapshot doc) {
    return CarModel(
      carName: doc['carName'],
      carId: doc['carId'],
      carColor: doc['carColor'],
      carPrice: doc['carPrice'],
      carImg: doc['carImg'],
      userId: doc['userId'],
    );
  }
}
