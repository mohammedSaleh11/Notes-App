import 'dart:convert';
import 'package:http/http.dart' as http;

class NoteService {
  final String serverurl = 'http://192.168.1.10:8000/api/notes';

  //create a note
  Future<http.Response> createNote(String title, String content) {
    final url = Uri.parse(serverurl);

    return http.post(
      url,
      headers: <String, String>{
        'content-type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'content': content,
      }),
    );
  }

// Fetch all notes
Future<http.Response> fetchNotes({
  String? searchText,
  int page = 1, // Default page number
  int limit = 10, // Default limit
}) {
  String url = '$serverurl?page=$page&limit=$limit'; // Add pagination to the URL

  if (searchText != null && searchText.isNotEmpty) {
    url += "&title=$searchText"; // Append search query if provided
  }

  final uri = Uri.parse(url);
  
  return http.get(uri);
}


  // Update a note
  Future<http.Response> updateNote(String id, String title, String content) {
    final url = Uri.parse('$serverurl/$id');
    return http.patch(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'content': content,
      }),
    );
  }

  // Delete a note
  Future<http.Response> deleteNote(String id) {
    final url = Uri.parse('$serverurl/$id');
    return http.delete(url);
  }
}
