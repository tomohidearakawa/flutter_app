import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_app/prsenter/pages/todo_list_page.dart'; // GoalItem クラスのインポート
import 'package:intl/intl.dart';

class WorkCategoryPage extends StatefulWidget {
  final String category;
  WorkCategoryPage({required this.category});

  @override
  _WorkCategoryPageState createState() => _WorkCategoryPageState();
}

class _WorkCategoryPageState extends State<WorkCategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: StreamBuilder<List<GoalItem>>(
        stream: FirestoreService().getGoalsByCategory(widget.category),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final goals = snapshot.data!;
            return ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return ListTile(
                  title: Text(goal.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('カテゴリー: ${goal.categories.join(', ')}'),
                      Text('完了予定日: ${goal.dueDate != null ? DateFormat('yyyy/MM/dd').format(goal.dueDate!) : 'なし'}'),
                      Text('コメント: ${goal.comment ?? 'なし'}'),
                      Text('作成者: ${goal.userName ?? '不明'}'), // 作成者の表示
                    ],
                  ),
                  onTap: () {
                    // タップしたら目標の詳細ページに遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GoalDetailPage(goal: goal),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('エラーが発生しました: ${snapshot.error}');
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class GoalDetailPage extends StatefulWidget {
  final GoalItem goal;
  GoalDetailPage({required this.goal});

  @override
  _GoalDetailPageState createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> {
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 目標の詳細情報を表示
            Text('カテゴリー: ${widget.goal.categories.join(', ')}'),
            Text('完了予定日: ${widget.goal.dueDate != null ? DateFormat('yyyy/MM/dd').format(widget.goal.dueDate!) : 'なし'}'),
            Text('コメント: ${widget.goal.comment ?? 'なし'}'),
            Text('作成者: ${widget.goal.userName ?? '不明'}'),

            // コメント追加フォーム
            SizedBox(height: 16),
            Text('コメントを追加:'),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'コメントを入力...',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // FirebaseAuthから現在のユーザーを取得
                final currentUser = FirebaseAuth.instance.currentUser;
                final userName = currentUser != null ? currentUser.displayName ?? '匿名ユーザー' : '匿名ユーザー';
                // コメントをFirestoreに保存
                await FirestoreService().addCommentToGoal(
                  widget.goal.id,
                  commentController.text,
                  userName, // 現在のユーザー名を使用
                );
                // コメント追加後、入力フィールドをクリア
                commentController.clear();
              },
              child: Text('コメントを追加'),
            ),

            // コメントリスト
            Expanded(
              child: StreamBuilder<List<Comment>>(
                stream: FirestoreService().getCommentsForGoal(widget.goal.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('エラーが発生しました: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final comments = snapshot.data!;
                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return ListTile(
                          title: Text(comment.userName),
                          subtitle: Linkify(
                            onOpen: (link) async {
                              if (await canLaunch(link.url)) {
                                await launch(link.url);
                              } else {
                                print('Could not launch ${link.url}');
                              }
                            },
                            text: comment.commentText,
                            style: TextStyle(color: Colors.black),
                            linkStyle: TextStyle(color: Colors.blue),
                          ),
                          trailing: Text(DateFormat('yyyy/MM/dd HH:mm').format(comment.timestamp)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CommentDetailPage(comment: comment),
                              ),
                            );
                          },
                        );
                      },
                    );
                  } else {
                    return Text('コメントはまだありません。');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentDetailPage extends StatelessWidget {
  final Comment comment;

  CommentDetailPage({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('コメント詳細'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('ユーザー名: ${comment.userName}'),
            SizedBox(height: 8.0),
            Text('コメント: ${comment.commentText}'),
            SizedBox(height: 8.0),
            Text('投稿日時: ${DateFormat('yyyy/MM/dd HH:mm').format(comment.timestamp)}'),
          ],
        ),
      ),
    );
  }
}

