import 'package:dio/dio.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:video_poc/story_model.dart';

class StoryService {
  // The base URL of the API
  final String _baseUrl =
      'http://54.73.71.137:4000/api/admin/v1/video-streaming'; // Replace with your actual API endpoint

  // Fetch stories from the API
  Future<List<Story>> fetchStories() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> data = json.decode(response.body);

      // Check if the response contains the expected structure
      if (data['body'] != null) {
        List<dynamic> body = data['body'];

        // Convert the JSON data into a list of Story objects
        return body.map((json) => Story.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load stories: Unexpected response format');
      }
    } else {
      throw Exception('Failed to load stories: ${response.statusCode}');
    }
  }
}
