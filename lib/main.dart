import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_menu_screen.dart';
import 'digimon_registration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeMenuScreen(),
      debugShowCheckedModeBanner: false,
      title: 'Digimon Codex',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        tooltipTheme: TooltipThemeData(
          textStyle: TextStyle(fontSize: 14, color: Colors.white),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          waitDuration: Duration(milliseconds: 300),
          showDuration: Duration(seconds: 5),
        ),
      ),
      routes: {
        '/digimon_registration': (context) => const DigimonRegistrationScreen(),
      },
    );
  }
}

class Digimon {
  final String name;
  final int grade;
  final String type;
  final String element;
  final String folderName;
  final String role;

  Digimon({
    required this.name,
    required this.grade,
    required this.type,
    required this.element,
    required this.folderName,
    required this.role,
  });
}

class DigimonListScreen extends StatefulWidget {
  const DigimonListScreen({super.key});

  @override
  State<DigimonListScreen> createState() => _DigimonListScreenState();
}

class _DigimonListScreenState extends State<DigimonListScreen> {
  List<Digimon> allDigimons = [];
  String? selectedType;
  int? selectedGrade;
  String? selectedElement;
  String? selectedRole;

  @override
  void initState() {
    super.initState();
    _loadDigimons();
  }

  Future<void> _loadDigimons() async {
    final url = 'https://HEO-man.github.io/digimon-codex-kr/data/digi_illustration/digimons.json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          allDigimons = jsonData.map((e) => Digimon(
            name: e['name'],
            grade: e['grade'],
            type: _localizedType(e['type']),
            element: _localizedElement(e['element']),
            folderName: e['folderName'],
            role: e['role'],
          )).toList()
            ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        });
      } else {
        debugPrint('HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('데이터 로딩 실패: $e');
    }
  }

  String _localizedType(String type) {
    switch (type.toLowerCase()) {
      case 'vaccine':
        return '백신';
      case 'virus':
        return '바이러스';
      case 'data':
        return '데이터';
      default:
        return type;
    }
  }

  String _localizedElement(String element) {
    switch (element.toLowerCase()) {
      case 'fire':
        return '불';
      case 'water':
        return '물';
      case 'nature':
      case 'plant':
        return '풀';
      case 'earth':
        return '땅';
      case 'wind':
        return '바람';
      case 'light':
        return '빛';
      case 'dark':
        return '어둠';
      case 'thunder':
      case 'electric':
        return '전기';
      default:
        return element;
    }
  }

  List<Digimon> get filteredDigimons {
    return allDigimons.where((digimon) {
      final gradeMatch = selectedGrade == null || selectedGrade == digimon.grade;
      final typeMatch = selectedType == null || selectedType == digimon.type;
      final elementMatch = selectedElement == null || selectedElement == digimon.element;
      final roleMatch = selectedRole == null || selectedRole == digimon.role;
      return gradeMatch && typeMatch && elementMatch && roleMatch;
    }).toList();
  }
  void _showRoleSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: ['딜러', '서포터', '컨트롤러'].map((role) {
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(role),
              onTap: () {
                setState(() {
                  selectedRole = role;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showGradeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [8, 11, 14, 18, 22, 25].map((grade) {
            return ListTile(
              leading: _gradeIcon(grade),
              title: Text('$grade급'),
              onTap: () {
                setState(() {
                  selectedGrade = grade;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showTypeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: ['백신', '바이러스', '데이터'].map((type) {
            return ListTile(
              leading: _typeIcon(type),
              title: Text(type),
              onTap: () {
                setState(() {
                  selectedType = type;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showElementSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: ['불', '물', '풀', '땅', '바람','전기', '빛', '어둠'].map((element) {
            return ListTile(
              leading: _elementIcon(element),
              title: Text(element),
              onTap: () {
                setState(() {
                  selectedElement = element;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('디지몬 목록', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final TextEditingController _passwordController = TextEditingController();
                  return AlertDialog(
                    title: const Text('관리자 비밀번호'),
                    content: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: '비밀번호를 입력하세요',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_passwordController.text == 'ilu') {
                            Navigator.of(context).pop();
                            Navigator.pushNamed(context, '/digimon_registration');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('비밀번호가 틀렸습니다')),
                            );
                          }
                        },
                        child: const Text('확인'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/digi_illustration/header_main_001.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showGradeSelector(context),
                  child: const Text('등급'),
                ),
                ElevatedButton(
                  onPressed: () => _showTypeSelector(context),
                  child: const Text('타입'),
                ),
                ElevatedButton(
                  onPressed: () => _showElementSelector(context),
                  child: const Text('속성'),
                ),
                ElevatedButton(
                  onPressed: () => _showRoleSelector(context),
                  child: const Text('역할군'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (selectedGrade != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InputChip(
                        avatar: _gradeIcon(selectedGrade!),
                        label: Text('${selectedGrade}급'),
                        onDeleted: () => setState(() => selectedGrade = null),
                      ),
                    ),
                  if (selectedType != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InputChip(
                        avatar: _typeIcon(selectedType!),
                        label: Text('타입: $selectedType'),
                        onDeleted: () => setState(() => selectedType = null),
                      ),
                    ),
                  if (selectedElement != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InputChip(
                        avatar: _elementIcon(selectedElement!),
                        label: Text('속성: $selectedElement'),
                        onDeleted: () => setState(() => selectedElement = null),
                      ),
                    ),
                  if (selectedRole != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InputChip(
                        avatar: const Icon(Icons.person, size: 14),
                        label: Text('역할: $selectedRole'),
                        onDeleted: () => setState(() => selectedRole = null),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDigimons.length,
              itemBuilder: (context, index) {
                final digimon = filteredDigimons[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'https://HEO-man.github.io/digimon-codex-kr/data/digi_illustration/${digimon.folderName}/illustration.png',
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                'https://HEO-man.github.io/digimon-codex-kr/data/digi_illustration/${digimon.folderName}/ilst.png',
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/icon/ic_missing.png',
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                digimon.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _TagChip(label: '${digimon.grade}급', icon: _gradeIcon(digimon.grade)),
                                  const SizedBox(width: 6),
                                  _TagChip(label: digimon.type, icon: _typeIcon(digimon.type)),
                                  const SizedBox(width: 6),
                                  _TagChip(label: digimon.element, icon: _elementIcon(digimon.element)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).inkWell(onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DigimonDetailScreen(digimon: digimon),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradeIcon(int grade) {
    switch (grade) {
      case 8:
        return Image.asset('assets/icon/grade/grade_8.png', width: 16, height: 16);
      case 11:
        return Image.asset('assets/icon/grade/grade_11.png', width: 16, height: 16);
      case 14:
        return Image.asset('assets/icon/grade/grade_14.png', width: 16, height: 16);
      case 18:
        return Image.asset('assets/icon/grade/grade_18.png', width: 16, height: 16);
      case 22:
        return Image.asset('assets/icon/grade/grade_22.png', width: 16, height: 16);
      case 25:
        return Image.asset('assets/icon/grade/grade_25.png', width: 16, height: 16);
      default:
        return const Icon(Icons.help_outline, size: 14, color: Colors.grey);
    }
  }

  Widget? _typeIcon(String type) {
    switch (type) {
      case '백신':
        return Image.asset('assets/icon/type/ic_vaccine.png', width: 14, height: 14);
      case '바이러스':
        return Image.asset('assets/icon/type/ic_virus.png', width: 14, height: 14);
      case '데이터':
        return Image.asset('assets/icon/type/ic_data.png', width: 14, height: 14);
      default:
        return null;
    }
  }

  Widget _elementIcon(String element) {
    switch (element) {
      case '불':
        return Image.asset('assets/icon/element/ic_fire.png', width: 14, height: 14);
      case '물':
        return Image.asset('assets/icon/element/ic_water.png', width: 14, height: 14);
      case '풀':
        return Image.asset('assets/icon/element/ic_nature.png', width: 14, height: 14);
      case '땅':
        return Image.asset('assets/icon/element/ic_earth.png', width: 14, height: 14);
      case '바람':
        return Image.asset('assets/icon/element/ic_wind.png', width: 14, height: 14);
      case '빛':
        return Image.asset('assets/icon/element/ic_light.png', width: 14, height: 14);
      case '어둠':
        return Image.asset('assets/icon/element/ic_dark.png', width: 14, height: 14);
      case '전기':
        return Image.asset('assets/icon/element/ic_thunder.png', width: 14, height: 14);
      default:
        return const Icon(Icons.help_outline, size: 14, color: Colors.grey);
    }
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Widget? icon;

  const _TagChip({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

extension on Widget {
  Widget inkWell({required VoidCallback onTap}) {
    return InkWell(onTap: onTap, child: this);
  }
}

class DigimonDetailScreen extends StatefulWidget {
  final Digimon digimon;

  const DigimonDetailScreen({required this.digimon});

  @override
  State<DigimonDetailScreen> createState() => _DigimonDetailScreenState();
}

class _DigimonDetailScreenState extends State<DigimonDetailScreen> {
  int selectedBreakthrough = 0;

  // 전투효과 데이터: 이름별 Map
  Map<String, Map<String, dynamic>> battleEffectsByName = {};

  // Helper to normalize subSkills to a List<Map<String, dynamic>>
  List<Map<String, dynamic>> _normalizeSubSkills(dynamic subSkills) {
    if (subSkills is List) {
      return subSkills.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
    } else if (subSkills is Map) {
      return subSkills.values
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();
    } else {
      return [];
    }
  }

  Future<void> _loadBattleEffects() async {
    final List<String> sources = [
      'https://heo-man.github.io/digimon-codex-kr/data/effects/battle_buff.json',
      'https://heo-man.github.io/digimon-codex-kr/data/effects/battle_debuff.json',
      'https://heo-man.github.io/digimon-codex-kr/data/effects/battle_control.json',
      'https://heo-man.github.io/digimon-codex-kr/data/weather/weather_script.json',
    ];

    for (final url in sources) {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final jsonMap = json.decode(res.body) as Map<String, dynamic>;
        for (final entry in jsonMap.entries) {
          final data = entry.value as Map<String, dynamic>;
          final keyName = data['name'];
          if (keyName != null) {
            battleEffectsByName[keyName] = data;
          }
        }
      }
    }
  }

  // 전투효과 이름을 일반 단어 매칭으로 추출
  List<String> extractEffectNamesFromText(String text) {
    final List<String> matched = [];
    final words = text.split(RegExp(r'[\s,.!?()\[\]{}"“”]+')); // 단어 구분자 기준 분리

    for (final name in battleEffectsByName.keys) {
      if (name == '비') {
        // '비'가 단독으로 등장했을 때만 인식
        if (words.contains('비')) {
          matched.add(name);
        }
      } else if (text.contains(name)) {
        matched.add(name);
      }
    }

    return matched.toSet().toList();
  }

  // 스킬 설명에서 전투효과명을 RichText로 하이라이트 및 Tooltip 처리
  Widget buildEffectRichText(String description) {
    final effectNames = battleEffectsByName.keys.toList();
    final spans = <InlineSpan>[];
    int currentIndex = 0;
    final matches = <Map<String, dynamic>>[];
    // Build a combined RegExp for all effect names, allowing Korean particles after
    for (final effectName in effectNames) {
      // r'\b' + RegExp.escape(effectName) + r'(을|를|이|가|에|은|는|과|와|이나|나)?\b'
      final pattern = RegExp(r'(^|[^가-힣A-Za-z0-9])' + RegExp.escape(effectName) + r'(을|를|이|가|에|은|는|과|와|이나|나)?(?![가-힣])');

      for (final match in pattern.allMatches(description)) {
        matches.add({
          'start': match.start,
          'end': match.end,
          'effectName': effectName,
          'matchedText': match.group(0),
        });
      }
    }
    // Sort matches by start index
    matches.sort((a, b) => a['start'].compareTo(b['start']));
    int lastIndex = 0;
    for (final match in matches) {
      if (match['start'] >= lastIndex) {
        // Add text before match
        if (match['start'] > lastIndex) {
          spans.add(TextSpan(
            text: description.substring(lastIndex, match['start']),
            style: const TextStyle(color: Colors.black),
          ));
        }
        final effect = battleEffectsByName[match['effectName']];
        if (effect != null) {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () {
                // Optional: handle tap
              },
              child: Tooltip(
                message: effect['description'] ?? '',
                preferBelow: false,
                child: Text(
                  match['matchedText'],
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ));
        } else {
          spans.add(TextSpan(
            text: match['matchedText'],
            style: const TextStyle(color: Colors.black),
          ));
        }
        lastIndex = match['end'];
      }
    }
    // Add remaining text
    if (lastIndex < description.length) {
      spans.add(TextSpan(
        text: description.substring(lastIndex),
        style: const TextStyle(color: Colors.black),
      ));
    }
    return RichText(
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _loadScript(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final script = snapshot.data as Map<String, dynamic>;
          final skills = script['skills'] is Map<String, dynamic>
              ? (script['skills'] as Map<String, dynamic>).values
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()
              : [];
          // If passive exists, append as a fourth skill
          if (script.containsKey('passive')) {
            skills.add({
              'name': script['passive']['name'],
              'type': 'Passive',
              'description': script['passive']['description'],
            });
          }
          final core = script['core'] ?? script['exclusiveCore'];
          final images = script['images'];
          final breakthrough = script['breakthrough'] is Map<String, dynamic>
              ? script['breakthrough'] as Map<String, dynamic>
              : null;

          // Tab controller for 2 tabs
          return DefaultTabController(
            length: 2,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.digimon.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 0),
                            blurRadius: 8,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    background: Image.network(
                      'https://HEO-man.github.io/digimon-codex-kr/data/digi_illustration/${widget.digimon.folderName}/illustration.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(
                          'https://HEO-man.github.io/digimon-codex-kr/data/digi_illustration/${widget.digimon.folderName}/ilst.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/icon/ic_missing.png',
                              fit: BoxFit.cover,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                // Tabs below illustration
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: '스킬 정보'),
                        Tab(text: '각성 효과'),
                      ],
                    ),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: TabBarView(
                    children: [
                      // Skill Info Tab
                      ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text("⭐ 각성 단계: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ElevatedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                    ),
                                    builder: (_) {
                                      return ListView.separated(
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        itemCount: 7,
                                        separatorBuilder: (_, __) => Divider(height: 1),
                                        itemBuilder: (context, i) {
                                          final effect = breakthrough != null ? breakthrough[i.toString()] : null;
                                          return ListTile(
                                            leading: Text('⭐', style: TextStyle(fontSize: 18)),
                                            title: Text(
                                              "$i성",
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                            ),
                                            subtitle: effect != null && effect is Map<String, dynamic> && effect['effect'] != null
                                                ? Text(effect['effect'], style: const TextStyle(fontSize: 13))
                                                : null,
                                            onTap: () {
                                              setState(() => selectedBreakthrough = i);
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                child: Text('$selectedBreakthrough성'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Render all skills, including passive (last one), regardless of type
                          for (int i = 0; i < skills.length; i++) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Builder(
                                builder: (context) {
                                  final skill = skills[i];
                                  final skillHasSubSkills = skill.containsKey('subSkills') && _normalizeSubSkills(skill['subSkills']).isNotEmpty;
                                  final subSkills = _normalizeSubSkills(skill['subSkills']);
                                  final skillImages = (images != null && images is List && images.length > i) ? images[i] : null;
                                  final List<Widget> widgets = [];
                                  widgets.add(
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 이미지 로딩: subSkills가 있으면 배열, 아니면 단일 이미지
                                        Builder(
                                          builder: (context) {
                                            String? skillImage;
                                            if (skillHasSubSkills && skillImages is List && skillImages.isNotEmpty) {
                                              skillImage = skillImages[0];
                                            } else if (!skillHasSubSkills && skillImages is String) {
                                              skillImage = skillImages;
                                            } else if (!skillHasSubSkills && skillImages is List && skillImages.isNotEmpty) {
                                              skillImage = skillImages[0];
                                            }
                                            skillImage ??= 'skill_0${i + 1}.png';
                                            return Image.network(
                                              'https://HEO-man.github.io/digimon-codex-kr/data/digi_illustration/${widget.digimon.folderName}/$skillImage',
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${skill['name'] ?? '스킬 ${i + 1}'}${skill['ap'] != null && skill['ap'].toString().isNotEmpty ? ' (${skill['ap']})' : ''}',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              const SizedBox(height: 4),
                                              if (!skillHasSubSkills) ...[
                                                buildEffectRichText(skill['description'] ?? ''),
                                              ] else ...[
                                                // mainSkill 정보
                                                if (skill['mainSkill'] != null) ...[
                                                  Text(
                                                    '${skill['mainSkill']['name'] ?? ''}'
                                                    '${skill['mainSkill']['ap'] != null && skill['mainSkill']['ap'].toString().isNotEmpty ? ' (${skill['mainSkill']['ap']})' : ''}',
                                                    style: const TextStyle(fontSize: 15),
                                                  ),
                                                  buildEffectRichText(skill['mainSkill']['description'] ?? ''),
                                                ],
                                                const SizedBox(height: 8),
                                                // subSkills 반복
                                                for (int j = 0; j < subSkills.length; j++) ...[
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        if (skillImages is List && skillImages.length > j + 1)
                                                          ClipRRect(
                                                            borderRadius: BorderRadius.circular(4),
                                                            child: Image.network(
                                                              'https://HEO-man.github.io/digimon-codex-kr/data/digi_illustration/${widget.digimon.folderName}/${skillImages[j + 1]}',
                                                              width: 40,
                                                              height: 40,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        if (skillImages is List && skillImages.length > j + 1)
                                                          const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                '${j + 1}. '
                                                                '${subSkills[j]['ap'] != null ? '(${subSkills[j]['ap']}) ' : ''}'
                                                                '',
                                                                style: const TextStyle(fontSize: 15),
                                                              ),
                                                              buildEffectRichText(subSkills[j]['description'] ?? ''),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  // 각성 효과 출력 (선택한 별 등급까지 누적 효과 표시)
                                  if (breakthrough != null && selectedBreakthrough > 0) {
                                    for (int star = 1; star <= selectedBreakthrough; star++) {
                                      final effectEntry = breakthrough[star.toString()];
                                      if (effectEntry != null && effectEntry is Map && effectEntry['effect'] != null && effectEntry['skillIndex'] == i) {
                                        widgets.add(
                                          Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Text(
                                              '⭐ ${star}성 효과: ${effectEntry['effect']}',
                                              style: const TextStyle(fontSize: 14, color: Colors.deepOrange),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: widgets,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(thickness: 1),
                            const SizedBox(height: 12),
                          ],
                          if (core != null) ...[
                            const Divider(),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '중앙칩 효과',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Image.network(
                                'https://HEO-man.github.io/digimon-codex-kr/data/digi_illustration/core_chip.png',
                                height: 56,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('- ${core['exclusiveEffect']}'),
                                  Text('- ${core['suitableEffect']}'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                      // 각성 효과 Tab
                      ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        children: [
                          const Text('각성 효과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          // 각성 설명 렌더링 부분 (1~6성 항상 표시)
                          Builder(
                            builder: (context) {
                              if (breakthrough != null && breakthrough is Map<String, dynamic>) {
                                final List<Widget> effects = [];
                                for (int i = 1; i <= 6; i++) {
                                  final entry = breakthrough[i.toString()];
                                  if (entry != null && entry is Map<String, dynamic>) {
                                    final effect = entry['effect'];
                                    final statsBoost = entry['statsBoost'];
                                    if (effect != null) {
                                      effects.add(
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: Text(
                                            '⭐ ${i}성: $effect',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    if (statsBoost != null) {
                                      effects.add(
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: Text(
                                            '📈 보너스 스탯: $statsBoost',
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                                return effects.isEmpty
                                    ? const Text(
                                        '해당 별 단계의 각성 효과 정보가 없습니다.',
                                        style: TextStyle(color: Colors.redAccent, fontSize: 15),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: effects),
                                      );
                              } else {
                                return const Text(
                                  '해당 별 단계의 각성 효과 정보가 없습니다.',
                                  style: TextStyle(color: Colors.redAccent, fontSize: 15),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadScript() async {
    final url = 'https://HEO-man.github.io/digimon-codex-kr/data/digi_illustration/${widget.digimon.folderName}/script.json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw Exception('Invalid script.json format: expected Map');
        }
        final script = decoded;
        // Only handle object format for 'skills' (ignore list format to avoid crashing)
        final List<Map<String, dynamic>> skills = [];
        if (script['skills'] is Map<String, dynamic>) {
          skills.addAll((script['skills'] as Map<String, dynamic>)
              .values
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)));
        }
        // Auto-generate images array if missing or incomplete, based on new skills structure
        if (!script.containsKey('images')) {
          final List<dynamic> images = [];
          for (int i = 0; i < skills.length; i++) {
            if (skills[i].containsKey('subSkills') && skills[i]['subSkills'] is List && (skills[i]['subSkills'] as List).isNotEmpty) {
              final List<String> skillImages = ['skill_0${i + 1}.png'];
              for (int j = 0; j < (skills[i]['subSkills'] as List).length; j++) {
                skillImages.add('skill_0${i + 1}_0${j + 1}.png');
              }
              images.add(skillImages);
            } else {
              images.add('skill_0${i + 1}.png');
            }
          }
          script['images'] = images;
        }
        if (!script.containsKey('breakthrough') || script['breakthrough'] is! Map<String, dynamic>) {
          script['breakthrough'] = null;
        }
        await _loadBattleEffects();
        return script;
      } else {
        debugPrint('HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('스크립트 로딩 실패: $e');
    }
    return {'breakthrough': null};
  }
}

// Sticky tab bar delegate for SliverPersistentHeader
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _StickyTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}