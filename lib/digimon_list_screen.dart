import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'digimon_model.dart';
import 'digimon_registration.dart';

class DigimonListScreen extends StatefulWidget {
  const DigimonListScreen({super.key});

  @override
  State<DigimonListScreen> createState() => _DigimonListScreenState();
}

class _DigimonListScreenState extends State<DigimonListScreen> {
  late Future<List<DigimonEntry>> _digimonEntriesFuture;

  @override
  void initState() {
    super.initState();
    _digimonEntriesFuture = fetchDigimonEntries();
  }

  Future<List<DigimonEntry>> fetchDigimonEntries() async {
    final res = await http.get(Uri.parse(
      'https://heo-man.github.io/digimon-codex-kr/data/digi_illustration/digimons.json',
    ));
    if (res.statusCode == 200) {
      final List<dynamic> decoded = json.decode(res.body);
      return decoded.map((e) => DigimonEntry.fromJson(e)).toList();
    } else {
      throw Exception('디지몬 목록을 불러오지 못했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('디지몬 목록')),
      body: FutureBuilder<List<DigimonEntry>>(
        future: _digimonEntriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }

          final entries = snapshot.data ?? [];

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                title: Text(entry.name),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  final url =
                      'https://heo-man.github.io/digimon-codex-kr/data/digi_illustration/${entry.folderName}/script.json';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DigimonRegistrationScreen(
                        existingScriptUrl: url,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}