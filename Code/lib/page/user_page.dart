import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:task_for_work/models/wish_list_model.dart';
import 'package:task_for_work/page/car_cart.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key, this.userid}) : super(key: key);
  final userid;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool showFilter = false;
  final searchController = TextEditingController();
  GlobalKey<ScaffoldState>? _key;
  bool? _isSelected;
  List<CarFilterWidget>? _companies;
  List<String>? _filters;
  List<String>? _choices;
  int? _choiceIndex;
  late var stream = FirebaseFirestore.instance
      .collection('users')
      .doc(widget.userid)
      .collection("carInfo")
      .snapshots();
  late var selectionType = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _key = GlobalKey<ScaffoldState>();
    _isSelected = false;
    _choiceIndex = 0;
    _filters = <String>[];
    _companies = <CarFilterWidget>[
      CarFilterWidget('Name'),
      CarFilterWidget('Price'),
      CarFilterWidget('Color'),
    ];
    _choices = ["Software Engineer", "Software Developer", "Software Testing"];
  }

  onSubmitSearch(String str) {
    switch (selectionType) {
      case 0:
        {
          setState(() {
            stream = FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userid)
                .collection("carInfo")
                .snapshots();
          });
        }
        break;
      case 1:
        {
          setState(() {
            stream = FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userid)
                .collection("carInfo")
                .where('carName', isEqualTo: str)
                .snapshots();
          });
        }
        break;
      case 2:
        {
          setState(() {
            stream = FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userid)
                .collection("carInfo")
                .where('carPrice', isEqualTo: str)
                .snapshots();
          });
        }
        break;
      case 3:
        {
          setState(() {
            stream = FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userid)
                .collection("carInfo")
                .where('carColor', arrayContains: str)
                .snapshots();
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          "User ${user.displayName!}",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CarCart(
                            userid: widget.userid,
                          )),
                );
              },
              icon: Icon(FontAwesomeIcons.boxOpen)),
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(FontAwesomeIcons.exchangeAlt)),
        ],
      ),
      body: SlidingUpPanel(
        maxHeight: MediaQuery.of(context).size.height / 4,
        minHeight: 70,
        margin: EdgeInsets.only(left: 7, right: 7),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        panel: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Center(
                  child: Container(
                width: 40,
                height: 5,
                color: Colors.grey[400],
              )),
            ),
            Container(
              margin: EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  "Slide up to filter",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: FChip('Name', 1),
                  ),
                  Container(
                    child: FChip('Price', 2),
                  ),
                  Container(
                    child: FChip('Color', 3),
                  ),
                  Container(
                      child: TextButton(
                    onPressed: () {
                      setState(() {
                        stream = FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.userid)
                            .collection("carInfo")
                            .snapshots();
                      });
                    },
                    child: Text("Clear Filter"),
                  )),
                ],
              ),
            ),
            Container(
              height: 50,
              margin: EdgeInsets.all(5),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40)),
                    labelText: "Filter Text",
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'BMW'),
                onSubmitted: (String value) {
                  if (selectionType == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Please Select Filter Type First')));
                  } else {
                    onSubmitSearch(value);
                  }
                },
              ),
            ),
          ],
        ),
        body: StreamBuilder(
            stream: stream,
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
                          height: MediaQuery.of(context).size.height/1.20,
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
                                                    color: Colors.grey.shade600),
                                              ),
                                            ),
                                            Container(
                                              child: IconButton(
                                                onPressed: () {
                                                  final carWish =
                                                  FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(widget.userid)
                                                      .collection(
                                                      "carWishList")
                                                      .doc(document[
                                                  'carId']);
                                                  WishListModle
                                                  wishListModle =
                                                  new WishListModle(
                                                      carName: document[
                                                      'carName'],
                                                      userId: widget
                                                          .userid
                                                          .toString(),
                                                      carColor: [
                                                        document[
                                                        'carColor'][0],
                                                        document[
                                                        'carColor'][1],
                                                        document[
                                                        'carColor'][2]
                                                      ],
                                                      carId: document[
                                                      'carId'],
                                                      carImg: document[
                                                      'carImg'],
                                                      carPrice: document[
                                                      'carPrice'],
                                                      numOfCarUserBuy: 1);
                                                  Map<String, dynamic>
                                                  carData =
                                                  wishListModle.toJson();
                                                  carWish.set(carData);

                                                  ScaffoldMessenger.of(
                                                      context)
                                                      .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Car added to Cart')));

                                                },
                                                icon: Icon(Icons
                                                    .add_shopping_cart_outlined),

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
                                        padding:
                                        const EdgeInsets.only(left: 8, right: 8),
                                        child: Row(
                                          children: [
                                            Text("Price: \$${document['carPrice']}"),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.only(left: 8, right: 8),
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
            }),
      ),
    );
  }

  Widget FChip(String filterText, var selection) {
    return FilterChip(
      backgroundColor: Colors.grey.shade400,
      avatar: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          filterText.substring(0, 1).toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
      ),
      label: Text(
        filterText,
        style: TextStyle(color: Colors.white),
      ),
      selected: _filters!.contains(filterText),
      selectedColor: Colors.blue,
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            selectionType = selection;
            _filters!.add(filterText);
          } else {
            _filters!.removeWhere((String name) {
              return name == filterText;
            });
          }
        });
      },
    );
  }
}

class CarFilterWidget {
  const CarFilterWidget(this.name);

  final String name;
}
