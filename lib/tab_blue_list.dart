import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TabBlueList extends StatefulWidget {
  const TabBlueList({Key? key}) : super(key: key);

  @override
  State<TabBlueList> createState() => _TabBlueListState();
}

class _TabBlueListState extends State<TabBlueList> {
  List<dynamic> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEquipment();
  }

  Future<void> fetchEquipment() async {
    try {
      final response = await http.get(Uri.parse('https://heo-man.github.io/digimon-codex-kr/data/equipment_json/blue_eq_list.json'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          setState(() {
            items = decoded;
            isLoading = false;
          });
        } else {
          print('⚠️ JSON은 List가 아님: ${decoded.runtimeType}');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('❌ 서버 응답 오류: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ 데이터 가져오기 실패: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EquipmentDetailScreen(item: item),
              ),
            );
          },
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(
                    color: item["color"] == "green"
                        ? Colors.green
                        : item["color"] == "blue"
                        ? Colors.blue
                        : item["color"] == "purple"
                        ? Colors.purple
                        : item["color"] == "yellow"
                        ? Colors.amber
                        : Colors.grey,
                    width: 2,
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/icon/equipment/${item["icon"]}'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(item["name"], style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}

class EquipmentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const EquipmentDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  int preBattleStars = 1;
  int triggerStars = 1;
  int passiveStars = 1;

  @override
  Widget build(BuildContext context) {
    final effects = widget.item["effects"];

    return Scaffold(
      appBar: AppBar(title: Text(widget.item["name"])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.item["color"] == "green"
                        ? Colors.green
                        : widget.item["color"] == "blue"
                        ? Colors.blue
                        : widget.item["color"] == "purple"
                        ? Colors.purple
                        : widget.item["color"] == "yellow"
                        ? Colors.amber
                        : Colors.grey,
                    width: 2,
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/icon/equipment/${widget.item["icon"]}'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < preBattleStars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        preBattleStars = index + 1;
                        triggerStars = index + 1;
                        passiveStars = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(widget.item["nickname"] ?? '', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              _buildEffectSection("1번 자리 (Pre Battle)", effects["preBattle"], preBattleStars, (val) {
                setState(() => preBattleStars = val);
              }),
              const SizedBox(height: 20),
              _buildEffectSection("2번 자리 (Trigger)", effects["trigger"], triggerStars, (val) {
                setState(() => triggerStars = val);
              }),
              const SizedBox(height: 20),
              _buildEffectSection("3번 자리 (Passive)", effects["passive"], passiveStars, (val) {
                setState(() => passiveStars = val);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEffectSection(String title, Map<String, dynamic> effect, int stars, Function(int) onStarTapped) {
    final description = effect["description"];
    final values = effect["values"];
    final unit = effect["unit"] ?? "";

    String displayText = resolveVariableDescription(description, effect["slot"], stars, values, unit);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(displayText, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  String resolveVariableDescription(String description, int slot, int stars, List<dynamic> values, String unit) {
    final value = (stars >= 1 && stars <= values.length) ? values[stars - 1].toString() : "";
    return description.replaceAllMapped(
      RegExp(r'([xyz])(%| 포인트| chance)?'),
      (match) {
        final varName = match[1];
        final suffix = match[2] ?? '';
        if ((slot == 1 && varName == 'x') ||
            (slot == 2 && varName == 'y') ||
            (slot == 3 && varName == 'z')) {
          return '$value$suffix';
        }
        return match.group(0)!;
      },
    );
  }
}