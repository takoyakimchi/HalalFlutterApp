// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Halal Food Checker`
  String get titleMainScreen {
    return Intl.message(
      'Halal Food Checker',
      name: 'titleMainScreen',
      desc: '',
      args: [],
    );
  }

  /// `Check Menu`
  String get btnCheckMenu {
    return Intl.message(
      'Check Menu',
      name: 'btnCheckMenu',
      desc: '',
      args: [],
    );
  }

  /// `Read Barcode`
  String get btnReadBarcode {
    return Intl.message(
      'Read Barcode',
      name: 'btnReadBarcode',
      desc: '',
      args: [],
    );
  }

  /// `Halal Restaurants`
  String get btnNearestHalal {
    return Intl.message(
      'Halal Restaurants',
      name: 'btnNearestHalal',
      desc: '',
      args: [],
    );
  }

  /// `Prayer Times`
  String get btnPrayerTimes {
    return Intl.message(
      'Prayer Times',
      name: 'btnPrayerTimes',
      desc: '',
      args: [],
    );
  }

  /// `Qibla Direction`
  String get btnQiblaDirection {
    return Intl.message(
      'Qibla Direction',
      name: 'btnQiblaDirection',
      desc: '',
      args: [],
    );
  }

  /// `Ramadan Calender`
  String get btnRamadan {
    return Intl.message(
      'Ramadan Calender',
      name: 'btnRamadan',
      desc: '',
      args: [],
    );
  }

  /// `Forum`
  String get btnForum {
    return Intl.message(
      'Forum',
      name: 'btnForum',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get btnEnglish {
    return Intl.message(
      'English',
      name: 'btnEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Get an image from...`
  String get getAnImageFrom {
    return Intl.message(
      'Get an image from...',
      name: 'getAnImageFrom',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gallery {
    return Intl.message(
      'Gallery',
      name: 'gallery',
      desc: '',
      args: [],
    );
  }

  /// `Halal`
  String get halal {
    return Intl.message(
      'Halal',
      name: 'halal',
      desc: '',
      args: [],
    );
  }

  /// `Haram`
  String get haram {
    return Intl.message(
      'Haram',
      name: 'haram',
      desc: '',
      args: [],
    );
  }

  /// `Forum`
  String get forum {
    return Intl.message(
      'Forum',
      name: 'forum',
      desc: '',
      args: [],
    );
  }

  /// `Go to Main`
  String get goToMain {
    return Intl.message(
      'Go to Main',
      name: 'goToMain',
      desc: '',
      args: [],
    );
  }

  /// `Make post`
  String get makePost {
    return Intl.message(
      'Make post',
      name: 'makePost',
      desc: '',
      args: [],
    );
  }

  /// `Post upload`
  String get postUpload {
    return Intl.message(
      'Post upload',
      name: 'postUpload',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get title {
    return Intl.message(
      'Title',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Author`
  String get author {
    return Intl.message(
      'Author',
      name: 'author',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get upload {
    return Intl.message(
      'Upload',
      name: 'upload',
      desc: '',
      args: [],
    );
  }

  /// `Content`
  String get content {
    return Intl.message(
      'Content',
      name: 'content',
      desc: '',
      args: [],
    );
  }

  /// `View post`
  String get board {
    return Intl.message(
      'View post',
      name: 'board',
      desc: '',
      args: [],
    );
  }

  /// `Wrong Password, please enter password again`
  String get wrongPassword {
    return Intl.message(
      'Wrong Password, please enter password again',
      name: 'wrongPassword',
      desc: '',
      args: [],
    );
  }

  /// `Check`
  String get check {
    return Intl.message(
      'Check',
      name: 'check',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `Go to forum`
  String get goToForum {
    return Intl.message(
      'Go to forum',
      name: 'goToForum',
      desc: '',
      args: [],
    );
  }

  /// `Review this food`
  String get reviewThisFood {
    return Intl.message(
      'Review this food',
      name: 'reviewThisFood',
      desc: '',
      args: [],
    );
  }

  /// `Rate`
  String get rate {
    return Intl.message(
      'Rate',
      name: 'rate',
      desc: '',
      args: [],
    );
  }

  /// `Enter password`
  String get enterPassword {
    return Intl.message(
      'Enter password',
      name: 'enterPassword',
      desc: '',
      args: [],
    );
  }

  /// `Product does not exist.`
  String get noProduct {
    return Intl.message(
      'Product does not exist.',
      name: 'noProduct',
      desc: '',
      args: [],
    );
  }

  /// `API Server error`
  String get apiServerError {
    return Intl.message(
      'API Server error',
      name: 'apiServerError',
      desc: '',
      args: [],
    );
  }

  /// `API Server(2) error`
  String get apiServerError2 {
    return Intl.message(
      'API Server(2) error',
      name: 'apiServerError2',
      desc: '',
      args: [],
    );
  }

  /// `Barcode Information`
  String get barcodeInfo {
    return Intl.message(
      'Barcode Information',
      name: 'barcodeInfo',
      desc: '',
      args: [],
    );
  }

  /// `Product Name`
  String get productName {
    return Intl.message(
      'Product Name',
      name: 'productName',
      desc: '',
      args: [],
    );
  }

  /// `Allergy Information`
  String get allergyInfo {
    return Intl.message(
      'Allergy Information',
      name: 'allergyInfo',
      desc: '',
      args: [],
    );
  }

  /// `Halal Ingredients`
  String get halalIngredients {
    return Intl.message(
      'Halal Ingredients',
      name: 'halalIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Haram Ingredients`
  String get haramIngredients {
    return Intl.message(
      'Haram Ingredients',
      name: 'haramIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Meat Ingredients`
  String get meatIngredients {
    return Intl.message(
      'Meat Ingredients',
      name: 'meatIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Ambiguous Ingredients`
  String get ambiguousIngredients {
    return Intl.message(
      'Ambiguous Ingredients',
      name: 'ambiguousIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Food Rate!`
  String get foodRate {
    return Intl.message(
      'Food Rate!',
      name: 'foodRate',
      desc: '',
      args: [],
    );
  }

  /// `Reviews and comments`
  String get reviewsAndComments {
    return Intl.message(
      'Reviews and comments',
      name: 'reviewsAndComments',
      desc: '',
      args: [],
    );
  }

  /// `Please fill out all fields.`
  String get pleaseFillOutAllFields {
    return Intl.message(
      'Please fill out all fields.',
      name: 'pleaseFillOutAllFields',
      desc: '',
      args: [],
    );
  }

  /// `Set language`
  String get setLanguage {
    return Intl.message(
      'Set language',
      name: 'setLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Reply`
  String get reply {
    return Intl.message(
      'Reply',
      name: 'reply',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
