import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DataHelper {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<List<Map<String,dynamic>>> getData() async {
    List<Map<String,dynamic>> data = [];
    await _db
        .collection("todos")
        .where('isDeleted', isEqualTo: false)
        .get()
        .then((value) {
          for(var doc in value.docs){
            Map<String,dynamic> temp;
            temp = doc.data();
            temp.addAll({"id":doc.id});
            data.add(temp);
          }
            return value;
        });
    return data;
  }
  
  static Future<void> addTask(String text) async {
    await _db.collection("todos").add({"text": text, "isDone": false, "isDeleted": false}).then((value) {
      if (kDebugMode) {
        print('New Task Added :) with ID : ${value.id}');
      }
    });
  }

  static Future<void> updateTaskState(String id, bool isDone) async {
    await _db.collection("todos").doc(id).update({"isDone" : isDone});
  }

  static Future<void> updateTaskText(String id, String text) async {
    await _db.collection("todos").doc(id).update({"text":text});
  }

  static Future<void> deleteTask(String id) async {
    await _db.collection("todos").doc(id).update({"isDeleted": true});
  }
}
