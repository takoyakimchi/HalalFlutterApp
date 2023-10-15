import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  late String? author;
  late String? reviewContent;
  late double? rate;
  late String? password;
  late String? dateTime;
  DocumentReference? reference;

  Review(
      {required this.author,
        required this.reviewContent,
        required this.rate,
        required this.password,
        required this.dateTime,
        this.reference});

  Review.fromJson(dynamic json, this.reference) {
    rate = json['rate'];
    author = json['author'];
    reviewContent = json['reviewContent'];
    password = json['password'];
    dateTime = json['dateTime'];
  }

  //실제 document의 데이터 값 가져오기
  Review.fromSanpshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  //Collection으로 부터 query, snapshot을 통해 데이터 받아오기, data가 절대 null이 될 수 없음
  Review.fromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  //firebase에 넣기 위해 직렬화
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['rate'] = rate;
    map['author'] = author;
    map['reviewContent'] = reviewContent;
    map['dateTime'] = dateTime;
    map['password'] = password;
    return map;
  }


}
