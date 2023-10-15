import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:first_flutter_app/classes/firestore_dao.dart';
import 'package:intl/intl.dart';

class FoodRateScreen extends StatefulWidget {
  const FoodRateScreen({super.key});

  @override
  _FoodRateScreenState createState() => _FoodRateScreenState();
}

class _FoodRateScreenState extends State<FoodRateScreen> {
  String foodName = '';
  double foodRate = -1.0;

  TextEditingController authorController = TextEditingController();
  String author = '';

  TextEditingController passwordController = TextEditingController();
  String password = '';

  TextEditingController foodReviewContentController = TextEditingController();
  String foodReviewContent = '';

  DateTime now = DateTime.now();
  late String dateTimeNow = DateFormat('yyyyMMdd HH:mm:ss').format(now);

  /// 초기화
  @override
  void initState() {
    foodName = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var stars = RatingBar.builder(
      minRating: 0.5,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: 50,
      itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        setState(() {
          foodRate = rating;
        });
      },
    );

    SizedBox pad = SizedBox(height: 20,);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.reviewThisFood),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 음식 이름
              Text(
                AppLocalizations.of(context)!.rate + " " + foodName,
                style: TextStyle(fontSize: 20)
              ),
              pad,

              // 음식 별점
              stars,
              pad,

              // 작성자명 텍스트필드
              TextField(
                controller: authorController,
                maxLines: 1,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: AppLocalizations.of(context)!.author),
                onChanged: (value) {
                  setState(() {
                    author = value;
                  });
                },
              ),
              pad,

              // 비밀번호 텍스트필드
              TextField(
                obscureText: true,
                controller: passwordController,
                maxLines: 1,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: AppLocalizations.of(context)!.password),
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              pad,

              // 리뷰 내용 텍스트필드
              TextField(
                controller: foodReviewContentController,
                maxLines: 8,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: AppLocalizations.of(context)!.content),
                onChanged: (value) {
                  setState(() {
                    foodReviewContent = value;
                  });
                },
              ),
              pad,

              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (author == "") {
                      // print("작성자명을 입력해 주세요.");
                    } else if (password == "") {
                      // print("비밀번호를 입력해 주세요.");
                    } else {
                      Map<String, dynamic> data = {
                        "rate": foodRate,
                        "author": author,
                        "password": password,
                        "dateTime": DateFormat('yyyyMMdd HH:mm:ss').format(now),
                        "reviewContent": foodReviewContent
                      };
                      
                      await FireDAO.createDoc("Reviews/reviews/$foodName", data); // firestore에 업로드

                      /// 평균 구하기
                      DocumentReference<Map<String, dynamic>> documentReference =
                          FirebaseFirestore.instance
                              .collection("Reviews/reviews/$foodName")
                              .doc('average');

                      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                          await documentReference.get(); // 평균 정보 받아오기

                      if (documentSnapshot.exists) {
                        /// 평균 정보가 이미 있는 경우, 계산해서 데이터베이스에 넣기
                        double rateSum = documentSnapshot['rateSum'];
                        int rateCount = documentSnapshot['rateCount'];
                        await documentReference.set({
                          'rateSum': rateSum + foodRate,
                          'rateCount': rateCount + 1
                        });
                      } else {
                        /// 평균 정보가 없는 경우 새로 설정함
                        await documentReference
                            .set({'rateSum': foodRate, 'rateCount': 1});
                      }

                      if (!mounted) {
                        return;
                      }

                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.upload),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
