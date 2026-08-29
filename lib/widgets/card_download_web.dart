import 'dart:js_interop';
import 'package:web/web.dart' as web;

void downloadFile(String base64Data, String fileName) {
  final String dataUrl = 'data:image/png;base64,$base64Data';
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = dataUrl;
  anchor.download = fileName;
  anchor.style.display = 'none';
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
}
