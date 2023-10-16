import 'dart:io';
import 'dart:math';
import 'package:first_flutter_app/app_screens/01_1_food_detail_info_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';
import 'package:first_flutter_app/classes/food.dart';
import 'package:first_flutter_app/classes/papago_translate.dart';

class ClovaOcr extends StatefulWidget {
  final File? imageFile;

  const ClovaOcr(this.imageFile, {super.key});

  @override
  ClovaOcrState createState() => ClovaOcrState();
}

class ClovaOcrState extends State<ClovaOcr> {
  int wordCnt = 0; // 인식한 단어의 개수
  File? imgFile; // 가져온 이미지 파일

  String lang = 'en';
  bool debugMode = true;

  late Future myFuture;

  /// 초기화
  @override
  void initState() {
    imgFile = widget.imageFile;
    myFuture = clovaOcrRequest();
    super.initState();
  }

  /// 문자열이 숫자 포함하는지
  bool containsNumber(String text) {
    final regex = RegExp(r'[0-9]');
    return regex.hasMatch(text);
  }

  /// 함수: 클로바 API 돌리기 -> 모든 정보가 채워진 List<Food> 리턴
  Future<List<Food>> clovaOcrRequest() async {
    imgFile = widget.imageFile;
    List<RecognitionWord> wordList = [];
    List<Food> foodList = [];

    String b64Image = "";

    // 이미지 -> 바이트
    if (imgFile != null) {
      List<int> imageBytes = await imgFile!.readAsBytes();
      b64Image = base64Encode(imageBytes);
    }

    // API 헤더 구성
    Map<String, String> headers = {
      'X-OCR-SECRET': dotenv.env['CLOVA_KEY']!,
      'Content-Type': 'application/json'
    };

    // API body 구성
    var body = jsonEncode(
        {
          'images': [
            {
              'format': 'jpg',
              'name': 'menu_image',
              'data': b64Image
            }
          ],
          'requestId': const Uuid().v4(),
          'version': 'V2',
          'timestamp': DateTime.now().millisecondsSinceEpoch
        }
    );

    // api 호출하기
    http.Response response = await http.post(
        Uri.parse(dotenv.env['CLOVA_URL']!),
        headers: headers,
        body: body
    );

    // 서버에서 받아온 데이터 처리
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body); // json 파싱

      wordCnt = json['images'][0]['fields'].length; // 인식한 단어의 개수

      // fList 채우기
      for (int i = 0; i < wordCnt; i++) {
        // 음식명과 좌표값
        String foodName = json['images'][0]['fields'][i]['inferText'];
        var verticesAsJson = json['images'][0]['fields'][i]['boundingPoly']['vertices'];

        // 좌표값 파싱
        List<Point> vertices = [];
        for (int j = 0; j < 4; j++) {
          vertices.add(Point(verticesAsJson[j]['x'], verticesAsJson[j]['y']));
        }

        // 인식한 텍스트와 좌표값만 채우기
        RecognitionWord wordInfo = RecognitionWord(foodName, vertices);
        wordList.add(wordInfo);

        // 데이터 가공
        foodList = refineWordList(wordList);
      }

      // 만개의레시피 돌리기
      for(int i = 0; i < foodList.length; i++) {
        // print(foodList[i].name);
        foodList[i] = await fillFoodInfoFromServer(foodList[i]);
      }

