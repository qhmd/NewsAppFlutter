// file: webview_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewModal extends StatefulWidget {
  final String url;

  const WebViewModal({super.key, required this.url});

  @override
  State<WebViewModal> createState() => _WebViewModalState();
}

class _WebViewModalState extends State<WebViewModal> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();

    // Load URL setelah frame animasi muncul
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadRequest(Uri.parse(widget.url));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primaryContainer,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
