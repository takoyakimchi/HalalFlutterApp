import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  late String? docId;
  late String? author;
  late String? dateTime;
  late String? content;
  late String? replyPW;
  DocumentReference? reference;

  Reply(
      {required this.docId,
      required this.author,
      required this.dateTime,
      required this.content,
      required this.replyPW,
      this.reference});

  Reply.fromJson(dynamic json, this.reference) {
    docId = json['docId'];
    author = json['author'];
    content = json['content'];
    dateTime = json['dateTime'];
    replyPW = json['replyPW'];
  }

  //실제 document의 데이터 값 가져오기
  Reply.fromSanpshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  //Collection으로 부터 query, snapshot을 통해 데이터 받아오기, data가 절대 null이 될 수 없음
  Reply.fromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  //firebase에 넣기 위해 직렬화
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['docId'] = docId;
    map['author'] = author;
    map['dateTime'] = dateTime;
    map['content'] = content;
    map['replyPW'] = replyPW;
    return map;
  }
}
