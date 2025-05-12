// web_import.dart
import 'dart:html' as html;
import 'dart:convert';

void importScriptJson(Function(String json) onJsonLoaded) {
  final uploadInput = html.FileUploadInputElement()..accept = '.json';
  uploadInput.click();
  uploadInput.onChange.listen((e) {
    final file = uploadInput.files?.first;
    if (file == null) return;
    final reader = html.FileReader();
    reader.readAsText(file);
    reader.onLoadEnd.listen((event) {
      onJsonLoaded(reader.result as String);
    });
  });
}

Future<void> uploadToServer({
  required String filename,
  required String folder,
  required String base64Data,
}) async {
  const repo = 'digimon-codex-kr';

  final response = await html.HttpRequest.request(
    'https://digimon-pusher.onrender.com/push',
    method: 'POST',
    requestHeaders: {'Content-Type': 'application/json'},
    sendData: jsonEncode({
      'filename': filename,
      'repo': repo,
      'folder': folder,
      'content_base64': base64Data,
    }),
  );

  if (response.status != 200) {
    throw Exception('업로드 실패: ${response.statusText}');
  }
}