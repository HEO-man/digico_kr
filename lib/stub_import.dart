// stub_import.dart
Future<void> uploadToServer({
  required String filename,
  required String folder,
  required String base64Data,
}) async {
  throw UnsupportedError('uploadToServer는 웹에서만 사용할 수 있습니다.');
}

// stub_import.dart
void importScriptJson(Function(String json) onJsonLoaded) {
  throw UnsupportedError('importScriptJson은 웹에서만 사용할 수 있습니다.');
}