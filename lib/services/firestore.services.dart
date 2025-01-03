import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filestorage/services/coludinary.service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreServices {
  User? user = FirebaseAuth.instance.currentUser;
  String collectionPath = "user-files";
  Future<void> saveUploadedFileData(Map<String, String> data) async {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(user!.uid)
        .collection("uploads")
        .doc()
        .set(data);
  }

  Stream<QuerySnapshot> readUploadFiles() {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(user!.uid)
        .collection("uploads")
        .snapshots();
  }

  Future<bool> deleteFile(String docId, String id) async {
    final result = await deleteToCloudinary(id);
    if (result) {
      await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(user!.uid)
          .collection("uploads")
          .doc(docId)
          .delete();
      return true;
    }
    return false;
  }
}
