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
        title: Text(widget.category), // カテゴリー名を表示
      ),
      body: StreamBuilder<List<GoalItem>>(
        stream: FirestoreService().getGoalsByCategory(widget.category), // カテゴリーごとの目標を取得するストリーム
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final goals = snapshot.data!;
            return ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return ListTile(
                  title: Text(goal.title),
                  subtitle: Text(
                    'カテゴリー: ${goal.categories.join(', ')}\n' +
                        '完了予定日: ${goal.dueDate != null ? DateFormat('yyyy/MM/dd').format(goal.dueDate!) : 'なし'}\n' +
                        'コメント: ${goal.comment ?? 'なし'}',
                  ),
                  // 他の情報をここに追加...
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('エラーが発生しました！');
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}


class StudyCategoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('勉強カテゴリー'),
      ),
      // 勉強カテゴリーのコンテンツをここに追加
    );
  }
}

// 他のカテゴリーページも同様に作成


// class CategoryPage extends StatefulWidget {
//   final String category;
//   CategoryPage({required this.category});

//   @override
//   _CategoryPageState createState() => _CategoryPageState();
// }

// class _CategoryPageState extends State<CategoryPage> {
//   List<GoalItem> goals = []; // カテゴリーごとの目標を格納するリスト

//   @override
//   void initState() {
//     super.initState();
//     // カテゴリーに関連する目標を取得し、リストに格納
//     _loadGoals();
//   }

//   // カテゴリーに関連する目標を取得するメソッド
//   void _loadGoals() async {
//     final loadedGoals = await FirestoreService().getGoalsByCategory(widget.category);
//     setState(() {
//       goals = loadedGoals;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('カテゴリー: ${widget.category}'),
//       ),
//       body: ListView.builder(
//         itemCount: goals.length,
//         itemBuilder: (context, index) {
//           final goal = goals[index];
//           return ListTile(
//             title: Text(goal.title),
//             subtitle: Text('完了予定日: ${goal.dueDate ?? '未設定'}'), // 必要に応じて表示情報をカスタマイズ
//             onTap: () {
//               // タップしたら目標の詳細ページに遷移
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => GoalDetailPage(goal: goal), // GoalDetailPage は目標の詳細ページのクラスです
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
