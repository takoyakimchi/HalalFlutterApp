import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_flutter_app/classes/post_model.dart';
import 'package:first_flutter_app/classes/reply_model.dart';
import 'package:first_flutter_app/classes/review_model.dart';

class FireDAO {
  static final FireDAO _fireDAO = FireDAO._internal();

  factory FireDAO() => _fireDAO;

  FireDAO._internal();

  // doc 생성
  static Future createDoc(String collection, Map<String, dynamic> json) async {
    DocumentReference<Map<String, dynamic>> documentReference =
        FirebaseFirestore.instance.collection(collection).doc();

    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();

    if (!documentSnapshot.exists) {
      await documentReference.set(json);
    }
  }

  // 댓글 작성(테스트 중)
  static Future createReply(String docId, Map<String, dynamic> json) async {
    DocumentReference<Map<String, dynamic>> documentReference =
        FirebaseFirestore.instance.collection("Posts/$docId/Comments").doc();

    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();

    if (!documentSnapshot.exists) {
      await documentReference.set(json);
    }
  }

  // 컬렉션 내 모든 document 가져오기
  static Future<List<dynamic>> getList(String collection) async {
    CollectionReference<Map<String, dynamic>> collectionReference =
        FirebaseFirestore.instance.collection(collection);

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await collectionReference.orderBy("dateTime", descending: true).get();

    List<dynamic> docList = []; // List<Post> or List<Reply> or List<Review>

    String collectionType = collection.split("/").last;
    switch (collectionType) {
      case "Posts":
        for (var doc in querySnapshot.docs) {
          dynamic data = Post.fromQuerySnapshot(doc);
          docList.add(data);
        }
        break;
      case "Comments":
        for (var doc in querySnapshot.docs) {
          dynamic data = Reply.fromQuerySnapshot(doc);
          docList.add(data);
        }
        break;
      case "Reviews":
        for (var doc in querySnapshot.docs) {
          dynamic data = Review.fromQuerySnapshot(doc);
          docList.add(data);
        }
        break;
    }

    return docList;
  }

  //하나의 document만 가져오기
  static Future<dynamic> getOne(String collection, String docId) async {
    DocumentReference<Map<String, dynamic>> documentReference =
        FirebaseFirestore.instance.collection(collection).doc(docId);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();
    final dynamic data;

    String collectionType = collection.split("/").last;
    switch (collectionType) {
      case "Posts":
        data = Post.fromSanpshot(documentSnapshot);
        break;
      case "Comments":
        data = Reply.fromSanpshot(documentSnapshot);
        break;
      case "Reviews":
        data = Review.fromSanpshot(documentSnapshot);
        break;
      default:
        data = Review.fromSanpshot(documentSnapshot);
        break;
    }

    return data;
  }

  // 개선하는 중
  static Future<Map<String, dynamic>> improvedGetOne(
      String collection, String docId) async {
    final DocumentSnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
        .instance
        .collection(collection)
        .doc(docId)
        .get();

    Map<String, dynamic>? data = snap.data();

    if (data != null) {
      return data;
    } else {
      return {"error": "error"};
    }
  }

//documnet id 가져오기
  static String getId(dynamic doc) {
    DocumentReference<Object?>? docRef =
        doc.reference; // your document reference
    String tempId = docRef.toString().split("/").last;
    String docId = tempId.substring(0, tempId.length - 1);
    return docId;
  }

//삭제
  static Future<int> deleteDoc(
      String collection, String docId, String inputPW) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    dynamic obj = await FireDAO.getOne(collection, docId);

    String? docPW = obj.docPW;

    if (inputPW == docPW) {
      firestore.collection(collection).doc(docId).delete();
      return 1;
    } else
      return 0;
  }

// 수정d
  static Future<int> updateDoc(String collection, String docId, String inputPW,
      Map<String, dynamic> data) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    dynamic obj = await FireDAO.getOne(collection, docId);

    String? docPW = obj.docPW;
    if (inputPW == docPW) {
      firestore.collection(collection).doc(docId).update(data);
      return 1;
    } else
      return 0;
  }

//컬렉션 길이 가져오기
  static Future<int> getLength(String collection) async {
    final CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(collection);
    QuerySnapshot snapshot = await collectionReference.get();
    return snapshot.size;
  }
}
