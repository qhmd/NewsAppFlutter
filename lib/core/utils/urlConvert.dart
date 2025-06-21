import 'dart:convert';

String encodeUrl(String url) {
  return base64Url.encode(utf8.encode(url));
}

String decodeUrl(String encoded) {
  return utf8.decode(base64Url.decode(encoded));
}
