import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'tab_green_list.dart';
import 'tab_blue_list.dart';
import 'tab_purple_list.dart';
import 'tab_gold_list.dart';

class EquipmentListScreen extends StatefulWidget {
  const EquipmentListScreen({Key? key}) : super(key: key);

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabs = ['Green', 'Blue', 'Purple', 'Gold'];
  final Map<String, List<dynamic>> equipmentByColor = {
    'Green': [],
    'Blue': [],
    'Purple': [],
    'Gold': [],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _loadEquipments();
  }

  Future<void> _loadEquipments() async {
    for (var color in tabs) {
      final response = await http.get(
        Uri.parse(
          'https://heo-man.github.io/digimon-codex-kr/data/equipment_${color.toLowerCase()}.json',
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          equipmentByColor[color] = jsonDecode(response.body);
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = equipmentByColor.values.any((list) => list.isEmpty);

    return Scaffold(
      appBar: AppBar(
        title: const Text('테이머 장비'),
        bottom: TabBar(
          controller: _tabController,
          tabs:
              tabs.map((label) {
                Color bgColor;
                switch (label) {
                  case 'Green':
                    bgColor = const Color(0xFF1FB830); // pastel green
                    break;
                  case 'Blue':
                    bgColor = const Color(0xFF6BA6F3); // pastel blue
                    break;
                  case 'Purple':
                    bgColor = const Color(0xFF9D74E3); // pastel purple
                    break;
                  case 'Gold':
                    bgColor = const Color(0xFFE6E466); // pastel yellow
                    break;
                  default:
                    bgColor = Colors.grey.shade200;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  child: Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TabGreenList(),
          TabBlueList(),
          TabPurpleList(),
          TabGoldList(),
        ],
      ),
    );
  }
}
