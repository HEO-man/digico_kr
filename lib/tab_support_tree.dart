import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SupportTreeTab extends StatefulWidget {
  final ValueChanged<int>? onLevelChanged;
  const SupportTreeTab({super.key, this.onLevelChanged});

  @override
  State<SupportTreeTab> createState() => _SupportTreeTabState();
}

class _SupportTreeTabState extends State<SupportTreeTab> {
  List<dynamic> talents = [];
  final Map<String, int> localTalentLevels = {};

  @override
  void initState() {
    super.initState();
    _loadTalents();
  }

  Future<void> _loadTalents() async {
    final response = await http.get(Uri.parse(
        'https://heo-man.github.io/digimon-codex-kr/data/talents_support.json'));
    if (response.statusCode == 200) {
      setState(() {
        talents = jsonDecode(response.body);
      });
    }
  }

  String _getCurrentDescription(Map<String, dynamic> talent, int level) {
    final value = level == 0 ? '' : talent["levels"][level - 1]["value"];
    return talent["description"]
        .replaceAll('n%', value)
        .replaceAll('n points', '$value points')
        .replaceAll('n chance', '$value chance')
        .replaceAll('n', value); // fallback case
  }

  @override
  Widget build(BuildContext context) {
    if (talents.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E1E2E), Color(0xFF15151F)],
            ),
            border: Border(
              left: BorderSide(color: Colors.blueGrey.shade700, width: 1),
              right: BorderSide(color: Colors.blueGrey.shade700, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Column(
            children: List.generate(6, (row) {
              return Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${row + 1}급',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  for (int col = 0; col < 4; col++)
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 80,
                        child: Center(
                          child: _buildNodeAt(row, col),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNodeAt(int row, int col) {
    final hasTalent = talents.any(
          (t) => t['position']['row'] == row && t['position']['col'] == col,
    );
    final talent = hasTalent
        ? talents.firstWhere(
          (t) =>
      t['position']['row'] == row && t['position']['col'] == col,
    )
        : null;
    final node = SizedBox(
      height: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Center(
              child: talent != null
                  ? GestureDetector(
                onTap: () => _showTalentDialog(context, talent),
                child: Image.asset(
                  'assets/icon/talents/${talent["icon"]}',
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red),
                ),
              )
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          Builder(builder: (_) {
            if (talent != null && talent["id"] != null) {
              final level = localTalentLevels['support::${talent["id"]}'] ?? 0;
              return Text(
                '$level/${(row % 2 == 1) ? 3 : 5}',
                style: const TextStyle(color: Colors.white),
              );
            }
            return const Text('', style: TextStyle(color: Colors.white));
          }),
        ],
      ),
    );
    //print('아이콘 파일명: ${talent["icon"]}');
    return talent == null ? Opacity(opacity: 0.0, child: node) : node;
  }

  void _showTalentDialog(BuildContext context, Map<String, dynamic> talent) {
    final key = 'support::${talent["id"]}';
    int level = localTalentLevels[key] ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey.shade900,
              title: Text(talent["name"], style: const TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/icon/talents/${talent["icon"]}', width: 48, height: 48),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (_) {
                      return Text(
                        _getCurrentDescription(talent, level),
                        style: const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  if (talent["remark"] != null)
                    Text(talent["remark"], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            if (level > 0) level--;
                          });
                        },
                      ),
                      Text('Lv. $level', style: const TextStyle(color: Colors.white)),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            int maxLevel = (talent["position"]["row"] % 2 == 1) ? 3 : 5;
                            if (level < maxLevel) level++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Delay the setState to ensure it runs after the dialog closes
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        localTalentLevels['support::${talent["id"]}'] = level;
                      });

                      if (widget.onLevelChanged != null) {
                        final total = localTalentLevels.values.fold<int>(0, (sum, val) => sum + val);
                        widget.onLevelChanged!(total);
                      }
                    });
                  },
                  child: const Text('확인', style: TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }
}