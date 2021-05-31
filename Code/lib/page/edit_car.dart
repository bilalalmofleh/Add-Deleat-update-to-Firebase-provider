import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_for_work/models/car_model.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditCar extends StatefulWidget {
  const EditCar({Key? key, this.userid, this.carID}) : super(key: key);
  final userid;
  final carID;

  @override
  _EditCarState createState() => _EditCarState();
}

class _EditCarState extends State<EditCar> {
  bool isUploaded = false;
  bool isChoosed = false;
  double val = 0;
  late firebase_storage.Reference ref;
  File? _img;

  final picker = ImagePicker();
  late final String _imgUrl;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text("Edit Car"),
          actions: [
            Center(
              child: InkWell(
                  onTap: () {
                    AlertDialog alert = AlertDialog(
                      title: Text('Delete ??'),
                      content: SingleChildScrollView(
                          child: ListBody(children: <Widget>[
                        Text('Are you sure you want to delete this Car?'),
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
                            style: TextStyle(color: Colors.grey),
                          ),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.userid)
                                .collection("carInfo")
                                .doc(widget.carID)
                                .delete();

                            Navigator.of(context).pop();
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
                  child: Row(
                    children: [
                      Text(
                        "Delete",
                        style: TextStyle(fontSize: 20),
                      ),
                      Icon(Icons.delete_rounded),
                    ],
                  )),
            ),
          ],
        ),
        body: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.email.toString())
                .collection("carInfo")
                .doc(widget.carID.toString())
                .get(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                  Map<String, dynamic> data = snapshot.data.data();
                  CarModel carModel = CarModel.fromJson(data);

                  final _carImgLink = TextEditingController(
                    text: carModel.carImg.toString(),
                  );
                  final _carName = TextEditingController(
                    text: carModel.carName,
                  );
                  final _carPrice = TextEditingController(
                    text: carModel.carPrice,
                  );
                  final _carColor1 = TextEditingController(
                    text: carModel.carColor[0],
                  );
                  final _carColor2 = TextEditingController(
                    text: carModel.carColor[1],
                  );
                  final _carColor3 = TextEditingController(
                    text: carModel.carColor[2],
                  );
                  return SingleChildScrollView(
                      child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Form(
                          child: Column(children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 8, 10, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: 200,
                                  height: 150,
                                  child: (_img != null)
                                      ? Image.file(
                                          _img!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          _carImgLink.text,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 60.0),
                                child: Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        FontAwesomeIcons.camera,
                                        size: 30.0,
                                      ),
                                      onPressed: () => chooseImage(),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        FontAwesomeIcons.upload,
                                        size: 30.0,
                                      ),
                                      onPressed: () => isChoosed
                                          ? uploadFile().whenComplete(() =>
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Image Upload Finish'))))
                                          : ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'Please Chose an image'))),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                          child: Container(
                            width: 300,
                            height: 100,
                            child: TextFormField(
                              controller: _carName,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  labelText: "Add Car Name",
                                  prefixIcon: Icon(
                                      Icons.drive_file_rename_outline_rounded),
                                  hintText: 'BMW 2021'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Container(
                            width: 300,
                            height: 100,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _carPrice,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  labelText: "Price",
                                  prefixIcon: Icon(Icons.attach_money_rounded),
                                  hintText: '17000'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Container(
                            width: 300,
                            height: 100,
                            child: TextFormField(
                              controller: _carColor1,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  labelText: "Color 1",
                                  prefixIcon: Icon(Icons.color_lens_rounded),
                                  hintText: 'blue'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Container(
                            width: 300,
                            height: 100,
                            child: TextFormField(
                              controller: _carColor2,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  labelText: "Color 2",
                                  prefixIcon: Icon(Icons.color_lens_rounded),
                                  hintText: 'red'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Container(
                            width: 300,
                            height: 100,
                            child: TextFormField(
                              controller: _carColor3,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  labelText: "Color 3",
                                  prefixIcon: Icon(Icons.color_lens_rounded),
                                  hintText: 'black'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 8, 10, 0),
                          child: Container(
                            width: 300,
                            height:60,
                            child: ElevatedButton(
                              child: Text("Edit",style: TextStyle(fontSize: 30),),
                              onPressed: () {
                                if (isUploaded) {
                                  final carRef = FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.email.toString())
                                      .collection("carInfo")
                                      .doc(widget.carID.toString());

                                  CarModel carModel = new CarModel(
                                      carName: _carName.text,
                                      carColor: [
                                        _carColor1.text,
                                        _carColor2.text,
                                        _carColor3.text
                                      ],
                                      carId: widget.carID,
                                      carImg: _imgUrl,
                                      carPrice: _carPrice.text,
                                      userId: widget.userid.toString());
                                  Map<String, dynamic> carData =
                                      carModel.toJson();
                                  carRef.set(carData);
                                  Navigator.of(context).pop();
                                } else if (!isUploaded) {
                                  final carRef = FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.email.toString())
                                      .collection("carInfo")
                                      .doc(widget.carID.toString());

                                  CarModel carModel = new CarModel(
                                      carName: _carName.text,
                                      carColor: [
                                        _carColor1.text,
                                        _carColor2.text,
                                        _carColor3.text
                                      ],
                                      carId: widget.carID,
                                      carImg: _carImgLink.text,
                                      carPrice: _carPrice.text,
                                      userId: widget.userid.toString());
                                  Map<String, dynamic> carData =
                                      carModel.toJson();
                                  carRef.set(carData);
                                  Navigator.of(context).pop();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Please Upload Image First')));
                                }
                              },
                            ),
                          ),
                        ),
                      ])),
                    ]),
                  ]));
              }
            }));
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  chooseImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _img = (File(pickedFile!.path));
      isChoosed = true;
    });
    if (pickedFile!.path == null) retrieveLostData();
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.file != null) {
      setState(() {
        _img = (File(response.file!.path));
        isChoosed = true;
      });
    } else {
      print(response.file);
    }
  }

  Future uploadFile() async {
    ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('images/${Path.basename(_img!.path)}');
    await ref.putFile(_img!).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        setState(() {
          _imgUrl = value;
          print('Image URL $_imgUrl');
          isUploaded = true;
        });
      });
    });
  }
}
