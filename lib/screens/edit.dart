// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import '../helper/snack_bar_helper.dart';
import '../models/note.dart';
import '../provider/api_service.dart';

class EditScreen extends StatefulWidget {
  final Note? note;
  const EditScreen({super.key, this.note});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  bool _addingTodo = false;

  final _apiService = ApiService();
  @override
  void initState() {
    if (widget.note != null) {
      _titleController = TextEditingController(text: widget.note!.title);
      _contentController = TextEditingController(text: widget.note!.content);
    }

    super.initState();
  }

  Future<void> _addToDoItem() async {
    if (_titleController.text.isEmpty || _titleController.text == "") {
      showErrorMessage("Please Enter Note Title", context);
      return;
    }
    if (_contentController.text.isEmpty || _contentController.text == "") {
      showErrorMessage("Please Enter Note Content", context);
      return;
    }

    try {
      setState(() {
        _addingTodo = true;
      });
      final newToDo = await _apiService.addNewToDo(
          _titleController.text.trim(), _contentController.text.trim());
      setState(() {
        _addingTodo = false; // Hide loading indicator
      });
      showSuccessMessage('Todo added successfully', context);
      Navigator.pop(
        context,
        Note(
          id: newToDo.id,
          title: newToDo.title,
          content: newToDo.content,
          modifiedTime: newToDo
              .modifiedTime, // You may need to adjust this based on your requirements
        ),
      );
    } catch (e) {
      // Handle error, show an error message or log the error
      showErrorMessage('Failed to add todo: $e', context);
    } finally {
      setState(() {
        _addingTodo = false;
      });
    }
  }

  Future<void> _editToDoItem() async {
    if (_titleController.text.isEmpty || _titleController.text == "") {
      showErrorMessage("Please Enter Note Title", context);
      return;
    }
    if (_contentController.text.isEmpty || _contentController.text == "") {
      showErrorMessage("Please Enter Note Content", context);
      return;
    }

    try {
      setState(() {
        _addingTodo = true;
      });
      final newToDo = await _apiService.updateNote(_titleController.text.trim(),
          _contentController.text.trim(), widget.note!.id);
      setState(() {
        _addingTodo = false; // Hide loading indicator
      });
      showSuccessMessage('Todo edited successfully', context);
      Navigator.pop(
        context,
        Note(
          id: newToDo.id,
          title: newToDo.title,
          content: newToDo.content,
          modifiedTime: newToDo
              .modifiedTime, // You may need to adjust this based on your requirements
        ),
      );
    } catch (e) {
      // Handle error, show an error message or log the error
      showErrorMessage('Failed to edited note: $e', context);
    } finally {
      setState(() {
        _addingTodo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  padding: const EdgeInsets.all(0),
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade800.withOpacity(.8),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ))
            ],
          ),
          Expanded(
              child: ListView(
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontSize: 30),
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 30)),
              ),
              TextField(
                controller: _contentController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                maxLines: null,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type something here',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    )),
              ),
            ],
          ))
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.note != null ? _editToDoItem() : _addToDoItem();
          // Navigator.pop(
          //     context, [_titleController.text, _contentController.text]);
        },
        elevation: 10,
        backgroundColor: Colors.grey.shade800,
        child: _addingTodo
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : const Icon(Icons.save),
      ),
    );
  }
}
