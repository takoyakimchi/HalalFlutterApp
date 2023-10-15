import 'dart:io';
import 'dart:math';

import 'package:first_flutter_app/app_screens/02_barcode_read_screen.dart';
import 'package:first_flutter_app/app_screens/01_0_clova_ocr.dart';
import 'package:first_flutter_app/app_screens/07_0_forum_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'app_screens/03_halal_food_map_screen.dart';
import 'app_screens/04_prayer_times_screen.dart';
import 'app_screens/05_qibla_direction_screen.dart';
import 'app_screens/06_ramadan_info_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'app_screens/08_change_language_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  File? image;

  // 바코드 스캔 함수
  Future<String> scanBarcode() async {
    String barcodeData = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666", // color of the scan button
      "Cancel", // text for the cancel button
      false, // enable flash
      ScanMode.BARCODE, // type of barcode to scan
    );

    return barcodeData;
  }

  // 이미지 가져오기 -> 카메라 or 갤러리 사용 가능
  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      image = File(pickedFile!.path); // 촬영한 이미지를 image에 저장
    });
  }

  // 이미지 자르기
  Future<void> cropImage(File? img) async {
    if (img != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: img.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: '이미지 자르기',
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
              hideBottomControls: true
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          image = File(croppedFile.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizedBox pad = const SizedBox(height: 20); // 위젯끼리 여백
    double buttonPadding = 8.0; // 버튼끼리의 여백
    double sWidth = MediaQuery.of(context).size.width; // 휴대폰 화면 너비
    double sHeight = MediaQuery.of(context).size.height; // 휴대폰 화면 높이
    double buttonHeightPercentage = 0.25; // 버튼 높이 비율
    double buttonWidthPercentage = 0.4; // 버튼 너비 비율
    double imageSize = max(sHeight, sWidth) * 0.15; // 로고 이미지 사이즈

    // 버튼에서 스택 아랫부분에 위치할 컨테이너 위젯
    Container smallIconContainer (Color color, IconData icon) {
      return Container(
        width: sWidth * buttonWidthPercentage,
        height: sHeight * buttonHeightPercentage / 2 - buttonPadding / 2,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: sWidth * buttonWidthPercentage * 0.2,
        ),
      );
    }

    // 버튼에서 스택 윗부분에 위치할 텍스트 위젯
    Padding buttonTextWidget (String txt) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 7.0),
        child: Center(
            child: Text(
              txt,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17.0,
                fontFamily: 'Kangwon'
              ),
              textAlign: TextAlign.center,
            )
        ),
      );
    }

    return Scaffold(
      body: Center( // 좌우 가운데 정렬
        child: Column(
          children: [
            /// Row: 최상위 공백
            SizedBox(height: sHeight * 0.1),
            /// Row: 어플 로고
            SizedBox(
              width: imageSize,
              height: imageSize,
              child: const Image(
                image: AssetImage('assets/images/halal.png')
              ),
            ),
            /// Row: 패딩
            pad,
            /// Row: 어플 이름
            const Text(
              "Halal Checker Korea",
              style: TextStyle(fontSize: 30, fontFamily: 'Kangwon'),
              textAlign: TextAlign.center,
            ),
            /// Row: 패딩
            pad, pad,
            /// Row: 첫번째 버튼 행
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Column 1: 메뉴판으로 확인하기
                GestureDetector(
                  onTap:  () async {
                    final navigator = Navigator.of(context);
                    // 버튼 누르면 뜨는 다이얼로그 창
                    await showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text(
                              AppLocalizations.of(context)!.getAnImageFrom,
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                // 1. Camera
                                TextButton(
                                  style: TextButton.styleFrom(
                                      textStyle: const TextStyle(fontSize: 18)
                                  ),
                                  onPressed: () async {
                                    await _getImage(ImageSource.camera);
                                    await cropImage(image);
                                    navigator.pop();
                                    await navigator.push(
                                      MaterialPageRoute(builder: (context) => ClovaOcr(image)),
                                    );
                                  },
                                  child: Text(AppLocalizations.of(context)!.camera),
                                ),

                                // 2. Gallery
                                TextButton(
                                  style: TextButton.styleFrom(
                                      textStyle: const TextStyle(fontSize: 18)
                                  ),
                                  onPressed: () async {
                                    await _getImage(ImageSource.gallery);
                                    await cropImage(image);
                                    navigator.pop();
                                    await navigator.push(
                                      MaterialPageRoute(builder: (context) => ClovaOcr(image)),
                                    );
                                  },
                                  child: Text(AppLocalizations.of(context)!.gallery),
                                ),
                              ],
                            ),
                          );
                        }
                    );
                  },
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: sWidth * buttonWidthPercentage,
                        height: sHeight * buttonHeightPercentage,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: min(sWidth * buttonWidthPercentage, sHeight * buttonHeightPercentage) * 0.4,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      buttonTextWidget(AppLocalizations.of(context)!.btnCheckMenu),
                    ],
                  ),
                ),
                /// Column 2: 여백
                SizedBox(width: buttonPadding),
                /// Column 3: 버튼 두개
                Column(
                  children: [
                    /// Row 1: 바코드 인식
                    GestureDetector(
                      onTap: () async {
                        String barcodeData = await scanBarcode();
                        if (barcodeData != '-1') {
                          Get.to(() => const BarcodeReadScreen(), arguments: barcodeData);
                        }
                      },
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          smallIconContainer(Colors.black, Icons.view_week),
                          buttonTextWidget(AppLocalizations.of(context)!.btnReadBarcode),
                        ],
                      ),
                    ),
                    /// Row 2: 여백
                    SizedBox(height: buttonPadding),
                    /// Row 3: 게시판
                    GestureDetector(
                      onTap: () async {
                        Get.to(() => ForumScreen());
                      },
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          smallIconContainer(Colors.black, Icons.dashboard),
                          buttonTextWidget(AppLocalizations.of(context)!.btnForum),

                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
            SizedBox(height: buttonPadding),
            /// Row: 두번째 버튼 행
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Column 1: 버튼 두개
                Column(
                  children: [
                    /// Row 1: 주변 할랄푸드 식당
                    GestureDetector(
                      onTap: () async {
                        Get.to(() => const HalalFoodMapScreen());
                      },
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          smallIconContainer(Colors.black, Icons.restaurant),
                          buttonTextWidget(AppLocalizations.of(context)!.btnNearestHalal),
                        ],
                      ),
                    ),
                    /// Row 2: 여백
                    SizedBox(height: buttonPadding),
                  ],
                ),
                /// Column 2: 여백
                SizedBox(width: buttonPadding),
                /// Column 3: 버튼 두개
                Column(
                  children: [
                    /// 언어 설정
                    GestureDetector(
                      onTap: () async {
                        Locale locale = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ChangeLanguageScreen()
                            )
                        );
                        Get.updateLocale(locale);
                      },
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          smallIconContainer(Colors.black, Icons.language),
                          buttonTextWidget(AppLocalizations.of(context)!.setLanguage),
                        ],
                      ),
                    ),
                    /// Row 2: 여백
                    SizedBox(height: buttonPadding),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Locale locale = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ChangeLanguageScreen()
              )
          );
          Get.updateLocale(locale);
        },
        child: const Icon(Icons.language),
      ),
    );
  }
}