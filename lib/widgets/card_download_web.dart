import 'dart:js_interop' as js;

@js.JS('cityLoomDownloadCard')
external bool _jsDownloadCard(js.JSString base64Data, js.JSString fileName);

void downloadFile(String base64Data, String fileName) {
  try {
    _jsDownloadCard(base64Data.toJS, fileName.toJS);
  } catch (e) {
    // Fallback if JS function is missing
  }
}
