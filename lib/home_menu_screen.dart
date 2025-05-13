import 'package:flutter/material.dart';
import 'package:new_century/rotation_screen.dart';
import 'guides_screen.dart';
import 'main.dart';
import 'talents_screen.dart';
import 'equipment_list_screen.dart';

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/main_ilst_04.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 170, left: 24, right: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                _buildMenuButton(context, '디지몬 정보', const DigimonListScreen()),
                const SizedBox(height: 20),
                _buildMenuButton(context, '공략 모음', const GuidesScreen()),
                const SizedBox(height: 20),
                _buildMenuButton(context, '로테이션 정보', const RotationScreen()),
                const SizedBox(height: 20),
                _buildMenuButton(context, '특성 찍기', const TalentsScreen()),
                const SizedBox(height: 20),
                _buildMenuButton(context, '테이머장비', const EquipmentListScreen()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, Widget targetScreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.white70,
          foregroundColor: Colors.deepPurple,
          elevation: 4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => targetScreen),
          );
        },
        child: Text(title, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}