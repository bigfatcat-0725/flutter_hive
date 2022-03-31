import 'package:flutter/material.dart';
import 'package:flutter_hive/hive_helper.dart';
import 'package:flutter_hive/task.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await HiveHelper().openBox();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Hive',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future _showMyDialog() async {
    return showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('New Task'),
            content: TextField(
              autofocus: true,
              onSubmitted: (String text) {
                setState(() {
                  HiveHelper().create(Task(text));
                });
                Navigator.of(context).pop();
              },
              textInputAction: TextInputAction.send,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
        future: HiveHelper().read(),
        builder: (context, snapshot) {
          List<Task> _tasks = snapshot.data ?? [];

          return Scaffold(
            appBar: AppBar(
              title: Text('To do'),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _showMyDialog();
              },
              child: Icon(Icons.add),
            ),
            // 누르고 드래그해서 리스트를 옮길수 있는 리스트 위젯
            body: ReorderableListView(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              proxyDecorator:
                  (Widget child, int index, Animation<double> animation) {
                return TaskTile(
                  task: _tasks[index],
                  onDeleted: () {},
                );
              },
              children: [
                for (int index = 0; index < _tasks.length; index++)
                  Padding(
                    key: Key('$index'),
                    padding: EdgeInsets.all(8),
                    child: TaskTile(
                      task: _tasks[index],
                      onDeleted: () {
                        setState(() {});
                      },
                    ),
                  )
              ],
              onReorder: (int oldIndex, int newIndex) async {
                if (oldIndex < newIndex) {
                  newIndex--;
                }
                await HiveHelper().reorder(oldIndex, newIndex);
                setState(() {});
              },
            ),
          );
        });
  }
}

class TaskTile extends StatefulWidget {
  const TaskTile({Key? key, required this.task, required this.onDeleted})
      : super(key: key);
  final Task task;
  final Function onDeleted;

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color evenItemColor = colorScheme.primary;
    return Material(
      child: AnimatedContainer(
        constraints: BoxConstraints(minHeight: 60),
        alignment: Alignment.center,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: widget.task.finished ? Colors.grey : evenItemColor,
            borderRadius: BorderRadius.circular(12)),
        duration: Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        child: Row(
          children: [
            Checkbox(
                value: widget.task.finished,
                onChanged: (checked) {
                  widget.task.finished = checked!;
                  widget.task.save();
                  setState(() {
                    widget.task.finished = checked;
                  });
                }),
            Expanded(
              child: Text(
                widget.task.title,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  decoration: widget.task.finished
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                widget.task.delete();
                widget.onDeleted();
              },
              icon: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
