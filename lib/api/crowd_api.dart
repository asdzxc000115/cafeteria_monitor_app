import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/crowd_data.dart';

class CrowdApi {
  // 플랫폼별로 다른 IP 사용
  static String get baseUrl {
    if (kIsWeb) {
      // 웹 브라우저
      return 'http://localhost:5001/api';
    } else if (Platform.isAndroid) {
      // Android 에뮬레이터
      return 'http://10.0.2.2:5001/api';
    } else if (Platform.isIOS) {
      // iOS 시뮬레이터
      return 'http://localhost:5001/api';
    }
    // 실제 디바이스 (WiFi 같은 네트워크)
    return 'http://10.200.42.30:5001/api'; // 실제 컴퓨터 IP로 변경
  }

  // placeName 파라미터 추가!
  static Future<CrowdData?> getCurrentCrowd({String placeName = '학생식당'}) async {
    try {
      // place 파라미터를 URL에 추가
      final url = '$baseUrl/current?place=$placeName';
      print('API 요청: $url');  // 디버그용

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return CrowdData.fromJson(json.decode(response.body));
      }
    } catch (e) {
      print('Error fetching current crowd: $e');
    }
    return null;
  }

  // history 함수도 필요하면 수정
  static Future<List<CrowdData>> getCrowdHistory({String placeName = '학생식당', int hours = 24}) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/history?place=$placeName&hours=$hours')
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => CrowdData.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching crowd history: $e');
    }
    return [];
  }
}