import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_todo_list/models/task_model.dart';
import 'package:flutter_todo_list/helpers/database_helper.dart';


class AddTaskScreen extends StatefulWidget {

  final Function updateTaskList;
  final Task task;
  
  // Constructor Function
  AddTaskScreen({this.updateTaskList, this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {

  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _priority;
  DateTime _date = DateTime.now();
  TextEditingController _dateController = TextEditingController();

  final DateFormat _dateFormatter = DateFormat('dd-MM-yyyy');
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _title = widget.task.title;
      _date = widget.task.date;
      _priority = widget.task.priority;
    }

    _dateController.text = _dateFormatter.format(_date);
  }
  
  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  _handleDatePicker() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date);
    }
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('$_title, $_date, $_priority');

      // Insert the task to our user database
      Task task = Task(
        title: _title,
        date: _date,
        priority: _priority
      );
      if (widget.task == null) {
        task.status = 0;
        DatabaseHelper.instance.insertTask(task);
      }
      else {
        task.status = widget.task.status;
        DatabaseHelper.instance.updateTask(task);
      }

      widget.updateTaskList();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                  SizedBox(height: 20,),

                  Text(
                    'Add Task',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10,),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: TextFormField(
                            style: TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: TextStyle(fontSize: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (input) => input.trim().isEmpty ? 'Please enter a task title' : null,
                            onSaved: (input) => _title = input,
                            initialValue: _title,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: TextFormField(
                            readOnly: true,
                            controller: _dateController,
                            style: TextStyle(fontSize: 18),
                            onTap: _handleDatePicker,
                            decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle: TextStyle(fontSize: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: DropdownButtonFormField(
                            isDense: true,
                            icon: Icon(Icons.arrow_drop_down_circle),
                            iconSize: 22.0,
                            iconEnabledColor: Theme.of(context).primaryColor,
                            items: _priorities.map((String priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Text(
                                  priority,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0
                                  ),
                                ),
                              );
                            }).toList(),
                            style: TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              labelStyle: TextStyle(fontSize: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (input) => _priority == null ? 'Please select a priority level' : null, 
                            onChanged: (value) {
                              setState(() {
                                _priority = value;
                              });
                            },
                            value: _priority,
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: FlatButton(
                            child: Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            onPressed: _submit,
                          ),
                        ),

                      ],
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