      // 음식 영어 이름 채우기
      for(int i = 0; i < foodList.length; i++) {
        foodList[i].englishName = await papagoTranslate(foodList[i].name, 'en');
      }
    }
    return foodList;
  }

  /// 유의미한 데이터 가공: List<RecognitionWord>에서 의미 있는 값만 추출하고, List<Food> 반환
  List<Food> refineWordList(List<RecognitionWord> wordList) {
    /// 금지어 포함하는지 여부
    bool stringContainsBanWord(String str) {
      List<String> banWords = ['입니다', '습니다', '합니다', '메뉴', '국내산', '식당',
        '원산지', '됩니다', '식사', '안주', '주류', '차림표', '면류', '밥류',
        '이상', '주문시', '가능', '미국산', '러시아산'
      ];
      for(String word in banWords) {
        if (str.contains(word)) {
          return true;
        }
      }
      if(str == "원") {
        return true;
      }
      return false;
    }
    
    List<RecognitionWord> newWordList = [];
    List<Food> foodListToReturn = [];

    String seperatedSubstring = "";

    /// for -- 인식한 단어 리스트를 루프
    for(RecognitionWord rw in wordList) {
      // 숫자 포함하는 경우 고려하지 않음
      if(containsNumber(rw.word)) {
        continue;
      }

      // 괄호 및 괄호 내부 제거
      rw.word = rw.word.replaceAll(RegExp(r'\([^)]*\)'), '');

      // 공백 제거
      rw.word = rw.word.replaceAll(' ', '');

      // 한글 빼고 다 제거
      rw.word = rw.word.replaceAll(RegExp('[^가-힣\\s]'), "");

      /// add 시작 -> 현재 루프의 단어만 애드
      if (rw.word != '') {
        /// 현재 문자열이 1글자인 경우
        if (rw.word.length == 1) {
          seperatedSubstring += rw.word; // 임시 문자열에 concat해놓기.
        }
        /// 현재 문자열이 2글자 이상인 경우
        else {
          if (seperatedSubstring != "") {
            if (seperatedSubstring.length != 1) { // 한글자짜리 메뉴는 웬만하면 없으니까 과감하게 버리기
              newWordList.add(RecognitionWord.byWord(seperatedSubstring)); // 저장 문자열 add
            }
            seperatedSubstring = ""; // 저장 문자열 초기화
          }
          newWordList.add(rw); // 현재 문자열 add
        }
      }
    }
    /// for end

    // 한글자 단어 빼기
    for(RecognitionWord rw in newWordList) {
      if(rw.word.length == 1) {
        continue; // 한글자 무시
      }

      if(stringContainsBanWord(rw.word)) {
        continue; // 금지어 포함 단어 무시
      }

      foodListToReturn.add(Food.withName(rw.word));
    }

    return foodListToReturn;
  }

  
  /// 함수: Food 정보 채우기(만개의레시피 크롤링)
  Future<Food> fillFoodInfoFromServer(Food food) async {
    Food filledFood = Food.withNameAndVertices(food.name, food.vertices); // 리턴할 Food 객체
    filledFood.englishName = await papagoTranslate(food.name, 'en');

    // 헤더 구성
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['FLASK_API_KEY']!,
    };

    // Flask 서버 호출 -> 만개의 레시피 크롤링
    http.Response response = await http.post(
        Uri.parse(dotenv.env['FLASK_SERVER_CALL_URI']!),
        headers: headers,
        body: jsonEncode([{'food_name': food.name}])
    );

    // 서버에서 받아온 값
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);

      // 리턴할 Food object에 값 채우기
      filledFood.halalIngredients = List<String>.from(json['halal_list'] as List);
      if(filledFood.halalIngredients.isNotEmpty) {
        filledFood.halalString = await papagoTranslate(filledFood.halalIngredients.join(','), 'en');
      }

      filledFood.haramIngredients = List<String>.from(json['haram_list'] as List);
      if(filledFood.haramIngredients.isNotEmpty){
        filledFood.haramString = await papagoTranslate(filledFood.haramIngredients.join(','), 'en');
      }

      filledFood.meatIngredients = List<String>.from(json['meat_list'] as List);
      if(filledFood.meatIngredients.isNotEmpty) {
        filledFood.meatString = await papagoTranslate(filledFood.meatIngredients.join(','), 'en');
      }

      filledFood.ambiguousIngredients = List<String>.from(json['ambiguous_list'] as List);
      if(filledFood.ambiguousIngredients.isNotEmpty) {
        filledFood.ambiguousString = await papagoTranslate(filledFood.ambiguousIngredients.join(','), 'en');
      }
    } else {
      filledFood = Food("Flask Error ${response.statusCode}", ["Flask Error"], ["Flask Error"], ["Flask Error"], ["Flask Error"], 5.0);
    }

    return filledFood;
  }

  /// 화면 그리기
  @override
  Widget build(BuildContext context) {
    const double inCardPadding = 4.0;

    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.btnCheckMenu),
              // 뒤로가기 버튼
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
            body: FutureBuilder(
                future: myFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  wordCnt = snapshot.data!.length;
                  List<Food> foodList = snapshot.data!;

                  Column foodColumn = Column(children: [],);
                  for (Food food in foodList) {
                    foodColumn.children.add(
                        GestureDetector(
                            onTap: () {
                              Get.to(() => const FoodDetailInfoScreen(),
                                  arguments: food);
                            },
                            child: SizedBox(
                              // height: 140,
                              child: Card(
                                child: ListTile(
                                    minLeadingWidth: 0,
                                    leading: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        food.getFoodIcon(),
                                      ],
                                    ),
                                    subtitle: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(food.name, style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                        const SizedBox(height: inCardPadding),

                                        Text(food.englishName, style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                        const SizedBox(height: inCardPadding),

                                        Text("Halal: ${food.halalString}",
                                            style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: inCardPadding),

                                        Text("Haram: ${food.haramString}",
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: inCardPadding),

                                        Text("Meat: ${food.meatString}",
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: inCardPadding),

                                        Text(
                                            "Ambi: ${food.ambiguousString}",
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    )
                                ),
                              ),
                            )
                        )
                    );
                  }

                  return SingleChildScrollView(
                      child: foodColumn
                  );
                }
            )
        )
    );
  }
}
