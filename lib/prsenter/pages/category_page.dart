import 'package:flutter/material.dart';
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
            Text('カテゴリー: ${widget.goal.categories.join(', ')}'),
            Text('完了予定日: ${widget.goal.dueDate != null ? DateFormat('yyyy/MM/dd').format(widget.goal.dueDate!) : 'なし'}'),
            Text('コメント: ${widget.goal.comment ?? 'なし'}'),
            Text('作成者: ${widget.goal.userName ?? '不明'}'),
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
                // コメントをFirestoreに保存
                await FirestoreService().addCommentToGoal(
                  widget.goal.id,
                  commentController.text,
                  // ログインユーザーのユーザー名を使用するか、任意の方法で取得してください
                  widget.goal.userName ?? 'ユーザー名', // ここを修正
                );
                // コメントを追加後、入力フィールドをクリア
                commentController.clear();
              },
              child: Text('コメントを追加'),
            ),
            SizedBox(height: 16),
            Text('コメント一覧:'),
            StreamBuilder<List<Comment>>(
              stream: FirestoreService().getCommentsForGoal(widget.goal.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('エラーが発生しました: ${snapshot.error}');
                } else if (snapshot.data?.isEmpty ?? true) {
                  return Text('コメントはまだありません。');
                } else {
                  final comments = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return ListTile(
                        title: Text(comment.userName),
                        subtitle: Text(comment.commentText),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                // コメントの削除を実装
                                await FirestoreService().deleteComment(widget.goal.id, comment.id);
                              },
                              child: Text('削除'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // 編集ダイアログや画面遷移を表示
                                // 編集が完了したらFirestoreに保存
                              },
                              child: Text('編集'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_app/prsenter/pages/todo_list_page.dart'; // GoalItem クラスのインポート
// import 'package:intl/intl.dart';

// class WorkCategoryPage extends StatefulWidget {
//   final String category;
//   WorkCategoryPage({required this.category});

//   @override
//   _WorkCategoryPageState createState() => _WorkCategoryPageState();
// }

// class _WorkCategoryPageState extends State<WorkCategoryPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.category),
//       ),
//       body: StreamBuilder<List<GoalItem>>(
//         stream: FirestoreService().getGoalsByCategory(widget.category),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             final goals = snapshot.data!;
//             return ListView.builder(
//               itemCount: goals.length,
//               itemBuilder: (context, index) {
//                 final goal = goals[index];
//                 return ListTile(
//                   title: Text(goal.title),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('カテゴリー: ${goal.categories.join(', ')}'),
//                       Text('完了予定日: ${goal.dueDate != null ? DateFormat('yyyy/MM/dd').format(goal.dueDate!) : 'なし'}'),
//                       Text('コメント: ${goal.comment ?? 'なし'}'),
//                       Text('作成者: ${goal.userName ?? '不明'}'),// 作成者の表示
//                     ],
//                   ),
//                   onTap: () {
//                     // タップしたら目標の詳細ページに遷移
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => GoalDetailPage(goal: goal),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           } else if (snapshot.hasError) {
//             return Text('エラーが発生しました！');
//           } else {
//             return CircularProgressIndicator();
//           }
//         },
//       ),
//     );
//   }
// }

// class GoalDetailPage extends StatefulWidget {
//   final GoalItem goal;
//   GoalDetailPage({required this.goal});

//   @override
//   _GoalDetailPageState createState() => _GoalDetailPageState();
// }

// class _GoalDetailPageState extends State<GoalDetailPage> {
//   final TextEditingController commentController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.goal.title),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('カテゴリー: ${widget.goal.categories.join(', ')}'),
//             Text('完了予定日: ${widget.goal.dueDate != null ? DateFormat('yyyy/MM/dd').format(widget.goal.dueDate!) : 'なし'}'),
//             Text('コメント: ${widget.goal.comment ?? 'なし'}'),
//             Text('作成者: ${widget.goal.userName ?? '不明'}'),
//             SizedBox(height: 16),
//             Text('コメントを追加:'),
//             TextField(
//               controller: commentController,
//               decoration: InputDecoration(
//                 hintText: 'コメントを入力...',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 // コメントをFirestoreに保存
//                 await FirestoreService().addCommentToGoal(
//                   widget.goal.id,
//                   commentController.text,
//                   // ユーザー名をここで指定
//                   // ログインユーザーのユーザー名を使用するか、任意の方法で取得してください
//                   'ユーザー名', 
//                 );
//                 // コメントを追加後、入力フィールドをクリア
//                 commentController.clear();
//               },
//               child: Text('コメントを追加'),
//             ),
//             SizedBox(height: 16),
//             Text('コメント一覧:'),
//             StreamBuilder<List<Comment>>(
//             stream: FirestoreService().getCommentsForGoal(widget.goal.id),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return CircularProgressIndicator();
//               } else if (snapshot.hasError) {
//                 return Text('エラーが発生しました: ${snapshot.error}'); // エラーメッセージを詳細に表示
//               } else if (snapshot.data?.isEmpty ?? true) {
//                 return Text('コメントはまだありません。');
//               } else {
//                 final comments = snapshot.data!;
//                 return ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: comments.length,
//                   itemBuilder: (context, index) {
//                     final comment = comments[index];
//                     return ListTile(
//                       title: Text(comment.userName),
//                       subtitle: Text(comment.commentText),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () async {
//                               // コメントの削除を実装
//                               await FirestoreService().deleteComment(widget.goal.id, comment.id);
//                             },
//                             child: Text('削除'),
//                           ),
//                           ElevatedButton(
//                             onPressed: () {
//                               // 編集ダイアログや画面遷移を表示
//                               // 編集が完了したらFirestoreに保存
//                             },
//                             child: Text('編集'),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               }
//             },
//           )
//           ],
//         ),
//       ),
//     );
//   }
// }
