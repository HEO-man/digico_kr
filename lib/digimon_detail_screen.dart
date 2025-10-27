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

// 모바일 WebView (pubspec에 webview_flutter 의존성 추가 필수)
import 'package:webview_flutter/webview_flutter.dart';

/// ─────────────────────────────────────────────
/// Google Sheets 설정
/// ─────────────────────────────────────────────
/// 스프레드시트 ID (주소의 /d/<ID>/ 부분)
const String kSpreadsheetId = '1k82S88guiGngWAabee2uKSmtWUgw0nJCC69R0w1Ou28';

/// Google Sheets API 키 (시트 목록 조회용)
const String kGoogleApiKey   = 'AIzaSyCQfKRlaKpKKV_HTywJ8CHFnTmfXZ901PM';

/// “웹에 게시”에서 얻은 E-베이스 URL
/// ─ 주의: 끝이 /pub 또는 /pub?output=csv 로 끝나는 전체 링크가 아니라,
///        그 앞부분(…/e/2PACX-… 까지)만 남긴 베이스여야 함!
const String kPublishedEBase =
    'https://docs.google.com/spreadsheets/d/e/2PACX-1vTx-6Id_QsgH9RT_GgelBNyzhSfpPS560GExIqBN6HmHKLU-Qe0rcrBv5JGNaONm8hngYrJbWJol5iu';

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

  // 이름 정규화(공백/특수공백)
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
    return [a, if (b != a) b, if (c != a && c != b) c];
  }

  @override
  void initState() {
    super.initState();
    _resolveAndLoad();
  }

  Future<void> _resolveAndLoad() async {
    setState(() {
      _loading = true;
      _error = null;
      _gid = null;
      _openUrl = null;
    });

    try {
      // 1) 탭 목록에서 시트 제목 매칭 → sheetId(gid) 찾기
      final gid = await _findGidByTitleCandidates(_cands(widget.digimonName));
      if (gid == null) {
        setState(() {
          _loading = false;
          _error = '해당 디지몬 시트 탭을 찾지 못했습니다.\n'
              '• 탭 이름이 목록과 정확히 같은지\n'
              '• [파일] > [웹에 게시]에서 “전체 문서”를 게시했는지 확인해 주세요.';
        });
        return;
      }

      // 2) “웹에 게시” E-베이스로 해당 gid만 임베드
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

  /// Google Sheets API v4로 모든 탭 목록(title, sheetId) 조회 → 후보명과 매칭
  Future<int?> _findGidByTitleCandidates(List<String> candidates) async {
    final uri = Uri.parse(
      'https://sheets.googleapis.com/v4/spreadsheets/$kSpreadsheetId'
          '?fields=sheets(properties(sheetId,title))&key=$kGoogleApiKey',
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Sheets API 실패: ${res.statusCode} / ${res.body}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final sheets = (json['sheets'] as List?) ?? [];

    for (final s in sheets) {
      final props = s['properties'] as Map<String, dynamic>?;
      if (props == null) continue;
      final title = (props['title'] ?? '').toString();
      final id    = props['sheetId'] as int?;
      if (id == null || title.isEmpty) continue;

      for (final cand in candidates) {
        if (title == cand ||
            _normSpaces(title) == cand ||
            _stripSpaces(title) == cand) {
          return id;
        }
      }
    }
    return null;
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
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
          ? _errorView(_error!)
          : (_gid == null
          ? const Center(child: Text('탭 gid를 찾지 못했습니다.'))
          : _sheetEmbed(_openUrl!))),
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

  /// 웹: iframe 임베드 / 모바일: webview_flutter
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
          ..style.height = '100%';
        return iframe;
      });
      return HtmlElementView(viewType: viewType);
    } else {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(url));
      return WebViewWidget(controller: controller);
    }
  }
}