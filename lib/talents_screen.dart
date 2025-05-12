import 'package:flutter/material.dart';
import 'package:new_century/tab_output_tree.dart';
import 'package:new_century/tab_survival_tree.dart';
import 'package:new_century/tab_support_tree.dart';

class TalentsScreen extends StatefulWidget {
  const TalentsScreen({super.key});

  @override
  State<TalentsScreen> createState() => _TalentsScreenState();
}

class _TalentsScreenState extends State<TalentsScreen> {
  final Map<String, int> _tabLevelMap = {
    '출력': 0,
    '생존': 0,
    '보조': 0,
  };

  void _updateLevel(String label, int level) {
    setState(() {
      _tabLevelMap[label] = level;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('특성 찍기'),
          bottom: TabBar(
            tabs: [
              Tab(text: '출력(${_tabLevelMap["출력"]})'),
              Tab(text: '생존(${_tabLevelMap["생존"]})'),
              Tab(text: '보조(${_tabLevelMap["보조"]})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OutputTreeTab(onLevelChanged: (level) => _updateLevel('출력', level)),
            SurvivalTreeTab(onLevelChanged: (level) => _updateLevel('생존', level)),
            SupportTreeTab(onLevelChanged: (level) => _updateLevel('보조', level)),
          ],
        ),
      ),
    );
  }
}

class TalentTreeTab extends StatelessWidget {
  final String label;
  final ValueChanged<int>? onLevelChanged;

  const TalentTreeTab({super.key, required this.label, this.onLevelChanged});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label 트리 영역 (구현 예정)',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}