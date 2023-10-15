import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  late String? postTitle;
  late String? author;
  late String? dateTime;
  late String? content;
  late String? docPW;
  DocumentReference? reference;

  Post(
      {required this.postTitle,
      required this.author,
      required this.dateTime,
      required this.content,
      required this.docPW,
      this.reference});

  Post.fromJson(dynamic json, this.reference) {
    postTitle = json['postTitle'];
    author = json['author'];
    content = json['content'];
    dateTime = json['dateTime'];
    docPW = json['docPW'];
  }

  //실제 document의 데이터 값 가져오기
  Post.fromSanpshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  //Collection으로 부터 query, snapshot을 통해 데이터 받아오기, data가 절대 null이 될 수 없음
  Post.fromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  //firebase에 넣기 위해 직렬화
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['postTitle'] = postTitle;
    map['author'] = author;
    map['dateTime'] = dateTime;
    map['content'] = content;
    map['docPW'] = docPW;
    return map;
  }
}
