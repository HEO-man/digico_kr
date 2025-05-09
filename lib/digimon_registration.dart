import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:html' as html;
import 'dart:convert';

import 'package:flutter/material.dart';

class DigimonRegistrationScreen extends StatefulWidget {
  const DigimonRegistrationScreen({super.key});

  @override
  State<DigimonRegistrationScreen> createState() =>
      _DigimonRegistrationScreenState();
}

class _DigimonRegistrationScreenState extends State<DigimonRegistrationScreen> {
  // script.json 자동 생성 결과를 저장하는 필드
  String? _generatedScriptJson;
  // Controllers for mainSkill's subSkills (메인 스킬 선택형)
  final List<Map<String, TextEditingController>> mainSubSkillControllers = [];
  final TextEditingController nameController = TextEditingController();
  Uint8List? _illustration;
  // Map to store skill images by filename
  final Map<String, Uint8List> _skillImageMap = {};
  final ImagePicker _picker = ImagePicker();
  // Helper to pick and store PNG-converted skill image by filename
  Future<void> _pickAndStoreSkillImage(String filename, [VoidCallback? refresh]) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final pngBytes = await _convertToPng(await picked.readAsBytes());
      setState(() {
        _skillImageMap[filename] = pngBytes;
      });
      if (refresh != null) refresh();
    }
  }

  String? selectedElement;
  String? selectedType;
  String? selectedRole;

  final TextEditingController normalSkillNameController =
      TextEditingController();
  final TextEditingController normalSkillTypeController =
      TextEditingController();
  final TextEditingController normalSkillApController = TextEditingController();
  final TextEditingController normalSkillDescController =
      TextEditingController();

  final TextEditingController mainSkillNameController = TextEditingController();
  final TextEditingController mainSkillTypeController = TextEditingController();
  final TextEditingController mainSkillApController = TextEditingController();
  final TextEditingController mainSkillDescController = TextEditingController();

  final TextEditingController subSkillNameController = TextEditingController();
  final TextEditingController subSkillTypeController = TextEditingController();
  final TextEditingController subSkillApController = TextEditingController();
  final TextEditingController subSkillDescController = TextEditingController();

  final TextEditingController passiveSkillNameController =
      TextEditingController();
  final TextEditingController passiveSkillDescController =
      TextEditingController();

  // Controllers/fields for exclusiveCore and breakthrough
  final TextEditingController exclusiveEffectController =
      TextEditingController();
  final TextEditingController suitableEffectController =
      TextEditingController();
  final List<TextEditingController> breakthroughEffects = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> breakthroughStats = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<int?> breakthroughSkillIndexes = List.filled(6, null);

  void _importScriptJson() {
    final uploadInput = html.FileUploadInputElement()..accept = '.json';
    uploadInput.click();
    uploadInput.onChange.listen((e) {
      final file = uploadInput.files?.first;
      if (file == null) return;
      final reader = html.FileReader();
      reader.readAsText(file);
      reader.onLoadEnd.listen((event) {
        final data = json.decode(reader.result as String);
        setState(() {
          nameController.text = data['name'] ?? '';
          selectedElement = _matchElement(data['element']);
          selectedType = _matchType(data['type']);
          selectedRole =
              ['딜러', '서포터', '컨트롤러'].contains(data['role'])
                  ? data['role']
                  : null;

          final skills = data['skills'] ?? {};
          normalSkillNameController.text = skills['normalSkill']?['name'] ?? '';
          normalSkillTypeController.text = skills['normalSkill']?['type'] ?? '';
          normalSkillApController.text = skills['normalSkill']?['ap'] ?? '';
          normalSkillDescController.text =
              skills['normalSkill']?['description'] ?? '';

          mainSkillNameController.text = skills['mainSkill']?['name'] ?? '';
          mainSkillTypeController.text = skills['mainSkill']?['type'] ?? '';
          mainSkillApController.text = skills['mainSkill']?['ap'] ?? '';
          mainSkillDescController.text =
              skills['mainSkill']?['description'] ?? '';
          // Populate mainSubSkillControllers from mainSkill['subSkills']
          final subSkills = skills['mainSkill']?['subSkills'];
          mainSubSkillControllers.clear();
          if (subSkills is List) {
            for (final sub in subSkills) {
              final name = TextEditingController(text: sub['name'] ?? '');
              final type = TextEditingController(text: sub['type'] ?? '');
              final ap = TextEditingController(text: sub['ap'] ?? '');
              final desc = TextEditingController(text: sub['description'] ?? '');
              mainSubSkillControllers.add({
                'name': name,
                'type': type,
                'ap': ap,
                'description': desc,
              });
            }
          }

          subSkillNameController.text = skills['subSkill']?['name'] ?? '';
          subSkillTypeController.text = skills['subSkill']?['type'] ?? '';
          subSkillApController.text = skills['subSkill']?['ap'] ?? '';
          subSkillDescController.text =
              skills['subSkill']?['description'] ?? '';

          passiveSkillNameController.text =
              skills['passiveSkill']?['name'] ?? '';
          passiveSkillDescController.text =
              skills['passiveSkill']?['description'] ?? '';

          // Populate exclusiveCore fields
          exclusiveEffectController.text =
              data['exclusiveCore']?['exclusiveEffect'] ?? '';
          suitableEffectController.text =
              data['exclusiveCore']?['suitableEffect'] ?? '';

          // Populate breakthrough fields
          final bt = data['breakthrough'] ?? {};
          for (int i = 0; i < 6; i++) {
            breakthroughEffects[i].text = bt['${i + 1}']?['effect'] ?? '';
            breakthroughStats[i].text = bt['${i + 1}']?['statsBoost'] ?? '';
            breakthroughSkillIndexes[i] = bt['${i + 1}']?['skillIndex'];
          }
        });
      });
    });
  }

  Future<Uint8List> _convertToPng(Uint8List originalBytes) async {
    final decodedImage = img.decodeImage(originalBytes);
    if (decodedImage == null) throw Exception("이미지 디코딩 실패");
    final pngBytes = img.encodePng(decodedImage);
    return Uint8List.fromList(pngBytes);
  }

  @override
  void dispose() {
    nameController.dispose();
    normalSkillNameController.dispose();
    normalSkillTypeController.dispose();
    normalSkillApController.dispose();
    normalSkillDescController.dispose();
    mainSkillNameController.dispose();
    mainSkillTypeController.dispose();
    mainSkillApController.dispose();
    mainSkillDescController.dispose();
    subSkillNameController.dispose();
    subSkillTypeController.dispose();
    subSkillApController.dispose();
    subSkillDescController.dispose();
    passiveSkillNameController.dispose();
    passiveSkillDescController.dispose();
    exclusiveEffectController.dispose();
    suitableEffectController.dispose();
    for (final c in breakthroughEffects) {
      c.dispose();
    }
    for (final c in breakthroughStats) {
      c.dispose();
    }
    // Dispose mainSubSkillControllers
    for (final group in mainSubSkillControllers) {
      group.values.forEach((c) => c.dispose());
    }
    mainSubSkillControllers.clear();
    super.dispose();
  }

  void _resetSkillInputs() {
    nameController.clear();
    selectedElement = null;
    selectedType = null;
    selectedRole = null;

    normalSkillNameController.clear();
    normalSkillTypeController.clear();
    normalSkillApController.clear();
    normalSkillDescController.clear();

    mainSkillNameController.clear();
    mainSkillTypeController.clear();
    mainSkillApController.clear();
    mainSkillDescController.clear();

    subSkillNameController.clear();
    subSkillTypeController.clear();
    subSkillApController.clear();
    subSkillDescController.clear();

    passiveSkillNameController.clear();
    passiveSkillDescController.clear();

    exclusiveEffectController.clear();
    suitableEffectController.clear();

    for (final c in breakthroughEffects) {
      c.clear();
    }
    for (final c in breakthroughStats) {
      c.clear();
    }
    for (int i = 0; i < breakthroughSkillIndexes.length; i++) {
      breakthroughSkillIndexes[i] = null;
    }

    // Dispose and clear mainSubSkillControllers
    for (final group in mainSubSkillControllers) {
      group.values.forEach((c) => c.dispose());
    }
    mainSubSkillControllers.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('디지몬 등록')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "기본 정보",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '디지몬 이름 / 폴더 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "일러스트 등록",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('일러스트 업로드'),
              onPressed: () async {
                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (picked != null) {
                  final pngFile = await _convertToPng(
                    await picked.readAsBytes(),
                  );
                  setState(() {
                    _illustration = pngFile;
                  });
                }
              },
            ),
            if (_illustration != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.memory(_illustration!, height: 120),
              ),
            const SizedBox(height: 24),
            const Text(
              "스킬 설명 등록",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  icon: Icon(
                    _generatedScriptJson != null ? Icons.check_circle : Icons.text_snippet,
                    color: _generatedScriptJson != null ? Colors.green : null,
                  ),
                  label: Text(
                    _generatedScriptJson != null ? '스킬 정보 입력됨' : '스킬 정보 입력',
                    style: TextStyle(
                      color: _generatedScriptJson != null ? Colors.green : null,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _generatedScriptJson != null ? Colors.green : Colors.grey,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return Dialog(
                          insetPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 32),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 1080),
                            child: StatefulBuilder(
                              builder: (context, localSetState) {
                                // Local copies for dropdowns
                                String? localElement = selectedElement;
                                String? localType = selectedType;
                                String? localRole = selectedRole;
                                return Scaffold(
                                  resizeToAvoidBottomInset: false,
                                  appBar: AppBar(
                                    title: const Text('스킬 정보 입력'),
                                    automaticallyImplyLeading: false,
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _resetSkillInputs();
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                        ),
                                        child: const Text('초기화'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          final requiredFields = [
                                            normalSkillNameController.text,
                                            normalSkillTypeController.text,
                                            normalSkillDescController.text,
                                            mainSkillNameController.text,
                                            mainSkillTypeController.text,
                                            mainSkillDescController.text,
                                            subSkillNameController.text,
                                            subSkillTypeController.text,
                                            subSkillDescController.text,
                                            passiveSkillNameController.text,
                                            passiveSkillDescController.text,
                                            exclusiveEffectController.text,
                                            suitableEffectController.text,
                                            ...breakthroughEffects.map((c) => c.text),
                                            ...breakthroughStats.map((c) => c.text),
                                          ];

                                          if (requiredFields.any((text) => text.trim().isEmpty)) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("스킬 정보 및 효과 항목을 모두 입력해주세요.")),
                                            );
                                            return;
                                          }

                                          final jsonData = {
                                            "name": nameController.text,
                                            "element": selectedElement,
                                            "type": selectedType,
                                            "role": selectedRole,
                                            "skills": {
                                              "normalSkill": {
                                                "name": normalSkillNameController.text,
                                                "type": normalSkillTypeController.text,
                                                "ap": normalSkillApController.text,
                                                "description": normalSkillDescController.text,
                                              },
                                              "mainSkill": {
                                                "name": mainSkillNameController.text,
                                                "type": mainSkillTypeController.text,
                                                "ap": mainSkillApController.text,
                                                "description": mainSkillDescController.text,
                                                "subSkills": mainSubSkillControllers.map((s) => {
                                                  "name": s["name"]!.text,
                                                  "type": s["type"]!.text,
                                                  "ap": s["ap"]!.text,
                                                  "description": s["description"]!.text,
                                                }).toList(),
                                              },
                                              "subSkill": {
                                                "name": subSkillNameController.text,
                                                "type": subSkillTypeController.text,
                                                "ap": subSkillApController.text,
                                                "description": subSkillDescController.text,
                                              },
                                              "passiveSkill": {
                                                "name": passiveSkillNameController.text,
                                                "description": passiveSkillDescController.text,
                                              }
                                            },
                                            "exclusiveCore": {
                                              "exclusiveEffect": exclusiveEffectController.text,
                                              "suitableEffect": suitableEffectController.text,
                                            },
                                            "breakthrough": Map.fromEntries(
                                              List.generate(6, (i) {
                                                return MapEntry("${i + 1}", {
                                                  "effect": breakthroughEffects[i].text,
                                                  "statsBoost": breakthroughStats[i].text,
                                                  "skillIndex": breakthroughSkillIndexes[i],
                                                });
                                              }),
                                            ),
                                          };

                                          setState(() {
                                            _generatedScriptJson = jsonEncode(jsonData);
                                          });

                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                        ),
                                        child: const Text('저장'),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                  body: SingleChildScrollView(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // ... (keep the same dialog widget as before)
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.upload_file),
                                          label: const Text("script.json 불러오기"),
                                          onPressed: () {
                                            final uploadInput =
                                                html.FileUploadInputElement()
                                                  ..accept = '.json';
                                            uploadInput.click();
                                            uploadInput.onChange.listen((e) {
                                              final file = uploadInput.files?.first;
                                              if (file == null) return;
                                              final reader = html.FileReader();
                                              reader.readAsText(file);
                                              reader.onLoadEnd.listen((event) {
                                                final data = json.decode(
                                                  reader.result as String,
                                                );
                                                localSetState(() {
                                                  nameController.text =
                                                      data['name'] ?? '';
                                                  selectedElement = _matchElement(
                                                    data['element'],
                                                  );
                                                  selectedType = _matchType(
                                                    data['type'],
                                                  );
                                                  selectedRole =
                                                      [
                                                            '딜러',
                                                            '서포터',
                                                            '컨트롤러',
                                                          ].contains(data['role'])
                                                          ? data['role']
                                                          : null;
                                                  // Update local copies
                                                  localElement = selectedElement;
                                                  localType = selectedType;
                                                  localRole = selectedRole;

                                                  final skills =
                                                      data['skills'] ?? {};
                                                  normalSkillNameController.text =
                                                      skills['normalSkill']?['name'] ??
                                                      '';
                                                  normalSkillTypeController.text =
                                                      skills['normalSkill']?['type'] ??
                                                      '';
                                                  normalSkillApController.text =
                                                      skills['normalSkill']?['ap'] ??
                                                      '';
                                                  normalSkillDescController.text =
                                                      skills['normalSkill']?['description'] ??
                                                      '';

                                                  mainSkillNameController.text =
                                                      skills['mainSkill']?['name'] ??
                                                      '';
                                                  mainSkillTypeController.text =
                                                      skills['mainSkill']?['type'] ??
                                                      '';
                                                  mainSkillApController.text =
                                                      skills['mainSkill']?['ap'] ??
                                                      '';
                                                  mainSkillDescController.text =
                                                      skills['mainSkill']?['description'] ??
                                                      '';
                                                  // Populate mainSubSkillControllers from mainSkill['subSkills']
                                                  final subSkills = skills['mainSkill']?['subSkills'];
                                                  mainSubSkillControllers.clear();
                                                  if (subSkills is List) {
                                                    for (final sub in subSkills) {
                                                      final name = TextEditingController(text: sub['name'] ?? '');
                                                      final type = TextEditingController(text: sub['type'] ?? '');
                                                      final ap = TextEditingController(text: sub['ap'] ?? '');
                                                      final desc = TextEditingController(text: sub['description'] ?? '');
                                                      mainSubSkillControllers.add({
                                                        'name': name,
                                                        'type': type,
                                                        'ap': ap,
                                                        'description': desc,
                                                      });
                                                    }
                                                  }

                                                  subSkillNameController.text =
                                                      skills['subSkill']?['name'] ??
                                                      '';
                                                  subSkillTypeController.text =
                                                      skills['subSkill']?['type'] ??
                                                      '';
                                                  subSkillApController.text =
                                                      skills['subSkill']?['ap'] ??
                                                      '';
                                                  subSkillDescController.text =
                                                      skills['subSkill']?['description'] ??
                                                      '';

                                                  passiveSkillNameController.text =
                                                      skills['passiveSkill']?['name'] ??
                                                      '';
                                                  passiveSkillDescController.text =
                                                      skills['passiveSkill']?['description'] ??
                                                      '';

                                                  exclusiveEffectController.text =
                                                      data['exclusiveCore']?['exclusiveEffect'] ??
                                                      '';
                                                  suitableEffectController.text =
                                                      data['exclusiveCore']?['suitableEffect'] ??
                                                      '';

                                                  final bt =
                                                      data['breakthrough'] ?? {};
                                                  for (int i = 0; i < 6; i++) {
                                                    breakthroughEffects[i].text =
                                                        bt['${i + 1}']?['effect'] ??
                                                        '';
                                                    breakthroughStats[i].text =
                                                        bt['${i + 1}']?['statsBoost'] ??
                                                        '';
                                                    breakthroughSkillIndexes[i] =
                                                        bt['${i + 1}']?['skillIndex'];
                                                  }
                                                });
                                              });
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          "디지몬 스크립트 입력",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: nameController,
                                          decoration: const InputDecoration(
                                            labelText: '디지몬 이름 / 폴더 이름',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                value: localElement,
                                                decoration: const InputDecoration(
                                                  labelText: '속성',
                                                  border: OutlineInputBorder(),
                                                ),
                                                items: [
                                                  '불', '물', '풀', '땅', '바람', '전기', '빛', '어둠'
                                                ].map((e) => DropdownMenuItem(
                                                      value: e,
                                                      child: Row(
                                                        children: [
                                                          Image.asset(
                                                            'assets/icon/element/ic_${_elementKey(e)}.png',
                                                            width: 20,
                                                            height: 20,
                                                          ),
                                                          const SizedBox(width: 6),
                                                          Text(e),
                                                        ],
                                                      ),
                                                    )).toList(),
                                                onChanged: (v) {
                                                  localSetState(() {
                                                    localElement = v;
                                                    selectedElement = v;
                                                  });
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                value: localType,
                                                decoration: const InputDecoration(
                                                  labelText: '타입',
                                                  border: OutlineInputBorder(),
                                                ),
                                                items: ['백신', '바이러스', '데이터'].map((e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        'assets/icon/type/${_typeKey(e)}.png',
                                                        width: 20,
                                                        height: 20,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(e),
                                                    ],
                                                  ),
                                                )).toList(),
                                                onChanged: (v) {
                                                  localSetState(() {
                                                    localType = v;
                                                    selectedType = v;
                                                  });
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                value: localRole,
                                                decoration: const InputDecoration(
                                                  labelText: '역할군',
                                                  border: OutlineInputBorder(),
                                                ),
                                                items: ['딜러', '서포터', '컨트롤러'].map((e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(e),
                                                )).toList(),
                                                onChanged: (v) {
                                                  localSetState(() {
                                                    localRole = v;
                                                    selectedRole = v;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          children: [
                                            const Text(
                                              "노멀 스킬",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            TextButton.icon(
                                              icon: const Icon(Icons.image),
                                              label: const Text("이미지 등록"),
                                              onPressed: () => _pickAndStoreSkillImage('skill_01.png', () => localSetState(() {})),
                                            ),
                                            if (_skillImageMap.containsKey('skill_01.png')) ...[
                                              const SizedBox(width: 6),
                                              const Icon(Icons.check_circle, color: Colors.green),
                                              const SizedBox(width: 6),
                                              SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Image.memory(
                                                  _skillImageMap['skill_01.png']!,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: normalSkillNameController,
                                          decoration: const InputDecoration(labelText: '스킬명'),
                                        ),
                                        const SizedBox(height: 6),
                                        TextField(
                                          controller: normalSkillTypeController,
                                          decoration: const InputDecoration(labelText: '속성/타입'),
                                        ),
                                        const SizedBox(height: 6),
                                        TextField(
                                          controller: normalSkillApController,
                                          decoration: const InputDecoration(labelText: 'AP'),
                                        ),
                                        const SizedBox(height: 6),
                                        TextField(
                                          controller: normalSkillDescController,
                                          decoration: const InputDecoration(labelText: '설명'),
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            const Text(
                                              "메인 스킬",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            TextButton.icon(
                                              icon: const Icon(Icons.image),
                                              label: const Text("이미지 등록"),
                                              onPressed: () => _pickAndStoreSkillImage('skill_02.png', () => localSetState(() {})),
                                            ),
                                            if (_skillImageMap.containsKey('skill_02.png')) ...[
                                              const SizedBox(width: 6),
                                              const Icon(Icons.check_circle, color: Colors.green),
                                              const SizedBox(width: 6),
                                              SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Image.memory(
                                                  _skillImageMap['skill_02.png']!,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: mainSkillNameController,
                                          decoration: const InputDecoration(labelText: '스킬명'),
                                        ),
                                        const SizedBox(height: 6),
                                        TextField(
                                          controller: mainSkillTypeController,
                                          decoration: const InputDecoration(labelText: '속성/타입'),
                                        ),
                                        const SizedBox(height: 6),
                                        TextField(
                                          controller: mainSkillApController,
                                          decoration: const InputDecoration(labelText: 'AP'),
                                        ),
                                        const SizedBox(height: 6),
                                        TextField(
                                          controller: mainSkillDescController,
                                          decoration: const InputDecoration(labelText: '설명'),
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Text(
                                              "서브스킬 추가",
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 10),
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.add),
                                              label: const Text('추가'),
                                              onPressed: () {
                                                localSetState(() {
                                                  mainSubSkillControllers.add({
                                                    'name': TextEditingController(),
                                                    'type': TextEditingController(),
                                                    'ap': TextEditingController(),
                                                    'description': TextEditingController(),
                                                  });
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            for (int i = 0; i < mainSubSkillControllers.length; i++)
                                              Card(
                                                margin: const EdgeInsets.symmetric(vertical: 6),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text("서브스킬 #${i + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                                              TextButton.icon(
                                                                icon: const Icon(Icons.image),
                                                                label: const Text("이미지 등록"),
                                                                onPressed: () => _pickAndStoreSkillImage('skill_02_${(i + 1).toString().padLeft(2, '0')}.png', () => localSetState(() {})),
                                                              ),
                                                              if (_skillImageMap.containsKey('skill_02_${(i + 1).toString().padLeft(2, '0')}.png')) ...[
                                                                const SizedBox(width: 6),
                                                                const Icon(Icons.check_circle, color: Colors.green),
                                                                const SizedBox(width: 6),
                                                                SizedBox(
                                                                  width: 40,
                                                                  height: 40,
                                                                  child: Image.memory(
                                                                    _skillImageMap['skill_02_${(i + 1).toString().padLeft(2, '0')}.png']!,
                                                                    fit: BoxFit.contain,
                                                                  ),
                                                                ),
                                                              ],
                                                            ],
                                                          ),
                                                          const Spacer(),
                                                          IconButton(
                                                            icon: const Icon(Icons.delete, color: Colors.red),
                                                            onPressed: () {
                                                              localSetState(() {
                                                                mainSubSkillControllers[i].values.forEach((c) => c.dispose());
                                                                mainSubSkillControllers.removeAt(i);
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                      TextField(
                                                        controller: mainSubSkillControllers[i]['name'],
                                                        decoration: const InputDecoration(labelText: '스킬명'),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      TextField(
                                                        controller: mainSubSkillControllers[i]['type'],
                                                        decoration: const InputDecoration(labelText: '속성/타입'),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      TextField(
                                                        controller: mainSubSkillControllers[i]['ap'],
                                                        decoration: const InputDecoration(labelText: 'AP'),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      TextField(
                                                        controller: mainSubSkillControllers[i]['description'],
                                                        decoration: const InputDecoration(labelText: '설명'),
                                                        maxLines: 2,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            const Text(
                                              "서브스킬",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            TextButton.icon(
                                              icon: const Icon(Icons.image),
                                              label: const Text("이미지 등록"),
                                              onPressed: () => _pickAndStoreSkillImage('skill_03.png', () => localSetState(() {})),
                                            ),
                                            if (_skillImageMap.containsKey('skill_03.png')) ...[
                                              const SizedBox(width: 6),
                                              const Icon(Icons.check_circle, color: Colors.green),
                                              const SizedBox(width: 6),
                                              SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Image.memory(
                                                  _skillImageMap['skill_03.png']!,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: subSkillNameController,
                                          decoration: const InputDecoration(labelText: '스킬명'),
                                        ),
                                        const SizedBox(height: 6),
                                        TextField(
                                          controller: subSkillTypeController,
                                          decoration: const InputDecoration(labelText: '속성/타입'),
                                        ),
                                        const SizedBox(height: 6),
                                        TextField(
                                          controller: subSkillApController,
                                          decoration: const InputDecoration(labelText: 'AP'),
                                        ),
                                        const SizedBox(height: 6),
                                        TextField(
                                          controller: subSkillDescController,
                                          decoration: const InputDecoration(labelText: '설명'),
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            const Text(
                                              "패시브 스킬",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            TextButton.icon(
                                              icon: const Icon(Icons.image),
                                              label: const Text("이미지 등록"),
                                              onPressed: () => _pickAndStoreSkillImage('skill_04.png', () => localSetState(() {})),
                                            ),
                                            if (_skillImageMap.containsKey('skill_04.png')) ...[
                                              const SizedBox(width: 6),
                                              const Icon(Icons.check_circle, color: Colors.green),
                                              const SizedBox(width: 6),
                                              SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Image.memory(
                                                  _skillImageMap['skill_04.png']!,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: passiveSkillNameController,
                                          decoration: const InputDecoration(labelText: '스킬명'),
                                        ),
                                        const SizedBox(height: 6),
                                        TextField(
                                          controller: passiveSkillDescController,
                                          decoration: const InputDecoration(labelText: '설명'),
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          "전용 코어 효과",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: exclusiveEffectController,
                                          decoration: const InputDecoration(labelText: '전용 효과'),
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: suitableEffectController,
                                          decoration: const InputDecoration(labelText: '적합 효과'),
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          "돌파 효과",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        Column(
                                          children: List.generate(6, (i) {
                                            return Card(
                                              margin: const EdgeInsets.symmetric(vertical: 4),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("⭐ ${i + 1}성", style: const TextStyle(fontWeight: FontWeight.bold)),
                                                    TextField(
                                                      controller: breakthroughEffects[i],
                                                      decoration: const InputDecoration(labelText: '효과 설명'),
                                                      maxLines: 2,
                                                    ),
                                                    const SizedBox(height: 6),
                                                    TextField(
                                                      controller: breakthroughStats[i],
                                                      decoration: const InputDecoration(labelText: '능력치 증가'),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        const Text("스킬 인덱스: "),
                                                        DropdownButton<int>(
                                                          value: (breakthroughSkillIndexes[i] != null &&
                                                                  breakthroughSkillIndexes[i]! < 4 + mainSubSkillControllers.length)
                                                              ? breakthroughSkillIndexes[i]
                                                              : null,
                                                          hint: const Text('선택'),
                                                          items: List.generate(
                                                            4 + mainSubSkillControllers.length,
                                                            (idx) {
                                                              if (idx == 0) {
                                                                return const DropdownMenuItem(
                                                                  value: 0,
                                                                  child: Text('노멀'),
                                                                );
                                                              } else if (idx == 1) {
                                                                return const DropdownMenuItem(
                                                                  value: 1,
                                                                  child: Text('메인'),
                                                                );
                                                              } else if (idx == 2) {
                                                                return const DropdownMenuItem(
                                                                  value: 2,
                                                                  child: Text('서브'),
                                                                );
                                                              } else if (idx == 3) {
                                                                return const DropdownMenuItem(
                                                                  value: 3,
                                                                  child: Text('패시브'),
                                                                );
                                                              } else {
                                                                return DropdownMenuItem(
                                                                  value: idx,
                                                                  child: Text('메인서브${idx - 3}'),
                                                                );
                                                              }
                                                            },
                                                          ),
                                                          onChanged: (v) {
                                                            localSetState(() {
                                                              breakthroughSkillIndexes[i] = v;
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  _generatedScriptJson != null
                      ? '✅ 스킬 정보가 입력되었습니다.'
                      : '⚠️ 아직 스킬 정보가 입력되지 않았습니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: _generatedScriptJson != null ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            // Skill image registration section removed; now handled per skill section
            const SizedBox(height: 40),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("디지몬 이름을 입력해주세요.")),
                        );
                        return;
                      }
                      if (_illustration == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("일러스트를 업로드해주세요.")),
                        );
                        return;
                      }
                      if (_skillImageMap.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("스킬 이미지를 업로드해주세요.")),
                        );
                        return;
                      }
                      if ([
                        normalSkillNameController.text,
                        normalSkillTypeController.text,
                        normalSkillDescController.text,
                        mainSkillNameController.text,
                        mainSkillTypeController.text,
                        mainSkillDescController.text,
                        subSkillNameController.text,
                        subSkillTypeController.text,
                        subSkillDescController.text,
                        passiveSkillNameController.text,
                        passiveSkillDescController.text,
                        exclusiveEffectController.text,
                        suitableEffectController.text,
                        ...breakthroughEffects.map((c) => c.text),
                        ...breakthroughStats.map((c) => c.text),
                      ].any((text) => text.trim().isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("스킬 정보 및 효과 항목을 모두 입력해주세요.")),
                        );
                        return;
                      }

                      final folderName = nameController.text.trim();

                      // Upload script.json
                      final scriptBytes = utf8.encode(_generatedScriptJson ?? '{}');
                      final scriptB64 = base64Encode(scriptBytes);

                      final scriptRes = await html.HttpRequest.request(
                        'https://digimon-pusher.onrender.com/push',
                        method: 'POST',
                        requestHeaders: {'Content-Type': 'application/json'},
                        sendData: jsonEncode({
                          'filename': 'script.json',
                          'repo': 'digimon-codex-kr',
                          'path': '$folderName/script.json',
                          'content_base64': scriptB64,
                        }),
                      );

                      if (scriptRes.status != 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("script.json 업로드 실패")),
                        );
                        return;
                      }

                      // Upload illustration
                      final illustB64 = base64Encode(_illustration!);
                      await html.HttpRequest.request(
                        'https://digimon-pusher.onrender.com/push',
                        method: 'POST',
                        requestHeaders: {'Content-Type': 'application/json'},
                        sendData: jsonEncode({
                          'filename': 'illustration.png',
                          'repo': 'digimon-codex-kr',
                          'path': '$folderName/illustration.png',
                          'content_base64': illustB64,
                        }),
                      );

                      // Upload skill images
                      for (final entry in _skillImageMap.entries) {
                        final b64 = base64Encode(entry.value);
                        await html.HttpRequest.request(
                          'https://digimon-pusher.onrender.com/push',
                          method: 'POST',
                          requestHeaders: {'Content-Type': 'application/json'},
                          sendData: jsonEncode({
                            'filename': entry.key,
                            'repo': 'digimon-codex-kr',
                            'path': '$folderName/${entry.key}',
                            'content_base64': b64,
                          }),
                        );
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("디지몬 등록이 완료되었습니다.")),
                      );
                    },
                    child: const Text("디지몬 등록 완료"),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // _saveScriptJson 함수는 더 이상 사용되지 않습니다.
}

String _elementKey(String e) {
  switch (e) {
    case '불':
      return 'fire';
    case '물':
      return 'water';
    case '풀':
      return 'nature';
    case '땅':
      return 'earth';
    case '바람':
      return 'wind';
    case '전기':
      return 'thunder';
    case '빛':
      return 'light';
    case '어둠':
      return 'dark';
    default:
      return 'unknown';
  }
}

String _typeKey(String type) {
  switch (type) {
    case '백신':
      return 'ic_vaccine';
    case '바이러스':
      return 'ic_virus';
    case '데이터':
      return 'ic_data';
    default:
      return 'unknown';
  }
}

String? _matchElement(String? value) {
  switch (value?.toLowerCase()) {
    case '불':
    case 'fire':
      return '불';
    case '물':
    case 'water':
      return '물';
    case '풀':
    case 'plant':
    case 'nature':
      return '풀';
    case '땅':
    case 'earth':
      return '땅';
    case '바람':
    case 'wind':
      return '바람';
    case '전기':
    case 'thunder':
    case 'electric':
      return '전기';
    case '빛':
    case 'light':
      return '빛';
    case '어둠':
    case 'dark':
      return '어둠';
    default:
      return null;
  }
}

String? _matchType(String? value) {
  switch (value?.toLowerCase()) {
    case '백신':
    case 'vaccine':
      return '백신';
    case '바이러스':
    case 'virus':
      return '바이러스';
    case '데이터':
    case 'data':
      return '데이터';
    default:
      return null;
  }
}

