import 'dart:developer';

import 'package:dio/dio.dart';

import '../models/note.dart';

class ApiService {
  final Dio _dio = Dio();
  var baseUrl = "https://mohamadnoteapp.000webhostapp.com/";
  Future<List<Note>> fetchNotes() async {
    try {
      final response = await _dio.get(
          "${baseUrl}get_notes.php"); // Replace with your actual API endpoint

      if (response.statusCode == 200) {
        final List<dynamic> noteListJson = response.data['notes'];
        return noteListJson.map((json) => Note.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch todos');
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to fetch todos: $e');
    }
  }

  Future<Note> addNewToDo(String title, String content) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var data = {'title': title, 'content': content};
    try {
      var response = await _dio.request(
        "${baseUrl}add_note.php",
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> todoJson = response.data['notes'];
        return Note.fromJson(todoJson);
      } else {
        throw Exception('Failed to add note');
      }
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }

  Future<Note> updateNote(String title, String content, String noteId) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var data = {'id': noteId, 'title': title, 'content': content};
    try {
      var response = await _dio.request(
        "${baseUrl}update_note.php",
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> todoJson = response.data['notes'];
        return Note.fromJson(todoJson);
      } else {
        throw Exception('Failed to edit note');
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to edit note: $e');
    }
  }

  Future<Note> deleteNote(String noteId) async {
    log(noteId);
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var data = {
      'id': noteId,
    };
    try {
      var response = await _dio.request(
        "${baseUrl}delete_note.php",
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        log(response.data.toString());
        final Map<String, dynamic> todoJson = response.data['notes'];
        return Note.fromJson(todoJson);
      } else {
        throw Exception('Failed to delete note');
      }
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }
}
