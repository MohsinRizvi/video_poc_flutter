import 'package:dio/dio.dart';

import 'package:dio/dio.dart';
import '../models/story_model.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class StoryService {
  // The base URL of the API
  final String _baseUrl = 'http://54.73.71.137:4000/api/admin/v1/video-streaming'; // Replace with your actual API endpoint

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

class VideoService {
  final Dio _dio = Dio();

  Future<Story> fetchVideos() async {
    try {
      final response = await _dio.get('http://54.73.71.137:4000/api/admin/v1/video-streaming');
      if (response.statusCode == 200) {
        // Parse the response using the generated JSON serialization code
        return Story.fromJson(response.data);
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      throw Exception('Failed to fetch videos: $e');
    }
  }
}
