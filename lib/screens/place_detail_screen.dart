import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/app_colors.dart';
import '../api/crowd_api.dart';
import '../models/crowd_data.dart';

class CafeteriaDetailScreen extends StatefulWidget {
  final String cafeteriaName;

  const CafeteriaDetailScreen({Key? key, required this.cafeteriaName}) : super(key: key);

  @override
  _CafeteriaDetailScreenState createState() => _CafeteriaDetailScreenState();
}

class _CafeteriaDetailScreenState extends State<CafeteriaDetailScreen> {
  CrowdData? currentData;
  bool isLoading = true;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    loadCurrentData();
    // 30초마다 자동 새로고침
    refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      loadCurrentData();
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadCurrentData() async {
    print('\n===== Flutter 요청 =====');
    print('요청 시간: ${DateTime.now()}');
    print('요청 장소: "${widget.cafeteriaName}"');
    print('======================');

    final data = await CrowdApi.getCurrentCrowd(placeName: widget.cafeteriaName);

    if (data != null) {
      print('받은 데이터:');
      print('- 인원: ${data.peopleCount}명');
      print('- 혼잡도: ${data.crowdLevel}');
      print('- 시간: ${data.timestamp}');
    } else {
      print('데이터 없음');
    }

    if (mounted) {
      setState(() {
        currentData = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cafeteriaName),
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () {
              print('\n=== 디버그 정보 ===');
              print('현재 장소: "${widget.cafeteriaName}"');
              print('현재 인원: ${currentData?.peopleCount ?? "없음"}');
              print('마지막 업데이트: ${currentData?.timestamp ?? "없음"}');
              print('=================\n');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightSkyBlue,
              Colors.white,
            ],
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.skyBlue))
            : currentData == null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.grey),
              SizedBox(height: 20),
              Text('데이터를 불러올 수 없습니다',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: loadCurrentData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.skyBlue,
                ),
                child: Text('다시 시도'),
              ),
            ],
          ),
        )
            : RefreshIndicator(
          onRefresh: loadCurrentData,
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              // 현재 혼잡도 카드
              CrowdStatusCard(crowdData: currentData!),
              SizedBox(height: 20),
              // 혼잡도 기준 안내
              CrowdLevelGuide(),
              SizedBox(height: 20),
              // 추가 정보
              InfoCard(crowdData: currentData!),
            ],
          ),
        ),
      ),
    );
  }
}

class CrowdStatusCard extends StatelessWidget {
  final CrowdData crowdData;

  const CrowdStatusCard({Key? key, required this.crowdData}) : super(key: key);

  Color _getCrowdColor() {
    switch (crowdData.crowdLevel) {
      case '여유':
        return AppColors.crowdLow;
      case '보통':
        return AppColors.crowdMedium;
      case '혼잡':
        return AppColors.crowdHigh;
      default:
        return Colors.grey;
    }
  }

  IconData _getCrowdIcon() {
    switch (crowdData.crowdLevel) {
      case '여유':
        return Icons.sentiment_very_satisfied;
      case '보통':
        return Icons.sentiment_neutral;
      case '혼잡':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          children: [
            Text(
              '현재 혼잡도',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            // 혼잡도 아이콘
            Icon(
              _getCrowdIcon(),
              size: 80,
              color: _getCrowdColor(),
            ),
            SizedBox(height: 20),
            // 혼잡도 레벨
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _getCrowdColor(),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                crowdData.crowdLevel,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 25),
            // 상세 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoColumn('현재 인원', '${crowdData.peopleCount}명'),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey[300],
                ),
                _buildInfoColumn('점유율', '${crowdData.occupancyRate.toStringAsFixed(1)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkSkyBlue,
          ),
        ),
      ],
    );
  }
}

class CrowdLevelGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '혼잡도 기준',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSkyBlue,
              ),
            ),
            SizedBox(height: 15),
            _buildLevelIndicator('여유', '0-30%', AppColors.crowdLow, '여유로움'),
            SizedBox(height: 10),
            _buildLevelIndicator('보통', '30-70%', AppColors.crowdMedium, '적당함'),
            SizedBox(height: 10),
            _buildLevelIndicator('혼잡', '70-100%', AppColors.crowdHigh, '혼잡함'),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelIndicator(String level, String range, Color color, String description) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              level,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                range,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final CrowdData crowdData;

  const InfoCard({Key? key, required this.crowdData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.skyBlue.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 업데이트',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _formatTime(crowdData.timestamp),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSkyBlue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              '30초마다 자동으로 업데이트됩니다',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}초 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else {
      return '${difference.inHours}시간 전';
    }
  }
}