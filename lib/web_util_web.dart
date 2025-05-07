// web_util_web.dart
import 'dart:html' as html;

void openUrl(String url) {
  html.window.open(url, '_blank');
}