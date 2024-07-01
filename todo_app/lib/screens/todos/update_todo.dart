import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/api_service.dart';
import 'package:todo_app/widgets/custom_scaffold.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class UpdateTaskScreen extends StatefulWidget {
  final Task task;

  UpdateTaskScreen({required this.task});

  @override
  _UpdateTaskScreenState createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late bool _completed;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _dueDate = widget.task.dueDate;
    _completed = widget.task.completed;
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        Task updatedTask = Task(
          id: widget.task.id,
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          completed: _completed,
          dueDate: _dueDate,
          dateCreated: widget.task.dateCreated, // Ensure dateCreated is included
        );

        await ApiService.updateTask(updatedTask);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task updated successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate a successful update
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task')),
        );
      }
    }
  }

  Future<void> _deleteTask() async {
    bool success = await ApiService.deleteTask(widget.task.id);
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
                  text: 'Update ',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: 'Task',
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
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 4.0,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the task title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the task description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Due Date: ${_dueDate.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (selectedDate != null && selectedDate != _dueDate) {
                        setState(() {
                          _dueDate = selectedDate;
                        });
                      }
                    },
                    child: Text('Select Due Date'),
                    style: ElevatedButton.styleFrom(
                      iconColor: Colors.blue,  // Background color
                      foregroundColor: Colors.blue,  // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  CheckboxListTile(
                    title: Text('Completed'),
                    value: _completed,
                    onChanged: (bool? value) {
                      setState(() {
                        _completed = value ?? false;
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateTask,
                      child: Text('Update Task'),
                      style: ElevatedButton.styleFrom(
                        iconColor: Colors.blue,  // Background color
                        foregroundColor: Colors.blue,  // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.0),
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
