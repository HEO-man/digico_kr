// ignore_for_file: undefined_prefixed_name
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// 웹 전용 iframe
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui;

// 모바일 WebView
import 'package:webview_flutter/webview_flutter.dart';

// 로컬 캐시
import 'package:shared_preferences/shared_preferences.dart';

/// Google Sheets
const String kSpreadsheetId = '1k82S88guiGngWAabee2uKSmtWUgw0nJCC69R0w1Ou28';
const String kGoogleApiKey  = 'AIzaSyCQfKRlaKpKKV_HTywJ8CHFnTmfXZ901PM';

/// “웹에 게시” E-베이스 (/pub 직전까지)
const String kPublishedEBase =
    'https://docs.google.com/spreadsheets/d/e/2PACX-1vTx-6Id_QsgH9RT_GgelBNyzhSfpPS560GExIqBN6HmHKLU-Qe0rcrBv5JGNaONm8hngYrJbWJol5iu';

/// 캐시 키
const String _kGidIndexKey = 'gid_index_v1';      // title→gid 맵(JSON)
const String _kGidIndexAt  = 'gid_index_at_v1';   // ISO8601 (스테일 판단용)
const Duration _kIndexTtl   = Duration(days: 1);

/// 제목 정규화
String _normSpaces(String s) =>
    s.replaceAll(RegExp(r'[\u00A0\u2007\u202F\t]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
String _stripSpaces(String s) =>
    s.replaceAll(RegExp(r'[\u00A0\u2007\u202F\s\t]+'), '');

List<String> _cands(String name) {
  final a = name;
  final b = _normSpaces(name);
  final c = _stripSpaces(name);
  final lc = <String>{a.toLowerCase(), b.toLowerCase(), c.toLowerCase()};
  return lc.toList();
}

/// GID 인덱스(제목→gid) 관리
class _GidIndex {
  Map<String, int> map = {}; // key: lowercased/normalized title

  static Future<_GidIndex> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kGidIndexKey);
    final at  = prefs.getString(_kGidIndexAt);

    final idx = _GidIndex();
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      idx.map = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    }

    // TTL 지난 경우 새로 빌드
    final isStale = () {
      if (at == null) return true;
      final t = DateTime.tryParse(at);
      if (t == null) return true;
      return DateTime.now().difference(t) > _kIndexTtl;
    }();

    if (idx.map.isEmpty || isStale) {
      await idx._rebuildAndSave(prefs);
    }
    return idx;
  }

  Future<void> _rebuildAndSave(SharedPreferences prefs) async {
    final uri = Uri.parse(
      'https://sheets.googleapis.com/v4/spreadsheets/$kSpreadsheetId'
          '?fields=sheets(properties(sheetId,title))&key=$kGoogleApiKey',
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      // 인덱스가 아예 없다면 예외, 기존이 있으면 그대로 사용
      if (map.isEmpty) {
        throw Exception('Sheets API 실패: ${res.statusCode} / ${res.body}');
      }
      return;
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final sheets = (json['sheets'] as List?) ?? [];

    final next = <String, int>{};
    for (final s in sheets) {
      final props = s['properties'] as Map<String, dynamic>?;
      if (props == null) continue;
      final title = (props['title'] ?? '').toString();
      final id    = props['sheetId'] as int?;
      if (id == null || title.isEmpty) continue;

      // 세 가지 형태 모두 인덱싱
      for (final key in {
        title.toLowerCase(),
        _normSpaces(title).toLowerCase(),
        _stripSpaces(title).toLowerCase(),
      }) {
        next[key] = id;
      }
    }

    map = next;
    await prefs.setString(_kGidIndexKey, jsonEncode(map));
    await prefs.setString(_kGidIndexAt, DateTime.now().toIso8601String());
  }

  int? findByName(String name) {
    for (final key in _cands(name)) {
      final gid = map[key];
      if (gid != null) return gid;
    }
    return null;
  }
}

class DigimonDetailScreen extends StatefulWidget {
  final String digimonName;
  const DigimonDetailScreen({super.key, required this.digimonName});

  @override
  State<DigimonDetailScreen> createState() => _DigimonDetailScreenState();
}

class _DigimonDetailScreenState extends State<DigimonDetailScreen> {
  bool _loading = true;
  String? _error;
  int? _gid;
  String? _openUrl;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) _injectPreconnect(); // 웹: 핸드셰이크 단축
    _resolveAndLoad();
  }

  // 웹: preconnect로 TLS 핸드셰이크 선행
  void _injectPreconnect() {
    for (final host in [
      'https://docs.google.com',
      'https://ssl.gstatic.com',
      'https://fonts.gstatic.com',
    ]) {
      final link = html.LinkElement()
        ..rel = 'preconnect'
        ..href = host
        ..crossOrigin = '';
      html.document.head?.append(link);
    }
  }

  Future<void> _resolveAndLoad() async {
    setState(() {
      _loading = true;
      _error = null;
      _gid = null;
      _openUrl = null;
    });

    try {
      // 1) gid 인덱스 로드(없거나 오래되면 1회 새로 빌드)
      final index = await _GidIndex.load();

      // 2) 바로 캐시에서 조회
      final gid = index.findByName(widget.digimonName);
      if (gid == null) {
        setState(() {
          _loading = false;
          _error = '해당 디지몬 시트 탭을 찾지 못했습니다.\n'
              '• 탭 이름이 목록과 정확히 같은지\n'
              '• [파일] > [웹에 게시]에서 “전체 문서”를 게시했는지 확인해 주세요.';
        });
        return;
      }

      final url = '$kPublishedEBase/pubhtml?gid=$gid'
          '&single=true&widget=true&headers=false';

      setState(() {
        _gid = gid;
        _openUrl = url;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = '불러오기 실패\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.digimonName;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_openUrl != null)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: '원문 열기(브라우저)',
              onPressed: () =>
                  launchUrl(Uri.parse(_openUrl!), mode: LaunchMode.externalApplication),
            ),
        ],
      ),
      body: _loading
          ? _skeleton()
          : (_error != null
          ? _errorView(_error!)
          : (_gid == null
          ? const Center(child: Text('탭 gid를 찾지 못했습니다.'))
          : _sheetEmbed(_openUrl!))),
    );
  }

  /// 스켈레톤(체감속도 개선)
  Widget _skeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: 8,
      itemBuilder: (_, i) => Container(
        height: i == 0 ? 160 : 54,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0x0F000000),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _errorView(String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 36),
          const SizedBox(height: 10),
          Text(msg, textAlign: TextAlign.center),
        ],
      ),
    ),
  );

  /// 웹: iframe 임베드 / 모바일: WebView
  Widget _sheetEmbed(String url) {
    if (kIsWeb) {
      final viewType =
          'sheet-iframe-${url.hashCode}-${Random().nextInt(1 << 20)}';
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(viewType, (int _) {
        final iframe = html.IFrameElement()
          ..src = url
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%'
          ..setAttribute('loading', 'lazy'); // 지연 로딩
        return iframe;
      });
      return HtmlElementView(viewType: viewType);
    } else {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..loadRequest(Uri.parse(url));
      return WebViewWidget(controller: controller);
    }
  }
}