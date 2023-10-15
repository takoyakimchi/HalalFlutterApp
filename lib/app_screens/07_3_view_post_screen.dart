// ignore_for_file: use_build_context_synchronously
import 'package:first_flutter_app/app_screens/07_2_modify_post_screen.dart';
import 'package:first_flutter_app/classes/post_model.dart';
import 'package:flutter/material.dart';
import 'package:first_flutter_app/classes/firestore_dao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:first_flutter_app/app_screens/07_0_forum_screen.dart';
import 'package:first_flutter_app/classes/reply_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ViewPostScreen extends StatefulWidget {
  final String docId;

  ViewPostScreen({required this.docId, Key? key}) : super(key: key);

  final Post defaultPost = Post(
      postTitle: 'Loading...',
      author: '',
      dateTime: '',
      content: '',
      docPW: '');

  final Reply defaultReply =
      Reply(docId: '', author: '', dateTime: '', content: '', replyPW: '');

  @override
  _ViewPostScreenState createState() => _ViewPostScreenState();
}

class _ViewPostScreenState extends State<ViewPostScreen> {
  late Post post = widget.defaultPost;

  TextEditingController inputPWController = TextEditingController();
  String inputPW = "";

  TextEditingController contentController = TextEditingController();
  String content = "";

  TextEditingController replyPWController = TextEditingController();
  String replyPW = "";

  TextEditingController authorController = TextEditingController();
  String author = "";

  TextEditingController inputReplyPWController = TextEditingController();
  String inputReplyPW = "";

  DateTime now = DateTime.now();
  late String dateTimeNow = DateFormat('yyyyMMdd HH:mm:ss').format(now);
  late int rlen = 0; //댓글 갯수

  late var routeData;

  @override
  void initState() {
    super.initState();
  }

  Future<List<dynamic>> _loadData() async {
    dynamic p = await FireDAO.getOne("Posts", widget.docId);
    List<dynamic> r = await FireDAO.getList("Posts/${widget.docId}/Comments");

    rlen = r.length;
    return [p, r, rlen];
  }

