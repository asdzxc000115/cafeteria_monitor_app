import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'place_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('학교 혼잡도'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                '장소를 선택하세요',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSkyBlue,
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  PlaceCard(
                    placeName: '학생식당',
                    iconData: Icons.restaurant,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CafeteriaDetailScreen(
                            cafeteriaName: '학생식당',
                          ),
                        ),
                      );
                    },
                  ),
                  PlaceCard(
                    placeName: '3호관 스터디룸',
                    iconData: Icons.menu_book,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CafeteriaDetailScreen(
                            cafeteriaName: '3호관 스터디룸',
                          ),
                        ),
                      );
                    },
                  ),
                  PlaceCard(
                    placeName: '도서관',
                    iconData: Icons.local_library,
                    onTap: () {
                      // 추후 구현
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('준비 중입니다')),
                      );
                    },
                  ),
                  PlaceCard(
                    placeName: '체육관',
                    iconData: Icons.fitness_center,
                    onTap: () {
                      // 추후 구현
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('준비 중입니다')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceCard extends StatelessWidget {
  final String placeName;
  final IconData iconData;
  final VoidCallback onTap;

  const PlaceCard({
    Key? key,
    required this.placeName,
    required this.iconData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.skyBlue.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 60,
              color: AppColors.skyBlue,
            ),
            SizedBox(height: 15),
            Text(
              placeName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSkyBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}