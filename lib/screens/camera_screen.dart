import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  Timer? _captureTimer;
  int _captureInterval = 5; // Default interval in seconds
  
  List<Map<String, dynamic>> _detectionResults = [];
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      
      await _controller!.initialize();
      
      if (!mounted) return;
      
      setState(() {
        _isInitialized = true;
      });
    }
  }
  
  void _startCapturing() {
    if (_isCapturing) return;
    
    setState(() {
      _isCapturing = true;
    });
    
    _captureTimer = Timer.periodic(Duration(seconds: _captureInterval), (_) {
      _captureAndSendImage();
    });
  }
  
  void _stopCapturing() {
    if (!_isCapturing) return;
    
    _captureTimer?.cancel();
    
    setState(() {
      _isCapturing = false;
    });
  }
  
  Future<void> _captureAndSendImage() async {
    if (!_controller!.value.isInitialized) return;
    
    try {
      final XFile image = await _controller!.takePicture();
      
      // Convert XFile to bytes directly
      final bytes = await image.readAsBytes();
      
      // Send the image to the API service
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.sendImageBytesToServer(bytes);
      
      setState(() {
        _detectionResults = result;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image processed: ${result.length} result(s) received')),
        );
      }
    } catch (e) {
      print('Error capturing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _captureTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Face Detection Camera'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Container(
            width: 600,
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CameraPreview(_controller!),
            ),
          ),
          SizedBox(height: 20),
          
          Container(
            width: 600,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detection Results:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                _detectionResults.isEmpty
                    ? Text('No results yet')
                    : Container(
                        height: 150,
                        child: SingleChildScrollView(
                          child: Text(
                            const JsonEncoder.withIndent('  ').convert(_detectionResults),
                            style: TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('Interval (seconds): $_captureInterval'),
                    Slider(
                      value: _captureInterval.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: _captureInterval.toString(),
                      onChanged: (value) {
                        setState(() {
                          _captureInterval = value.round();
                        });
                        if (_isCapturing) {
                          _stopCapturing();
                          _startCapturing();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isCapturing ? _stopCapturing : _startCapturing,
        child: Icon(_isCapturing ? Icons.stop : Icons.play_arrow),
      ),
    );
  }
} 