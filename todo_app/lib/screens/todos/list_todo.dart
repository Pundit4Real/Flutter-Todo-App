import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:todo_master/models/task.dart';
import 'package:todo_master/services/api_service.dart';
import 'package:todo_master/screens/todos/todo_detail.dart';
import 'package:todo_master/screens/todos/create_todo.dart';
import 'package:todo_master/screens/profile/profile.dart';
import 'package:todo_master/widgets/custom_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token'); // Remove the access token from SharedPreferences
    Navigator.of(context).pushReplacementNamed('/login'); // Navigate to login screen
  }

  Widget _buildTaskCard(Task task, int index) {
    return Card(
      key: ValueKey(task.id),
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
      automaticallyImplyLeading: false, // Remove the back button from the app bar
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
          icon: Icon(Icons.logout, color: Colors.red),
          onPressed: () {
            _logout(); // Call the logout method
          },
        ),
      ],
      elevation: 0,
      backgroundColor: Colors.white60,
    );
  }

  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 1) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProfileScreen()), // Navigate to profile screen
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: CustomScaffold(
        appBar: _buildAppBar(),
        child: RefreshIndicator(
          onRefresh: _fetchTasks,
          child: FutureBuilder<List<Task>>(
            future: _taskList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SpinKitFadingCircle(
                    color: Colors.blue, // Set the color of the SpinKit icon
                    size: 50.0,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Failed to load tasks: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No tasks available'));
              } else {
                return ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final Task task = _filteredTaskList.removeAt(oldIndex);
                      _filteredTaskList.insert(newIndex, task);
                    });
                  },
                  children: [
                    for (int index = 0; index < _filteredTaskList.length; index++)
                      _buildTaskCard(_filteredTaskList[index], index)
                  ],
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
