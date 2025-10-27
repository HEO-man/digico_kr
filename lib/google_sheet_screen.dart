import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart' as csv;
import 'package:url_launcher/url_launcher.dart';

/// ============== 설정 ==============
/// Google Sheet의 "파일 → 웹에 게시" 사용 (형식: CSV 또는 TSV).
/// 시트 ID와 각 탭의 gid만 넣으면 됩니다.
const String kSheetId   = '여기에_스프레드시트ID'; // 예: 1xvePfQi... (문서 URL의 /d/와 /edit 사이)
const String kGidX      = '여기에_X진화_gid';     // 예: 0
const String kGidZ      = '여기에_Z진화_gid';     // 예: 123456789
const String kGidSP     = '여기에_SP진화_gid';    // 예: 987654321
const bool   kUseCSV    = true; // TSV로 게시했다면 false
// 그냥 이걸로 충분합니다 👇
const String kCsvUrl =
    'https://docs.google.com/spreadsheets/d/e/2PACX-1vTx-6Id_QsgH9RT_GgelBNyzhSfpPS560GExIqBN6HmHKLU-Qe0rcrBv5JGNaONm8hngYrJbWJol5iu/pub?output=csv';

// 속성 → 색상 매핑(원하시는 팔레트로 바꿔도 됩니다)
const Map<String, Color> kAttrColor = {
  '불': Color(0xFFE11D48),
  '물': Color(0xFF2563EB),
  '전기': Color(0xFFF59E0B),
  '바람': Color(0xFF10B981),
  '땅': Color(0xFF92400E),
  '빛': Color(0xFFFDE68A),
  '어둠': Color(0xFF312E81),
  '무': Color(0xFF6B7280),
};

/// ============== 모델 ==============
class DigiX {
  final String grade;  // 급 (예: 25급, 18급…)
  final String attr;   // 속성 (예: 불, 물, 전기…)
  final String name;   // 디지몬명
  DigiX({required this.grade, required this.attr, required this.name});
}

class DigiSimple {
  final String name;   // 디지몬명
  DigiSimple(this.name);
}

/// ============== 유틸 ==============
String _exportUrl(String gid) {
  final fmt = kUseCSV ? 'csv' : 'tsv';
  return 'https://docs.google.com/spreadsheets/d/$kSheetId/export?format=$fmt&gid=$gid';
}

Future<List<List<dynamic>>> _fetchTable(String gid) async {
  final res = await http.get(Uri.parse(_exportUrl(gid)));
  if (res.statusCode != 200) {
    throw Exception('HTTP ${res.statusCode}');
  }
  final raw = utf8.decode(res.bodyBytes);
  final rows = csv.CsvToListConverter(
    fieldDelimiter: kUseCSV ? ',' : '\t',
    shouldParseNumbers: false,
  ).convert(raw);
  // 완전히 빈 행은 제거
  return rows.where((r) => r.any((c) => (c?.toString().trim().isNotEmpty ?? false))).toList();
}

List<DigiX> _parseX(List<List<dynamic>> rows) {
  // 기대 헤더: 급 / 속성 / 디지몬 (첫 행을 헤더로 간주)
  if (rows.isEmpty) return [];
  // 헤더 자동 감지(한글 포함 대비)
  final headers = rows.first.map((e) => (e ?? '').toString().trim()).toList();
  final idxGrade = headers.indexWhere((h) => h.contains('급'));
  final idxAttr  = headers.indexWhere((h) => h.contains('속성'));
  final idxName  = headers.indexWhere((h) => h.contains('몬') || h.contains('이름'));
  final gi = idxGrade >= 0 ? idxGrade : 0;
  final ai = idxAttr  >= 0 ? idxAttr  : 1;
  final ni = idxName  >= 0 ? idxName  : 2;

  return rows.skip(1).map((r) {
    String s(dynamic x) => (x ?? '').toString().trim();
    return DigiX(grade: s(gi < r.length ? r[gi] : ''),
        attr : s(ai < r.length ? r[ai] : ''),
        name : s(ni < r.length ? r[ni] : ''));
  }).where((e) => e.name.isNotEmpty).toList();
}

