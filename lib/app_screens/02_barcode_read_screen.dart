import 'dart:convert';
import 'package:first_flutter_app/classes/papago_translate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import 'package:first_flutter_app/classes/haram_ingredients.dart';

class BarcodeReadScreen extends StatefulWidget {
  const BarcodeReadScreen({super.key});

  @override
  _BarcodeReadScreenState createState() => _BarcodeReadScreenState();
}

class _BarcodeReadScreenState extends State<BarcodeReadScreen> {
  String barcode = "";
  String productName = "";
  String allergyInfoAsString = "";
  List<String> allergyInfoAsList = [];

  /// 초기화
  @override
  void initState() {
    initialize();
    super.initState();
  }

  /// 초기화
  Future<void> initialize() async {
    barcode = Get.arguments;
    await postRequest(barcode);
    allergyInfoAsString = await papagoTranslate(allergyInfoAsString, 'en');
    allergyInfoAsString = allergyInfoAsString.replaceAll("and ", "");
    setState(() {
      allergyInfoAsList = allergyInfoAsString.split(',');
    });
  }

  /// 바코드 post -> 알러지 정보 받아오기
  Future<void> postRequest(String barcode) async {
    String reportNumber = "";

    String apiKey1 = dotenv.env['FOODSAFETY_KEY'] ?? "error";
    Uri url1 = Uri.parse(
        'http://openapi.foodsafetykorea.go.kr/api/$apiKey1/C005/json/1/20/BAR_CD=$barcode');

    String apiKey2 = dotenv.env['DATA_GO_KR_KEY'] ?? "error";

    /// 서버 post (1)
    http.Response response = await http.post(
      url1,
    );

    // 받은 데이터 처리
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      if (jsonData['C005']['total_count'] == '0') {
        reportNumber = "-1"; // 상품 존재 안 함
      } else {
        reportNumber = jsonData['C005']['row'].last['PRDLST_REPORT_NO'];
      }
    } else {
      reportNumber = "-2"; // API 서버 오류
    }

    // 에러 처리
    if (reportNumber == "-1") {
      // setState(() {
      productName = AppLocalizations.of(context)!.noProduct;
      allergyInfoAsString = AppLocalizations.of(context)!.noProduct;
      // });
      return;
    } else if (reportNumber == "-2") {
      // setState(() {
      productName = AppLocalizations.of(context)!.apiServerError;
      allergyInfoAsString = AppLocalizations.of(context)!.apiServerError;
      // });
      return; // 데이터가 없으므로 2번째 api 호출이 의미 없음. 따라서 리턴.
    }

    /// 서버 post (2)
    final params = {
      'serviceKey': apiKey2,
      'prdlstReportNo': reportNumber,
      'returnType': 'xml',
      'pageNo': '1',
      'numOfRows': '10'
    };

    final uri = Uri.https('apis.data.go.kr',
        '/B553748/CertImgListService/getCertImgListService', params);
    final response2 = await http.post(uri);

    // 데이터 처리
    if (response2.statusCode == 200) {
      final xmlData = response2.body;
      final xmlParsed = Xml2Json()
        ..parse(xmlData);
      final jsonData = xmlParsed.toParker();
      var data = jsonDecode(jsonData);
      // setState(() {
      productName =
      data['response']['body']['items']['item']['prdlstNm']; // 제품명
      allergyInfoAsString =
      data['response']['body']['items']['item']['allergy']; // 알러지정보
      allergyInfoAsString = allergyInfoAsString
          .replaceAll('함유', '') // 뒤에 '함유' 빼기
          .replaceAll(RegExp('\\s'), ""); // 공백 제거하기
      // });
    } else {
      // setState(() {
      allergyInfoAsString = AppLocalizations.of(context)!.apiServerError2; // API 서버 오류
      // });
    }
  }

  /// 문자열이 금지 식재료면 true, 아니면 false
  bool isHaram(String ingredient) {
    for (String haram in haramIngredients) {
      if (ingredient.contains(haram)) {
        return true;
      }
    }
    return false;
  }

  Widget horizontalDividerLine = const Padding(
    padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0), // 위아래 패딩 20.0
    child: Divider(thickness: 1, height: 1, color: Colors.grey),
  );

  @override
  Widget build(BuildContext context) {
    List<Widget> allergyWidgetList = allergyInfoAsList.map((allergy) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(
              isHaram(allergy) ? Icons.error : Icons.check,
              color: isHaram(allergy) ? Colors.red : Colors.green,
            ),
            SizedBox(width: 8.0),
            Text(allergy),
          ],
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.btnReadBarcode),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.barcodeInfo,
              style: TextStyle(fontSize: 15),
            ),
            Padding(padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0)),
            Text(
              barcode,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            horizontalDividerLine,
            SizedBox(height: 16.0),
            Text(
              AppLocalizations.of(context)!.productName,
              style: TextStyle(fontSize: 15),
            ),
            Padding(padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0)),

            Text(
              productName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            horizontalDividerLine,
            SizedBox(height: 16.0),
            Text(
              AppLocalizations.of(context)!.allergyInfo,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: allergyWidgetList,
            ),
          ],
        ),
      ),
    );
  }
}
