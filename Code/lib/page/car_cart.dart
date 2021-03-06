import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task_for_work/models/wish_list_model.dart';

class CarCart extends StatefulWidget {
  const CarCart({Key? key, this.userid}) : super(key: key);
  final userid;

  @override
  _CarCartState createState() => _CarCartState();
}

class _CarCartState extends State<CarCart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Wish List"),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userid)
                .collection("carWishList")
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        new CircularProgressIndicator(),
                      ],
                    ),
                  ],
                );
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          new CircularProgressIndicator(),
                        ],
                      ),
                    ],
                  );
                default:
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height / 1.15,
                          child: GridView.count(
                            crossAxisCount: 1,
                            children: snapshot.data!.docs.map((document) {
                              return Card(
                                child: Column(
                                  children: [
                                    CachedNetworkImage(
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      imageUrl: document['carImg'],
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width,
                                      height: 240,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                document['carName'],
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color:
                                                        Colors.grey.shade600),
                                              ),
                                            ),
                                            Container(
                                              child: IconButton(
                                                onPressed: () {
                                                  AlertDialog alert = AlertDialog(
                                                    title: Text('Delete ??'),
                                                    content: SingleChildScrollView(
                                                        child: ListBody(
                                                            children: <Widget>[
                                                              Text(
                                                                  'Are you sure you want to delete this Car?'),
                                                            ])),
                                                    actions: [
                                                      TextButton(
                                                        child: Text('No'),
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text(
                                                          'Yes',
                                                          style: TextStyle(
                                                              color: Colors.grey),
                                                        ),
                                                        onPressed: () {
                                                          FirebaseFirestore.instance
                                                              .collection('users')
                                                              .doc(widget.userid)
                                                              .collection(
                                                              "carWishList")
                                                              .doc(document['carId'])
                                                              .delete();

                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return alert;
                                                    },
                                                  );

                                                },
                                                icon: Icon(Icons.delete),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.blue,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, right: 8),
                                        child: Row(
                                          children: [
                                            Text("Number of Units : "),
                                            IconButton(
                                                onPressed: () {
                                                  int num;
                                                  if (document[
                                                          'numOfCarUserBuy'] >
                                                      1) {
                                                    num = document[
                                                            'numOfCarUserBuy'] -
                                                        1;
                                                  } else {
                                                    num = 1;
                                                  }
                                                  final carRef =
                                                      FirebaseFirestore.instance
                                                          .collection('users')
                                                          .doc(widget.userid)
                                                          .collection(
                                                              "carWishList")
                                                          .doc(document[
                                                              'carId']);

                                                  WishListModle wishListModel =
                                                      new WishListModle(
                                                          carName: document[
                                                              'carName'],
                                                          carColor: [
                                                            document['carColor']
                                                                [0],
                                                            document['carColor']
                                                                [1],
                                                            document['carColor']
                                                                [2]
                                                          ],
                                                          carId:
                                                              document['carId'],
                                                          carImg: document[
                                                              'carImg'],
                                                          carPrice: document[
                                                              'carPrice'],
                                                          numOfCarUserBuy: num,
                                                          userId: widget.userid
                                                              .toString());
                                                  Map<String, dynamic> carData =
                                                      wishListModel.toJson();
                                                  carRef.set(carData);
                                                },
                                                icon: Icon(Icons
                                                    .keyboard_arrow_down_rounded)),
                                            Text(
                                              document['numOfCarUserBuy']
                                                  .toString(),
                                            ),
                                            IconButton(
                                                onPressed: () {
                                                  int num = document[
                                                          'numOfCarUserBuy'] +
                                                      1;
                                                  final carRef =
                                                      FirebaseFirestore.instance
                                                          .collection('users')
                                                          .doc(widget.userid)
                                                          .collection(
                                                              "carWishList")
                                                          .doc(document[
                                                              'carId']);

                                                  WishListModle wishListModel =
                                                      new WishListModle(
                                                          carName: document[
                                                              'carName'],
                                                          carColor: [
                                                            document['carColor']
                                                                [0],
                                                            document['carColor']
                                                                [1],
                                                            document['carColor']
                                                                [2]
                                                          ],
                                                          carId:
                                                              document['carId'],
                                                          carImg: document[
                                                              'carImg'],
                                                          carPrice: document[
                                                              'carPrice'],
                                                          numOfCarUserBuy: num,
                                                          userId: widget.userid
                                                              .toString());
                                                  Map<String, dynamic> carData =
                                                      wishListModel.toJson();
                                                  carRef.set(carData);
                                                },
                                                icon: Icon(Icons
                                                    .keyboard_arrow_up_rounded)),
                                            Text(
                                                "Price: \$${int.parse(document['carPrice']) * document['numOfCarUserBuy']}"),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, right: 8),
                                        child: Row(
                                          children: [
                                            Text("Colors:"),
                                            Text(document['carColor'][0]),
                                            Text(","),
                                            Text(document['carColor'][1]),
                                            Text(","),
                                            Text(document['carColor'][2]),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
              }
            }));
  }

  numOfCar(value, price) {
    return value * price;
  }
}
