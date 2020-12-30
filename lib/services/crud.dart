import 'package:cloud_firestore/cloud_firestore.dart';

class CrudMethods {
  Future<void> addData(blogData) async {
    FirebaseFirestore.instance.collection("blogs").add(blogData).catchError((e) {
      print(e);
    });
  }

  getData() async {
    return FirebaseFirestore.instance
        .collection('blogs')
        .orderBy("time", descending: true)
        .snapshots();
  }

  
}
