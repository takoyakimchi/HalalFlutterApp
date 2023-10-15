import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:first_flutter_app/classes/firestore_dao.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../classes/post_model.dart';

class MakePostScreen extends StatefulWidget {
  const MakePostScreen({super.key});

  @override
  MakePostScreenState createState() => MakePostScreenState();
}

class MakePostScreenState extends State<MakePostScreen> {
  TextEditingController titleController = TextEditingController();
  String postTitle = '';

  TextEditingController contentController = TextEditingController();
  String content = "";

  TextEditingController authorController = TextEditingController();
  String author = "";

  TextEditingController docPWController = TextEditingController();
  String docPW = "";

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    SizedBox paddingBox = const SizedBox(height: 20.0);

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.postUpload),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                /// 제목을 입력하는 필드
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: AppLocalizations.of(context)!.title,
                  ),
                  onChanged: (value) {
                    setState(() {
                      postTitle = value;
                    });
                  },
                ),
                paddingBox,

                /// 작성자 입력 필드
                TextField(
                  controller: authorController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: AppLocalizations.of(context)!.author,
                  ),
                  onChanged: (value) {
                    setState(() {
                      author = value;
                    });
                  },
                ),
                paddingBox,

                /// 비밀번호 입력 필드
                TextField(
                  obscureText: true,
                  controller: docPWController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: AppLocalizations.of(context)!.password,
                  ),
                  onChanged: (value) {
                    setState(() {
                      docPW = value;
                    });
                  },
                ),
                paddingBox,

                /// 내용 - 라벨
                // Align(
                //   alignment: Alignment.centerLeft,
                //   child: Text(
                //     AppLocalizations.of(context)!.content,
                //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                //   ),
                // ),
                // paddingBox,

                /// 내용 입력 필드
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    label: Text(AppLocalizations.of(context)!.content),
                  ),
                  maxLines: 10,
                  onChanged: (value) {
                    setState(() {
                      content = value;
                    });
                  },
                ),
                paddingBox,

                // 업로드하기
                ElevatedButton(
                    onPressed: () async {
                      if(postTitle == "" || author == "" || docPW == "" || content == "") {
                        await showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                content: Text(AppLocalizations.of(context)!.pleaseFillOutAllFields),
                                actions: [
                                  TextButton(onPressed: () {
                                    Navigator.of(context).pop();
                                  }, child: Text("OK"))
                                ]
                              );
                            }
                        );
                        return;
                      }

                      // 업로드할 데이터 맵 구성
                      Map<String, dynamic> data = {
                        "postTitle": postTitle,
                        "author": author,
                        "content": content,
                        "dateTime": DateFormat('yyyyMMdd HH:mm:ss').format(DateTime.now()),
                        "docPW": docPW,
                      };

                      // 이전 화면에 전달할 객체 구성
                      Post newPost = Post(
                        postTitle: postTitle,
                        author: author,
                        content: content,
                        dateTime: data['dateTime'],
                        docPW: docPW
                      );

                      await FireDAO.createDoc("Posts", data); // DB에 업로드

                      if (!mounted) {
                        return;
                      }

                      Navigator.pop(context, newPost);
                    },
                    child: Text(AppLocalizations.of(context)!.upload)),
              ],
            ),
          ),
        ));
  }
}
