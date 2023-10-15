import 'package:flutter/material.dart';
import 'package:first_flutter_app/app_screens/07_1_make_post_screen.dart';
import 'package:first_flutter_app/app_screens/07_3_view_post_screen.dart';
import 'package:first_flutter_app/classes/firestore_dao.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForumScreen extends StatefulWidget {
  var selectedLanguage;
  var onLanguageChanged;

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  List<dynamic> postList = [];

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    postList = await FireDAO.getList("Posts");
    setState(() {}); // Trigger a rebuild after data is loaded
  }

  @override
  Widget build(BuildContext context) {
    // 동적으로 처리하는 게시물들의 위젯 리스트
    List<Widget> postWidgetList = [];

    // DB에서 불러온 게시글을 바탕으로 위젯 하나씩 채우기
    for (int i = 0; i < postList.length; i++) {
      // DB에 맞게 동적으로 위젯 추가
      postWidgetList.add(
        GestureDetector(
          // 이벤트 핸들러
          onTap: () async {
            String id = FireDAO.getId(postList[i]); // 게시글의 DB 고유 ID

            // 게시글을 클릭하면 ViewPostScreen으로 이동
            dynamic post = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewPostScreen(docId: id)
              )
            );

            // 게시글에서 밖으로 나왔을 때의 처리
            setState(() {
              _loadPost();
              // postList[i].postTitle = post.postTitle;
              // postList[i].author = post.author;
              // postList[i].dateTime = post.dateTime;
            });
          },
          
          // 뷰
          child: SizedBox(
            child: Card(
              child: ListTile(
                title: Text(postList[i].postTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                subtitle: Text("${postList[i].author} | ${DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(postList[i].dateTime))}"),
              )
            ),
          ),
        ),

      );
    }

    /// 위젯 시작
    return Scaffold(
      // 상단 바
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.forum),
      ),

      // 게시글의 목록을 dynamic하게 보여줌
      body: ListView(
        padding: EdgeInsets.all(10.0),
        scrollDirection: Axis.vertical,
        children: postWidgetList
      ),

      // 우측 하단 게시글 작성 버튼
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MakePostScreen()
                )
            );
            await _loadPost();
          },
          tooltip: AppLocalizations.of(context)!.makePost,
          child: Icon(Icons.add)
      ),
    );
  }
}
