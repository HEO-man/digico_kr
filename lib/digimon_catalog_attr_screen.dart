// lib/digimon_catalog_attr_screen.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart' as csv;

import 'digimon_detail_screen.dart';

/// 공개 CSV (목록 탭 전체를 CSV로)
const String kListCsvUrl =
    'https://docs.google.com/spreadsheets/d/e/2PACX-1vTx-6Id_QsgH9RT_GgelBNyzhSfpPS560GExIqBN6HmHKLU-Qe0rcrBv5JGNaONm8hngYrJbWJol5iu/pub?output=csv';

/// 속성 라벨
const List<String> _attrLabels = ['불', '물', '전기', '바람', '땅', '빛', '어둠', '풀'];

/// 속성 → 아이콘 경로
const Map<String, String> _attrIcon = {
  '불':   'assets/icon/element/ic_fire.png',
  '물':   'assets/icon/element/ic_water.png',
  '바람': 'assets/icon/element/ic_wind.png',
  '풀':   'assets/icon/element/ic_nature.png',
  '빛':   'assets/icon/element/ic_light.png',
  '어둠': 'assets/icon/element/ic_dark.png',
  '땅':   'assets/icon/element/ic_earth.png',
  '전기': 'assets/icon/element/ic_thunder.png',
};

/// 구분/제외 행(행 전체가 이 단어들로만 구성되는 구분줄에 대응)
const Set<String> _stopRowTokens = {
  'z진화','Z진화','x진화','X진화','sp 진화','SP 진화','진화',
  '급','25급','22급','18급'
};

/// ─────────────────────────────────────────────
/// 유틸
/// ─────────────────────────────────────────────

/// 눈에 안 보이는 공백까지 싹 정규화
String _hardNormalize(String s) {
  if (s.isEmpty) return s;
  // BOM/제로폭/비가시 제거
  const invisibles = [
    '\uFEFF', // BOM
    '\u200B', '\u200C', '\u200D', '\u2060', // ZERO-WIDTH
  ];
  for (final ch in invisibles) {
    s = s.replaceAll(ch, '');
  }
  // NBSP류를 보통 공백으로
  s = s.replaceAll(RegExp(r'[\u00A0\u2007\u202F\t]'), ' ');
  // 연속 공백 1칸으로, 양끝 trim
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}

bool _looksLikeName(String raw) {
  final t = _hardNormalize(raw);
  if (t.isEmpty) return false;
  if (t.length < 2 || t.length > 30) return false;
  // 속성 라벨 자체는 제외
  if (_attrLabels.contains(t)) return false;
  // 디지몬명 휴리스틱
  if (t.contains('몬')) return true;
  if (RegExp(r'.+(몬|몬X|몬GX|몬SP)$').hasMatch(t)) return true;
  return false;
}

/// ─────────────────────────────────────────────
/// 모델
/// ─────────────────────────────────────────────
class _DigimonEntry {
  final String name;
  final String attr;
  _DigimonEntry(this.name, this.attr);
}

