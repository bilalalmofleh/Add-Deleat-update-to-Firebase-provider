import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_for_work/models/user_model.dart';
import 'package:task_for_work/page/user_page.dart';
import '../provider/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'add_new_car.dart';
import 'edit_car.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final userDocId = user.email;
    var _carID = DateTime.now().microsecondsSinceEpoch;


    final userRef = FirebaseFirestore.instance.collection('users');
    AdminModel adminModel = new AdminModel(
      userId: userDocId!,
      name: user.displayName!,

    );
    Map<String, dynamic> itemData = adminModel.toJson();
    userRef.doc(userDocId).set(itemData);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text("${user.displayName!} Admin"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserPage(
                          userid: userDocId.toString(),
                        )),
                  );
                }, icon: Icon(FontAwesomeIcons.exchangeAlt)),
            IconButton(
                onPressed: () {
                  final provider =
                      Provider.of<GoogleSignInProvider>(context, listen: false);
                  provider.logout();
                },
                icon: Icon(FontAwesomeIcons.signOutAlt)),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Add_new_car(
                        userid: userDocId.toString(),
                        carID: _carID.toString(),
                      )),
            );
            _carID++;
          },
          child: const Icon(
            Icons.add_rounded,
            size: 35,
          ),
          backgroundColor: Colors.blueAccent,
          elevation: 5,
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userDocId.toString())
                .collection("carInfo")
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
                  return GridView.count(
                    crossAxisCount: 1,
                    children: snapshot.data!.docs.map((document) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: Colors.white,
                          shadowColor: Colors.blueGrey,
                          elevation: 5,
                          child: Column(
                            children: [
                              CachedNetworkImage(
                                placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                                imageUrl: document['carImg'],fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                                height: 240,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(document['carName']),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                              "Price: \$${document['carPrice']}"),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(left: 8,right: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [

                                          Container(
                                            height: 33,
                                            child: ElevatedButton(
                                              child: Text("Edit"),
                                              onPressed: (){Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => EditCar(
                                                      userid: userDocId.toString(),
                                                      carID: document["carId"].toString(),
                                                    )),
                                              );},
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
              }
            }));
  }
}
