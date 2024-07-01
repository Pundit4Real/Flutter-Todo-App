import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/api_service.dart';
import 'package:todo_app/screens/todos/todo_detail.dart';
import 'package:todo_app/screens/todos/create_todo.dart';
import 'package:todo_app/widgets/custom_scaffold.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<List<Task>> _taskList;
  late List<Task> _filteredTaskList;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _taskList = ApiService.fetchTasks();
      _taskList.then((tasks) {
        setState(() {
          _filteredTaskList = tasks;
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      });
    });
  }

  void _navigateToAddTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTaskScreen()),
    );
    if (result == true) {
      _fetchTasks(); // Refresh the task list after adding a new task
    }
  }

  void _navigateToTaskDetail(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
    );
    if (result == true) {
      _fetchTasks(); // Refresh the task list after a task is deleted
    }
  }

  void _deleteTask(int taskId) async {
    bool success = await ApiService.deleteTask(taskId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task deleted successfully'),
          backgroundColor: Colors.blue,
        ),
      );
      _fetchTasks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete task'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterTasks(String query) {
    if (query.isEmpty) {
      _taskList.then((tasks) {
        setState(() {
          _filteredTaskList = tasks;
        });
      });
    } else {
      setState(() {
        _filteredTaskList = _filteredTaskList
            .where((task) =>
                task.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4.0,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: Checkbox(
          value: task.completed,
          onChanged: (bool? value) {
            if (value != null) {
              setState(() {
                task.completed = value;
              });
              ApiService.updateTask(task);
            }
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text:
                    'Description: ${task.description != null && task.description!.length > 10 ? task.description!.substring(0, 10) + '...' : task.description}\n',
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextSpan(
                text: 'Due: ${task.dueDate.toLocal().toString().split(' ')[0]}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteTask(task.id),
        ),
        onTap: () => _navigateToTaskDetail(task),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Feather.chevron_left,
          size: 30,
        ),
        color: Colors.blue,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.black38),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
              onChanged: _filterTasks,
            )
          : Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'To-Do ',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'List',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.normal,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _filterTasks('');
              }
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.blue),
          onPressed: () {
            _fetchTasks(); // Call the method to refresh the task list
          },
        ),
      ],
      elevation: 0,
      backgroundColor: Colors.white60, // Set AppBar background color
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: _buildAppBar(),
      child: RefreshIndicator(
        onRefresh: _fetchTasks,
        child: FutureBuilder<List<Task>>(
          future: _taskList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Failed to load tasks: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No tasks available'));
            } else {
              return ListView.builder(
                itemCount: _filteredTaskList.length,
                itemBuilder: (context, index) {
                  return _buildTaskCard(_filteredTaskList[index]);
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: Container(
        height: 50.0,
        width: 50.0,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: _navigateToAddTask,
            child: Icon(Icons.add, color: Colors.blue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
