import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:first_flutter_app/classes/food.dart';
import 'package:uuid/uuid.dart';


class DebugScreen extends StatefulWidget {
  final File? imageFile;
  const DebugScreen(this.imageFile, {super.key});

  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  File? imgFile;
  List<String> recogWordList = [];

  /// 초기화
  @override
  void initState() {
    super.initState();
    init();
  }

  Future init() async {
    recogWordList = await clovaOcrRequest();
    setState(() {});
  }

  /// 문자열이 숫자 포함하는지
  bool containsNumber(String text) {
    final regex = RegExp(r'[0-9]');
    return regex.hasMatch(text);
  }

  /// 클로바 ocr api 호출
  Future<List<String>> clovaOcrRequest() async {
    imgFile = widget.imageFile;
    List<RecognitionWord> wordList = [];
    List<String> stringListToReturn = [];

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
      int wordCnt = json['images'][0]['fields'].length; // 인식한 단어의 개수

      // wordList 채우기
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
      }
    }

    stringListToReturn = refineWordList(wordList);
    return stringListToReturn;
  }

  /// 금지어 포함하는지 여부
  bool stringContainsBanWord(String str) {
    List<String> banWords = ['입니다', '습니다', '합니다', '메뉴', '국내산', '식당',
      '원산지', '됩니다', '식사', '안주', '주류', '차림표', '면류', '밥류'];
    for(String word in banWords) {
      if (str.contains(word)) {
        return true;
      }
    }
    return false;
  }

  /// wordList 가공
  List<String> refineWordList(List<RecognitionWord> wordList) {
    List<RecognitionWord> newWordList = [];
    List<String> stringListToReturn = [];

    String seperatedSubstring = "";

    /// for start
    for(RecognitionWord rw in wordList) {
      bool isEndOfWord = false;

      // 괄호 및 괄호 내부 제거
      rw.word = rw.word.replaceAll(RegExp(r'\([^)]*\)'), '');

      // 공백 제거
      rw.word = rw.word.replaceAll(' ', '');

      // 숫자랑 한글 빼고 다 제거
      rw.word = rw.word.replaceAll(RegExp('[^0-9가-힣\\s]'), "");

      // 숫자 포함하는 경우 단어의 끝임
      if(containsNumber(rw.word)) {
        isEndOfWord = true;
      }

      // 숫자 제거
      rw.word = rw.word.replaceAll(RegExp('[0-9]'), '');

      /// add 시작 -> 현재 루프의 단어만 애드
      if (rw.word != '') {
        /// 현재 문자열이 1글자인 경우
        if (rw.word.length == 1) {
          seperatedSubstring += rw.word; // 임시 문자열에 concat해놓기.
          // 단어의 끝인 경우 애드하고 서브스트링 초기화하기
          if (isEndOfWord) {
            newWordList.add(RecognitionWord.byWord(seperatedSubstring));
            seperatedSubstring = "";
          }
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

      stringListToReturn.add(rw.word);
    }

    return stringListToReturn;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];

    // 화면에 표시할 위젯 리스트 구성하기
    for(int i = 0; i < recogWordList.length; i++){
      widgetList.add(
          Column(
            children: [
              Text(
                  "index $i: ${recogWordList[i]} "
              ),
              Text("\n"),
            ],
          )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.btnCheckMenu),
        // 뒤로가기 버튼
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black54,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: widgetList,
          ),
        ),
      ),
    );
  }
}
