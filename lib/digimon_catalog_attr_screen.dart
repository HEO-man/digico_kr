import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart' as csv;

import 'digimon_detail_screen.dart';

/// ─────────────────────────────────────────────
/// Google Sheets 설정 (사용자가 준 값 그대로)
/// ─────────────────────────────────────────────
const String kListCsvUrl =
    'https://docs.google.com/spreadsheets/d/e/2PACX-1vTx-6Id_QsgH9RT_GgelBNyzhSfpPS560GExIqBN6HmHKLU-Qe0rcrBv5JGNaONm8hngYrJbWJol5iu/pub?output=csv';

/// 목록 파싱용 레이블/정규식
const List<String> _attrLabels = ['불', '물', '전기', '바람', '땅', '빛', '어둠', '무', '풀'];
const Set<String> _stopWordsRow = {
  'z진화','Z진화','x진화','X진화','sp 진화','SP 진화','진화','급','25급','22급','18급'
};

bool _looksLikeName(String s) {
  final t = s.trim();
  if (t.isEmpty) return false;
  if (t.length < 2 || t.length > 20) return false;
  if (_attrLabels.contains(t)) return false;
  if (t.contains('몬')) return true;
  if (RegExp(r'.+(몬|몬X|몬GX|몬SP)$').hasMatch(t)) return true;
  return false;
}

class _DigimonEntry {
  final String name;
  final String attr;
  _DigimonEntry(this.name, this.attr);
}

/// ─────────────────────────────────────────────
/// 디지몬 목록(속성별) 화면
/// ─────────────────────────────────────────────
class DigimonCatalogAttrScreen extends StatefulWidget {
  const DigimonCatalogAttrScreen({super.key});
  @override
  State<DigimonCatalogAttrScreen> createState() => _DigimonCatalogAttrScreenState();
}

class _DigimonCatalogAttrScreenState extends State<DigimonCatalogAttrScreen> {
  bool _loading = true;
  String? _error;
  List<_DigimonEntry> _all = [];
  String _query = '';
  String _selectedAttr = '전체';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _all.clear();
    });

    try {
      final res = await http.get(Uri.parse(kListCsvUrl));
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final body = utf8.decode(res.bodyBytes);
      final rows =
      const csv.CsvToListConverter(shouldParseNumbers: false).convert(body);

      final parsed = _parseAttrGrid(rows);
      setState(() {
        _all = parsed..sort((a, b) => a.name.compareTo(b.name));
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<_DigimonEntry> _parseAttrGrid(List<List<dynamic>> rows) {
    final R = rows
        .map((r) => r.map((c) => (c ?? '').toString().trim()).toList())
        .where((r) => r.any((c) => c.isNotEmpty))
        .toList();

    if (R.isEmpty) return [];

    // 속성 헤더가 있는 행 찾기
    int attrRow = -1;
    for (int r = 0; r < R.length; r++) {
      final hit = R[r].where((c) => _attrLabels.contains(c)).length;
      if (hit >= 3) { attrRow = r; break; }
    }

    if (attrRow < 0) {
      // 헤더가 없어도 전체에서 후보명 수집
      final names = <String>{};
      for (final r in R) {
        for (final c in r) {
          if (_looksLikeName(c)) names.add(c);
        }
      }
      final listSorted = names.toList()..sort();
      return listSorted.map((n) => _DigimonEntry(n, '기타')).toList();
    }

    // 열 → 속성 매핑
    final attrByCol = <int,String>{};
    for (int c = 0; c < R[attrRow].length; c++) {
      final v = R[attrRow][c];
      if (_attrLabels.contains(v)) attrByCol[c] = v;
    }

    // 데이터 수집
    final list = <_DigimonEntry>[];
    for (int r = attrRow + 1; r < R.length; r++) {
      final row = R[r];
      if (row.any((c) => _stopWordsRow.contains(c))) continue; // 구분행 skip
      for (int c = 0; c < row.length; c++) {
        final name = row[c];
        if (name.isEmpty) continue;
        if (_looksLikeName(name)) {
          final attr = attrByCol[c] ?? '기타';
          list.add(_DigimonEntry(name, attr));
        }
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final attrs = <String>{'전체', ..._all.map((e) => e.attr)};
    final filtered = _all.where((e) {
      final okAttr = _selectedAttr == '전체' || e.attr == _selectedAttr;
      final okText = _query.isEmpty || e.name.toLowerCase().contains(_query.toLowerCase());
      return okAttr && okText;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('디지몬 목록 (속성별)'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
          ? Center(child: Text('불러오기 실패: $_error'))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: '디지몬 이름 검색',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
              onChanged: (s) => setState(() => _query = s.trim()),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              children: attrs.map((a) {
                final selected = a == _selectedAttr;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: ChoiceChip(
                    label: Text(a),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedAttr = a),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final e = filtered[i];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0x22000000)),
                  ),
                  title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(e.attr),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DigimonDetailScreen(digimonName: e.name),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      )),
    );
  }
}