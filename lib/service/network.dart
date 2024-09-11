import '../models/story_model.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class StoryService {
  // The base URL of the API

  final _baseUrl =
      'https://reels-poc-api-e8ccf946e84c.herokuapp.com/api/v1/video-streaming?platform=android'; // Replace with your actual API endpoint

  // Fetch stories from the API
  Future<List<Story>> fetchStories() async {
    // if (Platform.isAndroid) _baseUrl = '$_baseUrl?platform=android';
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