List<DigiSimple> _parseSimple(List<List<dynamic>> rows) {
  if (rows.isEmpty) return [];
  // 첫 행을 헤더로 간주. 이름/디지몬/Name 등 컬럼 자동 탐색.
  final headers = rows.first.map((e) => (e ?? '').toString().trim()).toList();
  final idx = headers.indexWhere((h) => h.contains('몬') || h.contains('이름') || h.toLowerCase() == 'name');
  final i = idx >= 0 ? idx : 0;
  return rows.skip(1).map((r) => DigiSimple(((i < r.length ? r[i] : '') ?? '').toString().trim()))
      .where((e) => e.name.isNotEmpty).toList();
}

/// ============== 화면 ==============
class DigimonBrowserScreen extends StatefulWidget {
  const DigimonBrowserScreen({super.key});
  @override
  State<DigimonBrowserScreen> createState() => _DigimonBrowserScreenState();
}

class _DigimonBrowserScreenState extends State<DigimonBrowserScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  List<DigiX> _x = [];
  List<DigiSimple> _z = [];
  List<DigiSimple> _sp = [];
  bool _loading = true;
  String? _error;

  // UI 상태
  String _query = '';
  String _selAttr = '전체';
  String _selGrade = '전체';
  bool   _gridView = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() { _loading = true; _error = null; });
    try {
      // CSV 한 번만 요청
      final res = await http.get(Uri.parse(kCsvUrl));
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final raw = utf8.decode(res.bodyBytes);

      final rows = csv.CsvToListConverter(
        fieldDelimiter: ',', // TSV면 '\t'로 변경
        shouldParseNumbers: false,
      ).convert(raw);
      // 기존 _parseX() 로직 재사용
      final list = _parseX(rows);

      setState(() {
        _x = list..sort((a,b)=>a.name.compareTo(b.name));
        _z = [];
        _sp = [];
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  // ====== 필터링 로직 (X) ======
  List<DigiX> _filteredX() {
    final q = _query.trim().toLowerCase();
    return _x.where((e) {
      final okAttr  = _selAttr  == '전체' || e.attr == _selAttr;
      final okGrade = _selGrade == '전체' || e.grade == _selGrade;
      final okText  = q.isEmpty || e.name.toLowerCase().contains(q);
      return okAttr && okGrade && okText;
    }).toList();
  }

  // ====== 공용 위젯 ======
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('디지몬 브라우저'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'X 진화'),
            Tab(text: 'Z 진화'),
            Tab(text: 'SP 진화'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _gridView ? '리스트로 보기' : '그리드로 보기',
            onPressed: () => setState(() => _gridView = !_gridView),
            icon: Icon(_gridView ? Icons.view_list : Icons.grid_view_rounded),
          ),
          IconButton(
            tooltip: '새로고침',
            onPressed: _loadAll,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null ? _buildError() : TabBarView(
        controller: _tab,
        children: [
          _buildX(theme),
          _buildSimple(theme, _z, label: 'Z 진화'),
          _buildSimple(theme, _sp, label: 'SP 진화'),
        ],
      )),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('불러오기 실패: $_error'),
      ),
    );
  }

  // ====== X 진화 탭 ======
  Widget _buildX(ThemeData theme) {
    final grades = <String>{'전체', ..._x.map((e) => e.grade).where((s)=>s.isNotEmpty)};
    final attrs  = <String>{'전체', ..._x.map((e) => e.attr).where((s)=>s.isNotEmpty)};

    final list = _filteredX();

    return Column(
      children: [
        _SearchBar(
          hint: '디지몬 검색',
          onChanged: (s) => setState(() => _query = s),
        ),
        _FilterRow(
          items: grades.toList()..sort(),
          selected: _selGrade,
          onChanged: (v) => setState(() => _selGrade = v),
          label: '급',
        ),
        _FilterRow(
          items: attrs.toList()..sort(),
          selected: _selAttr,
          onChanged: (v) => setState(() => _selAttr = v),
          label: '속성',
        ),
        const SizedBox(height: 6),
        Expanded(
          child: _gridView
              ? _XGrid(list)
              : _XList(list),
        ),
      ],
    );
  }

  // ====== Z/SP 공용 탭 ======
  Widget _buildSimple(ThemeData theme, List<DigiSimple> data, {required String label}) {
    final q = _query.trim().toLowerCase();
    final filtered = data.where((e) => q.isEmpty || e.name.toLowerCase().contains(q)).toList();

    return Column(
      children: [
        _SearchBar(
          hint: '$label 검색',
          onChanged: (s) => setState(() => _query = s),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: _gridView
              ? GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 3.8, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _NameCard(filtered[i].name),
          )
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            itemBuilder: (_, i) => _NameTile(filtered[i].name),
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemCount: filtered.length,
          ),
        ),
      ],
    );
  }
}

