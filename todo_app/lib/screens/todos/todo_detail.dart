import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/api_service.dart';
import 'package:todo_app/screens/todos/update_todo.dart'; // Import the UpdateTaskScreen
import 'package:todo_app/widgets/custom_scaffold.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  TaskDetailScreen({required this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _updateTaskCompletion(bool isCompleted) async {
    try {
      // Update the task's completion status
      await ApiService.updateTask(
        _task.copyWith(completed: isCompleted),
      );

      setState(() {
        _task.completed = isCompleted;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task updated successfully'),
        backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task'),
        backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteTask() async {
    bool success = await ApiService.deleteTask(_task.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task deleted successfully'),
        backgroundColor: Colors.blue,
        ),
      );
      Navigator.pop(context, true); // Notify the previous screen about the deletion
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task'),
      backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
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
        title: null,  // Set title to null to use flexibleSpace for centering
        flexibleSpace: Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Task ',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: 'Details',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.normal,
                    color: Colors.blue,  // Change the color for part of the text
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteTask,
          ),
        ],
      ),

      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 4.0,
            child: Padding(
              padding: EdgeInsets.all(1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    child: Card(
                      color: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4.0,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Title:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 6.0),
                            Text(
                              _task.title,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Description:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              _task.description ?? 'No description',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Date Created:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              _task.dateCreated.toLocal().toString().split(' ')[0], // Show date only
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Due Date:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              _task.dueDate.toLocal().toString().split(' ')[0], // Show date only
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 16.0),
                            CheckboxListTile(
                              title: Text('Completed'),
                              value: _task.completed,
                              onChanged: (bool? value) {
                                if (value != null) {
                                  _updateTaskCompletion(value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    width: double.infinity,
                    child: Card(
                      color: Colors.blue.shade50,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 2.0,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                // Navigate to update task screen
                                final updatedTask = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateTaskScreen(task: _task),
                                  ),
                                );

                                if (updatedTask != null && updatedTask is Task) {
                                  setState(() {
                                    _task = updatedTask;
                                  });
                                } else if (updatedTask == true) {
                                  Navigator.pop(context, true); // Task was deleted, go back to To-Do List screen
                                }
                              },
                              child: Text('Edit Task'),
                              style: ElevatedButton.styleFrom(
                                iconColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
