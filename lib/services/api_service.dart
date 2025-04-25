import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ApiService extends ChangeNotifier {
  static const String _apiUrl = 'https://mytree.vn/tool1/_site/event_mng/get-image-ai-face-detect.php';
  List<Map<String, dynamic>> _lastDetectionResult = [];
  
  List<Map<String, dynamic>> get lastDetectionResult => _lastDetectionResult;
  
  Future<List<Map<String, dynamic>>> sendImageToServer(File imageFile) async {
    try {
      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      
      // Add the image file to the request - fix for _Namespace error
      final bytes = await imageFile.readAsBytes();
      
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'image.jpg',
      );
      
      request.files.add(multipartFile);
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body) as List;
        _lastDetectionResult = List<Map<String, dynamic>>.from(
          decodedResponse.map((item) => item as Map<String, dynamic>)
        );
        notifyListeners();
        return _lastDetectionResult;
      } else {
        print('Server error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error sending image to server: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> sendImageBytesToServer(Uint8List imageBytes) async {
    try {
      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      
      // Add the image bytes to the request
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'image.jpg',
      );
      
      request.files.add(multipartFile);
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<Map<String, dynamic>> results = [];
        
        // Handle both list and map responses
        if (jsonResponse is List) {
          results = List<Map<String, dynamic>>.from(
            jsonResponse.map((item) => item as Map<String, dynamic>)
          );
        } else if (jsonResponse is Map) {
          // If it's a single object or an object with a results array
          if (jsonResponse.containsKey('results') && jsonResponse['results'] is List) {
            // If the API returns {results: [...]}
            results = List<Map<String, dynamic>>.from(
              jsonResponse['results'].map((item) => item as Map<String, dynamic>)
            );
          } else {
            // If it's just a single result object, wrap it in a list
            results = [Map<String, dynamic>.from(jsonResponse)];
          }
        }
        
        _lastDetectionResult = results;
        notifyListeners();
        return results;
      } else {
        print('Server error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error sending image to server: $e');
      return [];
    }
  }
} 