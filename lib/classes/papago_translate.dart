import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// 함수  파파고 API에 접속해서 번역하기
/// 인자  msg: 번역할 메시지, lang: 번역할 언어 ('en')
/// 리턴  번역 완료한 String
Future<String> papagoTranslate(String msg, String lang) async {
  String result = "";
  Uri url = Uri.parse("https://openapi.naver.com/v1/papago/n2mt");

  Map<String, String> headers = {
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    'X-Naver-Client-Id': dotenv.env['PAPAGO_ID']!,
    'X-Naver-Client-Secret': dotenv.env['PAPAGO_SECRET']!
  };

  Map<String, String> body = {
    'source': 'ko',
    'target': lang,
    'text': msg
  };

  http.Response response = await http.post(url, headers: headers, body: body);
  if (response.statusCode == 200) {
    var jsonData = jsonDecode(response.body);
    result = jsonData['message']['result']['translatedText'];
  } else {
    result = "Error: papago api error";
  }

  return result;
}