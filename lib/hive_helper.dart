import 'package:flutter_hive/task.dart';
import 'package:hive/hive.dart';

const String TASK_BOX = 'TASK_BOX';

class HiveHelper {
  static final HiveHelper _singleton = HiveHelper._internal();
  factory HiveHelper() {
    return _singleton;
  }
  HiveHelper._internal();

  Box<Task>? taskBox;

  Future reorder(int oldIndex, int newIndex) async {
    List<Task> newList = [];
    newList.addAll(taskBox!.values);

    final Task item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    await taskBox!.clear();
    await taskBox!.addAll(newList);
    return;
  }

  Future openBox() async {
    taskBox = await Hive.openBox(TASK_BOX);
  }

  Future create(Task newTask) async {
    return taskBox!.add(newTask);
  }

  Future<List<Task>> read() async {
    return taskBox!.values.toList();
  }

  Future update(int index, Task updatedTask) async {
    taskBox!.putAt(index, updatedTask);
  }

  Future delete(int index) async {
    taskBox!.deleteAt(index);
  }
}
