import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/crowd_data.dart';

class CrowdApi {
  // 맥북 IP와 포트 5001로 수정
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5001/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5001/api';
    } else if (Platform.isIOS || Platform.isMacOS) {
      return 'http://10.200.72.41:5001/api';  // macOS/iOS용
    }
    return 'http://localhost:5001/api';
  }

  // 연결 테스트 함수 - /api/current 사용
  static Future<bool> testConnection() async {
    try {
      print('🔍 서버 연결 테스트 시작...');
      print('📡 연결 주소: $baseUrl/current');

      final response = await http.get(
        Uri.parse('$baseUrl/current'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('📊 응답 코드: ${response.statusCode}');
      print('📝 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ 서버 연결 성공!');
        return true;
      } else {
        print('❌ 서버 응답 오류: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ 연결 에러: $e');
      print('💡 확인사항:');
      print('   1. 맥북과 폰이 같은 WiFi에 연결되어 있나요?');
      print('   2. 맥북에서 서버가 실행 중인가요? (python src/api/server.py)');
      print('   3. IP 주소가 올바른가요? (10.200.73.247:5001)');
      return false;
    }
  }

  // 현재 혼잡도 조회 - placeName 파라미터 추가
  static Future<CrowdData?> getCurrentCrowd({String placeName = '학생식당'}) async {
    try {
      // place 파라미터를 URL에 추가
      final url = '$baseUrl/current?place=$placeName';
      print('📱 API 요청: $url');  // 디버그용

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('📊 응답 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ 데이터 수신 성공: ${jsonData['people_count']}명');
        return CrowdData.fromJson(jsonData);
      } else {
        print('❌ API 오류: ${response.statusCode}');
        print('📝 응답 내용: ${response.body}');
      }
    } catch (e) {
      print('❌ 현재 혼잡도 조회 실패: $e');
    }
    return null;
  }

  // 이력 데이터 조회 - placeName 파라미터 추가
  static Future<List<CrowdData>> getCrowdHistory({String placeName = '학생식당', int hours = 24}) async {
    try {
      final url = '$baseUrl/history?place=$placeName&hours=$hours';
      print('📊 이력 데이터 요청: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      print('📊 이력 응답 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('✅ 이력 데이터 수신: ${data.length}개 항목');
        return data.map((item) => CrowdData.fromJson(item)).toList();
      } else {
        print('❌ 이력 조회 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 이력 조회 실패: $e');
    }
    return [];
  }

  // 서버 상태 확인
  static Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ 서버 상태 확인 실패: $e');
      return false;
    }
  }

  // 네트워크 디버그 정보 출력
  static void printDebugInfo() {
    print('\n🔧 네트워크 디버그 정보:');
    print('📡 Base URL: $baseUrl');
    print('🌐 플랫폼: ${Platform.operatingSystem}');
    print('📱 웹 여부: $kIsWeb');
    print('💡 서버 확인: http://10.200.73.247:5001/api/current');
    print('=====================================\n');
  }
}