import 'package:flutter/material.dart';
import 'package:todo_master/models/task.dart';
import 'package:todo_master/services/api_service.dart';

class DeleteTaskScreen extends StatelessWidget {
  final Task task;

  DeleteTaskScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Are you sure you want to delete the task: ${task.title}?'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  bool success = await ApiService.deleteTask(task.id);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Task deleted successfully')),
                    );
                    Navigator.pop(context, true); // Notify the previous screen about the deletion
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete task')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: Text('Delete Task'),
              style: ElevatedButton.styleFrom(
                iconColor: Colors.red, // Red button for delete action
              ),
            ),
          ],
        ),
      ),
    );
  }
}
