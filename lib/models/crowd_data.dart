class CrowdData {
  final DateTime timestamp;
  final int peopleCount;
  final double occupancyRate;
  final String crowdLevel;
  final String? placeName;  // 이 필드 추가 (nullable)

  CrowdData({
    required this.timestamp,
    required this.peopleCount,
    required this.occupancyRate,
    required this.crowdLevel,
    this.placeName,  // 이 부분 추가
  });

  factory CrowdData.fromJson(Map<String, dynamic> json) {
    return CrowdData(
      timestamp: DateTime.parse(json['timestamp']),
      peopleCount: json['people_count'],
      occupancyRate: json['occupancy_rate'].toDouble(),
      crowdLevel: json['crowd_level'],
      placeName: json['place_name'],  // 이 부분 추가
    );
  }
}