/// ─────────────────────────────────────────────
/// 화면
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
      final bust = DateTime.now().millisecondsSinceEpoch;
      final url = '$kListCsvUrl&cb=$bust';
      debugPrint('[CSV] GET: $url');

      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode} / ${res.body}');
      }
      final body = utf8.decode(res.bodyBytes);
      final rows = const csv.CsvToListConverter(
        shouldParseNumbers: false,
      ).convert(body);

      final parsed = _parseAttrGrid(rows);
      parsed.sort((a, b) => a.name.compareTo(b.name));

      // 디버깅: 속성별 카운트 + 도철몬 탐지
      final byAttr = <String, int>{};
      for (final e in parsed) {
        byAttr[e.attr] = (byAttr[e.attr] ?? 0) + 1;
      }
      debugPrint('[PARSE] 총 ${parsed.length}개, 속성별: $byAttr');
      final probe = parsed.where((e) =>
      _hardNormalize(e.name).contains(_hardNormalize('도철')) ||
          _hardNormalize(e.name).contains(_hardNormalize('도철몬'))).toList();
      debugPrint('[PARSE] "도철/도철몬" 매칭 ${probe.length}개 → ${probe.map((e)=>'${e.name}(${e.attr})').toList()}');

      setState(() => _all = parsed);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<_DigimonEntry> _parseAttrGrid(List<List<dynamic>> rows) {
    // 1) 문자열 정규화 + 빈 행 제거
    final R = rows
        .map((r) => r.map((c) => _hardNormalize((c ?? '').toString())).toList())
        .where((r) => r.any((c) => c.isNotEmpty))
        .toList();
    if (R.isEmpty) return [];

    // 2) 속성 헤더 행 자동 탐지(같은 줄에 3개 이상 속성 라벨)
    int attrRow = -1;
    for (int r = 0; r < R.length; r++) {
      final hit = R[r].where((c) => _attrLabels.contains(c)).length;
      if (hit >= 3) {
        attrRow = r;
        debugPrint('[PARSE] 속성 헤더 행 = $attrRow → ${R[r]}');
        break;
      }
    }
    if (attrRow < 0) {
      // 헤더가 없어도 전체에서 이름만 긁어서 ‘기타’로
      final names = <String>{};
      for (final r in R) {
        for (final c in r) {
          if (_looksLikeName(c)) names.add(_hardNormalize(c));
        }
      }
      return names.map((n) => _DigimonEntry(n, '기타')).toList();
    }

    // 3) 열 → 속성 매핑(좌/우 블록 전부)
    final attrByCol = <int, String>{};
    for (int c = 0; c < R[attrRow].length; c++) {
      final v = R[attrRow][c];
      if (_attrLabels.contains(v)) attrByCol[c] = v;
    }
    debugPrint('[PARSE] 열→속성 매핑: $attrByCol');

    // 4) 데이터 수집(구분행 스킵)
    final list = <_DigimonEntry>[];
    for (int r = attrRow + 1; r < R.length; r++) {
      final row = R[r];

      // 구분행 스킵: 이 행이 전부 구분 토큰이거나 토큰만 섞인 경우
      final tokens = row.where((c) => c.isNotEmpty).toSet();
      final onlyStops = tokens.isNotEmpty && tokens.every(_stopRowTokens.contains);
      if (onlyStops) continue;

      for (int c = 0; c < row.length; c++) {
        final cell = row[c];
        if (cell.isEmpty) continue;
        if (!_looksLikeName(cell)) continue;

        final name = _hardNormalize(cell);
        final attr = attrByCol[c] ?? '기타';
        list.add(_DigimonEntry(name, attr));
      }
    }

    // 5) 중복 제거(같은 이름이 여러 열에 있을 수 있음)
    final dedup = <String, _DigimonEntry>{};
    for (final e in list) {
      final key = _hardNormalize(e.name);
      // 속성 우선순위(있으면 덮지 않음): 바람/빛/어둠/불/물/전기/풀/땅/기타
      if (!dedup.containsKey(key)) {
        dedup[key] = e;
      }
    }
    debugPrint('[PARSE] 결과 ${dedup.length}개 수집');
    return dedup.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final attrs = <String>{'전체', ..._all.map((e) => e.attr)}.toList()
      ..sort((a, b) {
        if (a == '전체') return -1;
        if (b == '전체') return 1;
        return a.compareTo(b);
      });

    final q = _hardNormalize(_query);
    final filtered = _all.where((e) {
      final okAttr = _selectedAttr == '전체' || e.attr == _selectedAttr;
      final nm = _hardNormalize(e.name);
      final okText = q.isEmpty || nm.contains(q);
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
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text('불러오기 실패: $_error',
            style: const TextStyle(color: Colors.red)),
      )
          : Column(
        children: [
          // 검색
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: '디지몬 이름 검색 (예: 도철 / 도철몬)',
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
              onChanged: (s) => setState(() => _query = s),
            ),
          ),
          // 속성 필터 칩
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              children: attrs.map((a) {
                final selected = a == _selectedAttr;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 8),
                  child: ChoiceChip(
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _selectedAttr = a),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (a != '전체') ...[
                          Image.asset(
                            _attrIcon[a] ?? _attrIcon['빛']!,
                            width: 18, height: 18,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(a),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          // 목록
          Expanded(
            child: ListView.separated(
              padding:
              const EdgeInsets.fromLTRB(12, 8, 12, 12),
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final e = filtered[i];
                final iconPath =
                    _attrIcon[e.attr] ?? _attrIcon['빛']!;
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                        color: Color(0x22000000)),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceVariant,
                    radius: 18,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(iconPath),
                    ),
                  ),
                  title: Text(
                    e.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700),
                  ),
                  subtitle: Row(
                    children: [
                      Image.asset(iconPath,
                          width: 16, height: 16),
                      const SizedBox(width: 6),
                      Text(e.attr),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DigimonDetailScreen(
                          digimonName: e.name),
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