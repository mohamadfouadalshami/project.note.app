// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_app/constants/colors.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/screens/edit.dart';

import '../helper/snack_bar_helper.dart';
import '../provider/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> filteredNotes = [];
  bool sorted = false;
  bool _delete = false;
  final _apiService = ApiService();

  bool _loading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // filteredNotes = sampleNotes;
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    try {
      final todos = await _apiService.fetchNotes();
      setState(() {
        filteredNotes = todos;
        _loading = false;
        _errorMessage = ''; // Clear any previous error messages
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Error fetching todos: $e';
      });
      // Handle error, show an error message or log the error
      print(_errorMessage);
    }
  }

  List<Note> sortNotesByModifiedTime(List<Note> notes) {
    if (sorted) {
      notes.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));
    } else {
      notes.sort((b, a) => a.modifiedTime.compareTo(b.modifiedTime));
    }

    sorted = !sorted;

    return notes;
  }

  getRandomColor() {
    Random random = Random();
    return backgroundColors[random.nextInt(backgroundColors.length)];
  }

  final List<Note> _originalToDoList =
      []; // Add this line to store the original list

  void onSearchTextChanged(String enteredKeyword) {
    List<Note> results = [];

    if (_originalToDoList.isEmpty) {
      _originalToDoList.addAll(filteredNotes);
    }

    if (enteredKeyword.isEmpty) {
      results =
          _originalToDoList; // Use the original list when keyword is empty
    } else {
      results = filteredNotes
          .where((item) =>
              item.title.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
              item.content.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredNotes = results;
    });
  }

  Future<void> deleteNote(String id) async {
    try {
      setState(() {
        _delete = true;
      });
      await _apiService.deleteNote(id);
      setState(() {
        filteredNotes.removeWhere(
            (todo) => todo.id == id); // Remove the todo from the list
        _originalToDoList.removeWhere(
            (todo) => todo.id == id); // Remove from the original list

        onSearchTextChanged("");
        _delete = false;
      });

      showSuccessMessage('Note deleted successfully', context);
    } catch (e) {
      showErrorMessage('Error deleting todo: $e', context);
      setState(() {
        _delete = false;
      });
      // Handle error, show an error message or log the error
      print('Error deleting todo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notes',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        filteredNotes = sortNotesByModifiedTime(filteredNotes);
                      });
                    },
                    padding: const EdgeInsets.all(0),
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade800.withOpacity(.8),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(
                        Icons.sort,
                        color: Colors.white,
                      ),
                    ))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              onChanged: onSearchTextChanged,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: "Search notes...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                fillColor: Colors.grey.shade800,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                        _errorMessage,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.white),
                      ))
                    : filteredNotes.isEmpty
                        ? const Center(
                            child: Text(
                            'No data found',
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ))
                        : const SizedBox.shrink(),
            Expanded(
                child: ListView.builder(
              padding: const EdgeInsets.only(top: 30),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  color: getRandomColor(),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListTile(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                EditScreen(note: filteredNotes[index]),
                          ),
                        );
                        if (result != null && result is Note) {
                          setState(() {
                            filteredNotes[index] = Note(
                                id: result.id,
                                title: result.title,
                                content: result.content,
                                modifiedTime: result.modifiedTime);
                          });
                        }
                      },
                      title: RichText(
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            text: '${filteredNotes[index].title} \n',
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                height: 1.5),
                            children: [
                              TextSpan(
                                text: filteredNotes[index].content,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    height: 1.5),
                              )
                            ]),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Edited: ${DateFormat('EEE MMM d, yyyy h:mm a').format(filteredNotes[index].modifiedTime)}',
                          style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade800),
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () async {
                          confirmDialog(context, filteredNotes[index].id);
                        },
                        icon: const Icon(
                          Icons.delete,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const EditScreen(),
            ),
          );
          if (result != null && result is Note) {
            setState(() {
              filteredNotes.add(Note(
                  id: result.id,
                  title: result.title,
                  content: result.content,
                  modifiedTime: result.modifiedTime));
              // filteredNotes = sampleNotes;
            });
          }
        },
        elevation: 10,
        backgroundColor: Colors.grey.shade800,
        child: const Icon(
          Icons.add,
          size: 38,
        ),
      ),
    );
  }

  Future<dynamic> confirmDialog(BuildContext context, String id) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey.shade900,
            icon: const Icon(
              Icons.info,
              color: Colors.grey,
            ),
            title: _delete == true
                ? const CircularProgressIndicator()
                : const Text(
                    'Are you sure you want to delete?',
                    style: TextStyle(color: Colors.white),
                  ),
            content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        deleteNote(id).whenComplete(() {
                          Navigator.pop(context, true);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const SizedBox(
                        width: 60,
                        child: Text(
                          'Yes',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const SizedBox(
                        width: 60,
                        child: Text(
                          'No',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                ]),
          );
        });
  }
}