  @override
  Widget build(BuildContext context) {
    const double leftRightPadding = 0.0;

    // 구분선 위젯 -> 여러 번 재사용
    const double dividerPadding = 20.0;
    Widget horizontalDividerLine = const Padding(
      padding: EdgeInsets.fromLTRB(0.0, dividerPadding, 0.0, dividerPadding),
      child: Divider(thickness: 1, height: 1, color: Colors.grey),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.board),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, post);
          return false;
        },
        child: FutureBuilder(
            future: _loadData(),
            builder: (context, snapshot) {
              if (snapshot.hasData == false) {
                return const Center(child: CircularProgressIndicator());
              }

              List<Widget> replyWidgetList = [];
              post = snapshot.data![0];
              List<dynamic> replyList = snapshot.data![1];
              rlen = snapshot.data![2]; // 댓글의 개수

              // 각각의 댓글을 반복
              for (int i = 0; i < rlen; i++) {
                String replyContent =
                    replyList[i].content ?? "No Content"; // 댓글 내용
                String dateTime = replyList[i].dateTime ??
                    "20200101 00:00:00"; // 댓글 날짜(DB 형식)
                String parsedDateTime = DateFormat('yyyy/MM/dd HH:mm')
                    .format(DateTime.parse(dateTime)); // 댓글 날짜 표시 형식
                String replyAuthor =
                    replyList[i].author ?? "Anonymous"; // 댓글 작성자
                String replyId = FireDAO.getId(replyList[i]); // 댓글의 DB 고유key

                // DB 기반으로 댓글 위젯을 동적으로 추가하기
                replyWidgetList.add(
                  SizedBox(
                    child: ListTile(
                      title: Text(replyContent,
                          style: const TextStyle(fontSize: 20)),
                      // 댓글 내용
                      subtitle: Text("$replyAuthor | $parsedDateTime"),
                      // 작성자와 날짜
                      trailing: GestureDetector(
                          onTap: () {
                            // 댓글 삭제 기능
                            showBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    alignment: Alignment.bottomCenter,
                                    height: 300,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(0),
                                          topRight: Radius.circular(0),
                                        )),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 140,
                                          height: 50,
                                          child: TextField(
                                            style:
                                                const TextStyle(fontSize: 15),
                                            obscureText: true,
                                            maxLength: 8,
                                            controller: inputReplyPWController,
                                            decoration: InputDecoration(
                                                border: const OutlineInputBorder(),
                                                hintText: AppLocalizations.of(context)!.password,
                                                hintStyle: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                                counterText: ''),
                                            onChanged: (value) {
                                              setState(() {
                                                inputReplyPW = value;
                                              });
                                            },
                                          ),
                                        ),

                                        //댓글 삭제하기
                                        ElevatedButton(
                                            onPressed: () async {

                                              // 비밀번호가 일치하지 않음
                                              if (inputReplyPW !=
                                                  replyList[i].replyPW) {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        content: Text(
                                                            AppLocalizations.of(context)!.wrongPassword),
                                                        actions: <Widget>[
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  AppLocalizations.of(context)!.check))
                                                        ],
                                                      );
                                                    });
                                              }
                                              // 비밀번호가 일치함
                                              else {
                                                FirebaseFirestore.instance
                                                    .collection(
                                                    "Posts/${widget.docId}/Comments")
                                                    .doc(replyId)
                                                    .delete();
                                                // Get.to(() => ViewPostScreen(
                                                //     do cId: widget.docId));
                                                Navigator.pop(
                                                    context); // Dismisses the modal
                                                FocusScope.of(context)
                                                    .unfocus();
                                              }
                                            },
                                            child: Text(AppLocalizations.of(context)!.delete))
                                      ],
                                    ),
                                  );
                                });
                          },
                          child: Icon(Icons.delete)),
                    ),
                  ),
                );

                // 각각의 댓글에 구분선 추가
                replyWidgetList.add(horizontalDividerLine);
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                  child: Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.fromLTRB(
                              leftRightPadding, 15.0, leftRightPadding, 10.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            post.postTitle.toString(),
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          )),

                      // 작성자와 작성 날짜
                      Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${post.author ?? ''} | ${DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(post.dateTime ?? ' '))}",
                            style: const TextStyle(fontSize: 15),
                          )),

                      // 구분선
                      const Padding(
                        padding: EdgeInsets.fromLTRB(
                            0.0, dividerPadding, 0.0, dividerPadding),
                        child: Divider(
                            thickness: 1, height: 1, color: Colors.grey),
                      ),

                      // 게시글 내용
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            post.content ?? '',
                            style: const TextStyle(fontSize: 18),
                          )),

                      // 구분선
                      horizontalDividerLine,

                      // 비밀번호
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            leftRightPadding, 0.0, leftRightPadding, 20.0),
                        child: TextField(
                          obscureText: true,
                          maxLength: 10,
                          controller: inputPWController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: AppLocalizations.of(context)!.password,
                              counterText: ''),
                          onChanged: (value) {
                            setState(() {
                              inputPW = value;
                            });
                          },
                        ),
                      ),

                      // 버튼Row: 삭제, 수정, Go To Forum
                      Row(
                        children: [
                          // 게시글 삭제
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                int passwordMatch = await FireDAO.deleteDoc(
                                    "Posts", widget.docId, inputPW);
                                // 비밀번호가 일치하지 않음
                                if (passwordMatch == 0) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Text(AppLocalizations.of(context)!.wrongPassword),
                                          actions: <Widget>[
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(AppLocalizations.of(context)!.check))
                                          ],
                                        );
                                      });
                                }
                                // 비밀번호가 일치함
                                if (passwordMatch == 1) {
                                  // Get.to(() => ForumScreen());
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text(AppLocalizations.of(context)!.delete),
                            ),
                          ),

                          // 게시물 수정
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (post.docPW == inputPW) {
                                  Post post = await FireDAO.getOne(
                                      "Posts", widget.docId);
                                  routeData = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdatePostScreen(
                                        docId: widget.docId,
                                        docPW: inputPW,
                                        temp: post,
                                      ),
                                    ),
                                  );
                                  setState(() {
                                    post.postTitle = routeData["postTitle"];
                                    post.content = routeData["content"];
                                    post.author = routeData["author"];
                                    post.dateTime = routeData["dateTime"];
                                  });
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Text(AppLocalizations.of(context)!.wrongPassword),
                                          actions: <Widget>[
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(AppLocalizations.of(context)!.check))
                                          ],
                                        );
                                      });
                                }
                              },
                              child: Text(AppLocalizations.of(context)!.update),
                            ),
                          ),

                          // 게시물 목록으로
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                            child: OutlinedButton(
                              onPressed: () async {
                                Get.to(() => ForumScreen());
                              },
                              child: Text(AppLocalizations.of(context)!.goToForum),
                            ),
                          ),
                        ],
                      ),

                      // 구분선
                      horizontalDividerLine,

                      ///
                      /// 댓글 시작
                      ///
                      // 라벨: 댓글
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)!.reply,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                      ),

                      // 댓글 TextField -> 작성자, 비밀번호
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 10.0),
                        child: Row(
                          children: [
                            // 작성자
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                  0.0, 0.0, 10.0, 0.0),
                              width: 160,
                              height: 50,
                              child: TextField(
                                style: const TextStyle(fontSize: 15),
                                maxLength: 10,
                                controller: authorController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: AppLocalizations.of(context)!.author,
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                  ),
                                  counterText: '',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    author = value;
                                  });
                                },
                              ),
                            ),

                            // 비밀번호
                            Container(
                              width: 140,
                              height: 50,
                              child: TextField(
                                style: const TextStyle(fontSize: 15),
                                obscureText: true,
                                maxLength: 8,
                                controller: replyPWController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: AppLocalizations.of(context)!.password,
                                    hintStyle: TextStyle(
                                      fontSize: 15,
                                    ),
                                    counterText: ''),
                                onChanged: (value) {
                                  setState(() {
                                    replyPW = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 댓글 내용
                      TextField(
                        style: const TextStyle(fontSize: 15),
                        textAlignVertical: TextAlignVertical.top,
                        // maxLength: 50,
                        maxLines: 3,
                        controller: contentController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: AppLocalizations.of(context)!.content,
                        ),
                        onChanged: (value) {
                          setState(() {
                            content = value;
                          });
                        },
                      ),

                      // 댓글 등록
                      ElevatedButton(
                          onPressed: () async {
                            Map<String, dynamic> data = {
                              "docId": widget.docId,
                              "author": author,
                              "content": content,
                              "dateTime": dateTimeNow,
                              "replyPW": replyPW,
                            };
                            // int e = await FireDAO.createDoc("Reply", data);
                            await FireDAO.createReply(widget.docId, data);
                            setState(() {
                              contentController.text = '';
                              authorController.text = '';
                              replyPWController.text = '';
                            });
                            print(data);
                          },
                          child: const Text("Reply Upload")),

                      Column(
                        children: replyWidgetList,
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
