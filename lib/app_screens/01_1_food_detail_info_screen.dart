import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_flutter_app/app_screens/01_2_food_rate_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:first_flutter_app/classes/review_model.dart';
import 'package:intl/intl.dart';
import '../classes/food.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FoodDetailInfoScreen extends StatefulWidget {
  const FoodDetailInfoScreen({super.key});

  @override
  _FoodDetailInfoScreenState createState() => _FoodDetailInfoScreenState();
}

class _FoodDetailInfoScreenState extends State<FoodDetailInfoScreen> {
  late Food food;
  List<dynamic> reviewList = [];
  List<String> reviewIdList = [];
  double averageRate = 0.0;
  String inputPw = "";
  String stringPasswordIsWrong = "";

  /// 초기화
  @override
  void initState() {
    initialize();
    super.initState();
  }

  /// 초기화
  Future<void> initialize() async {
    food = Get.arguments;
    await _loadReviews();
  }

  /// 파이어스토어 DB로부터 데이터 받아서 List 채우기
  Future<void> _loadReviews() async {
    reviewList = [];
    reviewIdList = [];

    /// 리뷰 정보 모두 가져오기
    CollectionReference<Map<String, dynamic>> collectionReference =
    FirebaseFirestore.instance.collection("/Reviews/reviews/${food.name}");
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await collectionReference.orderBy("dateTime", descending: true).get();
    for (var doc in querySnapshot.docs) {
      dynamic data = Review.fromQuerySnapshot(doc);
      if (doc.id != "average") {
        reviewList.add(data);
        reviewIdList.add(doc.id);
      } else {
        int rateCount = doc.data()['rateCount'];
        double rateSum = doc.data()['rateSum'];
        setState(() {
          averageRate = rateSum / rateCount;
        });
      }
    }

    /// 평점 정보만 가져오기
    if (querySnapshot.docs.length > 0) {
      DocumentReference<Map<String, dynamic>> docRef =
      FirebaseFirestore.instance.collection("/Reviews/reviews/${food.name}").doc('average');
      DocumentSnapshot<Map<String, dynamic>> docSnap = await docRef.get();
      int rateCount = docSnap['rateCount'];
      double rateSum = docSnap['rateSum'];
      setState(() {
        averageRate = rateSum / rateCount;
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    stringPasswordIsWrong = "";
    TextEditingController textFieldPwController = TextEditingController();

    List<Widget> reviewWidgetList = [];
    const double columnPadding = 30.0;
    const double titleFontSize = 22.0;
    const double contentsFontSize = 18.0;

    /// 구분선
    Widget horizontalDividerLine = const Padding(
      padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0), // 위아래 패딩 20.0
      child: Divider(thickness: 1, height: 1, color: Colors.grey),
    );

    /// 동적으로 리뷰의 List를 생성하는 과정
    for (int i = 0; i < reviewList.length; i++) {
      String author = reviewList[i].author ?? "null author"; // 작성자명
      String reviewContent = reviewList[i].reviewContent ?? "null content"; // 리뷰 내용
      double rate = reviewList[i].rate ?? 0.0; // 리뷰 평점
      String dateTime = reviewList[i].dateTime;

      // 리스트에 추가할 각각의 위젯 지정
      reviewWidgetList.add(Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: 0.5),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Row 1: 작성자 이름 + 삭제 버튼
                  ListTile(
                    /// 작성자 이름
                    title: Text(
                      author,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),

                    /// 삭제 아이콘
                    trailing: GestureDetector(
                        onTap: () async {
                          showDialog(context: context, builder: (context) {
                            return AlertDialog(
                                title: Text(AppLocalizations.of(context)!.enterPassword),
                                content: SizedBox(
                                  height: 150,
                                  child: Column(
                                      children: [
                                        TextField(
                                          style: const TextStyle(fontSize: 15),
                                          obscureText: true,
                                          maxLength: 8,
                                          controller: textFieldPwController,
                                          decoration: InputDecoration(
                                              border: const OutlineInputBorder(),
                                              hintText: AppLocalizations.of(context)!.password,
                                              hintStyle: const TextStyle(
                                                fontSize: 15,
                                              ),
                                              counterText: ''),
                                          onChanged: (value) {
                                            setState(() {
                                              inputPw = value;
                                            });
                                          },
                                        ),

                                        ElevatedButton(onPressed: () async {
                                          if (inputPw == reviewList[i].password) {
                                            // 비밀번호가 맞은 경우
                                            FirebaseFirestore.instance.collection("/Reviews/reviews/${food.name}").doc(reviewIdList[i]).delete();
                                            Navigator.of(context).pop();
                                            await _loadReviews();
                                          } else {
                                            setState(() {
                                              showDialog(context: context, builder: (context) {
                                                return AlertDialog(content: Text(AppLocalizations.of(context)!.wrongPassword));
                                              });
                                            });
                                            textFieldPwController.clear();
                                          }
                                        }, child: Text(AppLocalizations.of(context)!.check)),
                                      ]
                                  ),
                                )
                            );
                          });
                        },
                        child: Icon(Icons.delete)
                    ),
                  ),

                  /// Row 2: 별점 + 날짜
                  Row(
                    children: [
                      SizedBox(width: 10.0),
                      RatingBarIndicator(
                        rating: rate,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 15.0,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                        direction: Axis.horizontal,
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(dateTime)),
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),

                  /// Row 3: 리뷰 내용
                  horizontalDividerLine,
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      reviewContent,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ));

      reviewWidgetList.add(SizedBox(height: 20));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("음식의 세부 정보"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 40.0, 25.0, 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                food.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),

              const SizedBox(height: 8.0),
              Text(food.englishName, style: TextStyle(fontSize: 22)),
              const SizedBox(height: 8.0),

              /// DB에 담겨 있는 음식의 평점 평균
              RatingBarIndicator(
                rating: averageRate,
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 30.0,
                itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                direction: Axis.horizontal,
              ),

              // 구분선
              const Padding(
                padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                child: Divider(thickness: 1, height: 1, color: Colors.grey),
              ),

              Text(AppLocalizations.of(context)!.halalIngredients,
                  style: TextStyle(
                      fontSize: titleFontSize, fontWeight: FontWeight.bold)),
              Text(
                food.halalString,
                style: const TextStyle(fontSize: contentsFontSize),
              ),

              const SizedBox(height: columnPadding),
              Text(AppLocalizations.of(context)!.haramIngredients,
                  style: TextStyle(
                      fontSize: titleFontSize, fontWeight: FontWeight.bold)),
              Text(
                food.haramString,
                style: const TextStyle(fontSize: contentsFontSize),
              ),

              const SizedBox(height: columnPadding),
              Text(AppLocalizations.of(context)!.meatIngredients,
                  style: TextStyle(
                      fontSize: titleFontSize, fontWeight: FontWeight.bold)),
              Text(food.meatString,
                  style: const TextStyle(fontSize: contentsFontSize)),

              const SizedBox(height: columnPadding),
              Text(AppLocalizations.of(context)!.ambiguousIngredients,
                  style: const TextStyle(
                      fontSize: titleFontSize, fontWeight: FontWeight.bold)),
              Text(food.ambiguousString,
                  style: const TextStyle(fontSize: contentsFontSize)),

              /// 이하 후기 동적으로 표시
              const SizedBox(height: columnPadding),
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.reviewsAndComments,
                      style: const TextStyle(
                          fontSize: titleFontSize, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  RawMaterialButton(
                    onPressed: () async {
                      await Get.to(() => const FoodRateScreen(), arguments: food.name);
                      await _loadReviews();
                    },
                    child: Icon(Icons.create, color: Colors.white,),
                    shape: CircleBorder(),
                    fillColor: Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: columnPadding),
              Column(
                children: reviewWidgetList,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
