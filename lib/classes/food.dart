import 'dart:math';

import 'package:first_flutter_app/classes/papago_translate.dart';
import 'package:flutter/material.dart';

// 음식의 정보를 담는 클래스
class Food {
  String name = ""; // 음식명
  String englishName = "";

  List<String> halalIngredients = [];
  List<String> haramIngredients = [];
  List<String> meatIngredients = [];
  List<String> ambiguousIngredients = [];
  double foodRate = -1.0;
  List<Point> vertices = [];

  String halalString = "";
  String haramString = "";
  String meatString = "";
  String ambiguousString = "";

  /// 생성자
  // 기본
  Food(
      this.name,
      this.haramIngredients,
      this.halalIngredients,
      this.ambiguousIngredients,
      this.meatIngredients,
      this.foodRate,
      );

  // 이름만으로 초기화
  Food.withName(this.name);

  // 이름과 좌표값 리스트로 초기화
  Food.withNameAndVertices(String name, List<Point> vertices) {
    this.name = name;
    this.vertices = vertices;
  }

  /// 멤버 함수
  // 할랄 여부를 판단
  bool isHalal() {
    return haramIngredients.isEmpty &&
        meatIngredients.isEmpty &&
        ambiguousIngredients.isEmpty;
  }

  String getEdibility() {
    if (haramIngredients.isEmpty && meatIngredients.isEmpty && ambiguousIngredients.isEmpty) {
      return "halal";
    } else if (haramIngredients.isNotEmpty) {
      return "haram";
    } else {
      return "ambiguous";
    }
  }

  Icon getFoodIcon() {
    if (haramIngredients.isEmpty && meatIngredients.isEmpty && ambiguousIngredients.isEmpty) {
      return Icon(Icons.check, color: Colors.green);
    } else if (haramIngredients.isNotEmpty) {
      return Icon(Icons.error, color: Colors.red);
    } else {
      return Icon(Icons.question_mark, color: Colors.grey);
    }
  }

  Future<String> halalAsText () async {
    String str = halalIngredients.join(',');
    return papagoTranslate(str, 'en');
  }

  String haramAsText () {
    return haramIngredients.join(',');
  }

  String meatAsText () {
    return meatIngredients.join(',');
  }

  String ambiguousAsText () {
    return ambiguousIngredients.join(',');
  }
}

// 인식한 텍스트와 좌표값만 담음
class RecognitionWord {
  String word = "";
  List<Point> vertices = [Point(0, 0), Point(0, 0), Point(0, 0), Point(0, 0)];

  RecognitionWord(this.word, this.vertices);
  RecognitionWord.byWord(this.word);
}