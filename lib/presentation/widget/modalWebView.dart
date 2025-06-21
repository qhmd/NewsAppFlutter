import 'package:flutter/material.dart';
import 'package:newsapp/presentation/screens/news/WebViewModal.dart';

void openWebViewModal(BuildContext context, String url) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.onPrimary,
      useSafeArea: true,
      enableDrag: false,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 1,
        child: WebViewModal(url: url),
      ),
    );
  }