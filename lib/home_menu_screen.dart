import 'package:flutter/material.dart';
import 'package:new_century/rotation_screen.dart';
import 'guides_screen.dart';
import 'main.dart';

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digimon Codex'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuButton(context, '디지몬 정보', const DigimonListScreen()),
            const SizedBox(height: 20),
            _buildMenuButton(context, '공략 모음', const GuidesScreen()),
            const SizedBox(height: 20),
            _buildMenuButton(context, '로테이션 정보', const RotationScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, Widget targetScreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
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