/// ====== 소형 위젯들 ======

class _SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: hint,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          isDense: true,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final List<String> items;
  final String selected;
  final ValueChanged<String> onChanged;
  final String label;
  const _FilterRow({required this.items, required this.selected, required this.onChanged, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6, top: 10),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          ...items.map((e) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: ChoiceChip(
              label: Text(e),
              selected: e == selected,
              onSelected: (_) => onChanged(e),
            ),
          )),
        ],
      ),
    );
  }
}

class _XGrid extends StatelessWidget {
  final List<DigiX> list;
  const _XGrid(this.list);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 1.9, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: list.length,
      itemBuilder: (_, i) => _XCard(list[i]),
    );
  }
}

class _XList extends StatelessWidget {
  final List<DigiX> list;
  const _XList(this.list);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      itemBuilder: (_, i) => _XTile(list[i]),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: list.length,
    );
  }
}

class _XCard extends StatelessWidget {
  final DigiX e;
  const _XCard(this.e);

  @override
  Widget build(BuildContext context) {
    final attrColor = kAttrColor[e.attr] ?? Colors.blueGrey;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [attrColor.withOpacity(.18), attrColor.withOpacity(.06)],
        ),
        border: Border.all(color: attrColor.withOpacity(.25)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openSheet(context, e.name),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _AvatarBadge(text: e.attr.isNotEmpty ? e.attr[0] : '∙', color: attrColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        _Chip(text: e.grade,  color: attrColor.withOpacity(.14), textColor: attrColor),
                        _Chip(text: e.attr,   color: attrColor.withOpacity(.10), textColor: attrColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _XTile extends StatelessWidget {
  final DigiX e;
  const _XTile(this.e);

  @override
  Widget build(BuildContext context) {
    final attrColor = kAttrColor[e.attr] ?? Colors.blueGrey;
    return ListTile(
      onTap: () => _openSheet(context, e.name),
      leading: _AvatarBadge(text: e.attr.isNotEmpty ? e.attr[0] : '∙', color: attrColor),
      title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Wrap(spacing: 8, children: [
        _Chip(text: e.grade, color: attrColor.withOpacity(.14), textColor: attrColor),
        _Chip(text: e.attr,  color: attrColor.withOpacity(.10), textColor: attrColor),
      ]),
      trailing: const Icon(Icons.chevron_right),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: attrColor.withOpacity(.18)),
      ),
    );
  }
}

class _NameCard extends StatelessWidget {
  final String name;
  const _NameCard(this.name);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openSheet(context, name),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.pets_rounded),
              const SizedBox(width: 10),
              Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700))),
              const Icon(Icons.open_in_new, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameTile extends StatelessWidget {
  final String name;
  const _NameTile(this.name);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.open_in_new, size: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0x22000000))),
      onTap: () => _openSheet(context, name),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _AvatarBadge({required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: color.withOpacity(.15),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  const _Chip({required this.text, required this.color, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

/// 디지몬 이름을 클릭했을 때: 같은 시트 문서 내 해당 탭(이름과 동일한 시트)로 점프 시도
Future<void> _openSheet(BuildContext context, String name) async {
  // 시트 탭 이름과 디지몬 이름이 동일하다는 가정.
  // 문서의 sheetId를 알 수 없다면 검색 링크로 대체할 수도 있음.
  final url = 'https://docs.google.com/spreadsheets/d/$kSheetId/edit#gid=0&range=A1&fvid=1&rm=minimal&search="${Uri.encodeComponent(name)}"';
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}