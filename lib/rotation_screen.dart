import 'package:flutter/material.dart';

class RotationScreen extends StatelessWidget {
  const RotationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로테이션 정보'),
      ),
      body: const Center(
        child: Text(
          '로테이션 정보 화면은 준비 중입니다.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}