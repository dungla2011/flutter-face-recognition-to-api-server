class DetectionResult {
  final String personId;
  final double confidence;
  final Map<String, double> boundingBox;
  
  DetectionResult({
    required this.personId,
    required this.confidence,
    required this.boundingBox,
  });
  
  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      personId: json['person_id'] as String,
      confidence: json['confidence'] as double,
      boundingBox: Map<String, double>.from(json['bounding_box'] as Map),
    );
  }
} 