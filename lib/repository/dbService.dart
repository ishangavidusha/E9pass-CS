import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e9pass_cs/models/fireSettings.dart';
import 'package:flutter/material.dart';

class DataRepository extends ChangeNotifier {
  List<AppData> appData = [];
  final CollectionReference collection = Firestore.instance.collection('settings');

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  Future<List<AppData>> getData({bool shouldUpdate = true}) async {
    appData = [];
    await collection.getDocuments().then((QuerySnapshot snapshot) => {
      snapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
        appData.add(AppData.fromJson(documentSnapshot.data));
      })
    });
    print(appData.length);
    update(shouldUpdate);
    return appData;
  }

  Future<DocumentReference> addData(AppData appData) {
    return collection.add(appData.toJson());
  }

  void update(bool shouldUpdate) {
    if (shouldUpdate) notifyListeners();
  }
}