import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:first_flutter_app/classes/firestore_dao.dart';
import 'package:first_flutter_app/classes/post_model.dart';

class UpdatePostScreen extends StatefulWidget {
  final String docId;
  final String docPW;
  final Post temp;

  const UpdatePostScreen(
      {required this.docId, required this.docPW, required this.temp, Key? key})
      : super(key: key);

  @override
  UpdatePostScreenState createState() => UpdatePostScreenState();
}

class UpdatePostScreenState extends State<UpdatePostScreen> {
  TextEditingController titleController = TextEditingController();
  String? postTitle = '';

  TextEditingController contentController = TextEditingController();
  String? content = "";

  TextEditingController authorController = TextEditingController();
  String? author = "";

  TextEditingController docPWController = TextEditingController();
  String? docPW = "";

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late BuildContext _myContext;

  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.temp.postTitle);
    authorController = TextEditingController(text: widget.temp.author);
    docPWController = TextEditingController(text: widget.temp.docPW);
    contentController = TextEditingController(text: widget.temp.content);
    postTitle = widget.temp.postTitle;
    author = widget.temp.author;
    docPW = widget.temp.docPW;
    content = widget.temp.content;
    _myContext = context;
  }

  DateTime now = DateTime.now();
  late String dateTimeNow = DateFormat('yyyyMMdd HH:mm:ss').format(now);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.update),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 제목을 입력하는 필드
              TextField(
                maxLength: 50,
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
              //작성자 입력 필드
              TextField(
                maxLength: 10,
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
              TextField(
                maxLength: 4,
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

              // 내용을 입력하는 필드
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.content,
                ),
                maxLines: 10,
                onChanged: (value) {
                  setState(() {
                    content = value;
                  });
                },
              ),
              Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      Map<String, dynamic> data = {
                        "postTitle": postTitle,
                        "author": author,
                        "content": content,
                        "dateTime": dateTimeNow,
                        "docPW": docPW,
                      };
                      int e = await FireDAO.updateDoc(
                        "Posts",
                        widget.docId,
                        widget.docPW,
                        data,
                      );

                      if (e == 1) {
                        Navigator.pop(_myContext, data);
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.update),
                  );
                },
              )

              //Updated by DAO 아직 미구현
            ],
          ),
        ));
  }
}
