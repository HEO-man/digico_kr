import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'web_util.dart';

class RotationScreen extends StatelessWidget {
  const RotationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로테이션 정보'),
      ),
      body: const RotationContent(),
    );
  }
}


class RotationContent extends StatefulWidget {
  const RotationContent({super.key});

  @override
  State<RotationContent> createState() => _RotationContentState();
}

class _RotationContentState extends State<RotationContent> {
  String selectedType = '신규 정보';
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    _loadJson('https://HEO-man.github.io/digimon-codex-kr/data/new.json');
  }

  Future<void> _loadJson(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          data = jsonData;
        });
      }
    } catch (e) {
      debugPrint('로테이션 정보 로딩 실패: $e');
    }
  }

  void _openWebView(String title, String url) {
    if (kIsWeb) {
      openUrl(url);
      return;
    }

    final isGoogleDocs = url.contains('docs.google.com');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(
                isGoogleDocs ? url.replaceFirst('/edit', '/preview') : url,
              ),
            ),
            initialSettings: InAppWebViewSettings(
              userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.0',
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ToggleButtons(
            isSelected: [selectedType == '신규 정보', selectedType == '복각 정보'],
            onPressed: (index) {
              setState(() {
                selectedType = index == 0 ? '신규 정보' : '복각 정보';
                _loadJson(index == 0
                    ? 'https://HEO-man.github.io/digimon-codex-kr/data/new.json'
                    : 'https://HEO-man.github.io/digimon-codex-kr/data/reprint.json');
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('신규 정보'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('복각 정보'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return ListTile(
                title: Text(item['title']),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _openWebView(item['title'], item['url']),
              );
            },
          ),
        ),
      ],
    );
  }
}