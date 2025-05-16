import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BattleEffectsScreen extends StatefulWidget {
  const BattleEffectsScreen({super.key});

  @override
  State<BattleEffectsScreen> createState() => _BattleEffectsScreenState();
}

class _BattleEffectsScreenState extends State<BattleEffectsScreen> {
  Map<String, dynamic> weatherData = {};
  Map<String, dynamic> battleEffectData = {};
  Map<String, dynamic> buffs = {};
  Map<String, dynamic> debuffs = {};
  Map<String, dynamic> controls = {};

  @override
  void initState() {
    super.initState();
    _loadEffectData();
  }

  Future<void> _loadEffectData() async {
    try {
      final weatherRes = await http.get(Uri.parse(
          'https://heo-man.github.io/digimon-codex-kr/data/weather/weather_script.json'));

      final battleRes = await http.get(Uri.parse(
          'https://heo-man.github.io/digimon-codex-kr/data/effects/battle_script.json'));
      final buffRes = await http.get(Uri.parse(
          'https://heo-man.github.io/digimon-codex-kr/data/effects/battle_buff.json'));
      final debuffRes = await http.get(Uri.parse(
          'https://heo-man.github.io/digimon-codex-kr/data/effects/battle_debuff.json'));
      final controlRes = await http.get(Uri.parse(
          'https://heo-man.github.io/digimon-codex-kr/data/effects/battle_control.json'));


      if (weatherRes.statusCode == 200) {
        setState(() {
          weatherData = json.decode(weatherRes.body);
        });
      }

      if (battleRes.statusCode == 200) {
        setState(() {
          battleEffectData = json.decode(battleRes.body);
        });
      }
      if (buffRes.statusCode == 200) {
        buffs = json.decode(buffRes.body);
      }
      if (debuffRes.statusCode == 200) {
        debuffs = json.decode(debuffRes.body);
      }
      if (controlRes.statusCode == 200) {
        controls = json.decode(controlRes.body);
      }
    } catch (e) {
      debugPrint('전투 효과 로딩 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('전투 효과'),
          bottom: const TabBar(
            isScrollable: false,
            tabs: [
              Tab(text: '날씨 효과'),
              Tab(text: '버프'),
              Tab(text: '디버프'),
              Tab(text: '제어상태'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEffectList(weatherData),
            _buildEffectList(buffs),
            _buildEffectList(debuffs),
            _buildEffectList(controls),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectList(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final entries = data.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final effect = entries[index].value;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Image.network(
              'https://heo-man.github.io/digimon-codex-kr/data/${effect['icon']}',
              width: 40,
              height: 40,
              errorBuilder: (_, __, ___) => const Icon(Icons.help_outline),
            ),
            title: Text(effect['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(effect['description']),
            tileColor: Color(int.parse('0xFF${effect['color'].substring(1)}')).withOpacity(0.1),
          ),
        );
      },
    );
  }
}