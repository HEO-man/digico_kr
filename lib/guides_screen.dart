import 'package:flutter/foundation.dart'; // <-- add this at the top
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

class GuideItem {
  final String title;
  final String url;

  GuideItem({required this.title, required this.url});

  factory GuideItem.fromJson(Map<String, dynamic> json) {
    return GuideItem(title: json['title'], url: json['url']);
  }
}

class GuidesScreen extends StatefulWidget {
  const GuidesScreen({super.key});

  @override
  State<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  List<GuideItem> guideItems = [];

  String _normalizeUrlForWeb(String url) {
    if (kIsWeb && (url.contains('youtube.com/watch') || url.contains('youtu.be/'))) {
      final videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null) {
        return 'https://www.youtube.com/embed/$videoId';
      }
    }
    return url;
  }

  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  Future<void> _loadGuides() async {
    final url = 'https://HEO-man.github.io/digimon-codex-kr/data/guides.json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          guideItems = data.map((e) => GuideItem.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('공략 데이터 로딩 실패: $e');
    }
  }

  void _openWebView(String title, String url) {
    final videoId = YoutubePlayer.convertUrlToId(url);
    if (kIsWeb || videoId == null) {
      final isGoogleDocs = url.contains('docs.google.com');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InAppWebViewScreen(
            title: title,
            url: isGoogleDocs
                ? url.replaceFirst('/edit', '/preview') // Use preview mode
                : url,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => YoutubePlayerScreen(title: title, videoId: videoId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('공략 모음')),
      body: ListView.builder(
        itemCount: guideItems.length,
        itemBuilder: (context, index) {
          final item = guideItems[index];
          return ListTile(
            title: Text(item.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openWebView(item.title, item.url),
          );
        },
      ),
    );
  }
}

class InAppWebViewScreen extends StatelessWidget {
  final String title;
  final String url;

  const InAppWebViewScreen({super.key, required this.title, required this.url});

  String _normalizeUrlForWeb(String url) {
    if (kIsWeb && (url.contains('youtube.com/watch') || url.contains('youtu.be/'))) {
      final videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null) {
        return 'https://www.youtube.com/embed/$videoId';
      }
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(_normalizeUrlForWeb(url)),
        ),
      ),
    );
  }
}


class YoutubePlayerScreen extends StatefulWidget {
  final String title;
  final String videoId;

  const YoutubePlayerScreen({super.key, required this.title, required this.videoId});

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: _controller),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.title)),
          body: player,
        );
      },
    );
  }
}