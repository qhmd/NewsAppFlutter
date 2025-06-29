import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:newsapp/presentation/widget/bookmark_toast.dart';

class AppIcon extends StatelessWidget {
  final url;

  const AppIcon({super.key, required this.url});

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak dapat membuka $url';
    }
  }

  void launchEmail(String url) async {
  final Uri emailUri = Uri.parse(
    "mailto:example@email.com?subject=News&body=${url}",
  );

  try {
    if (!await launchUrl(emailUri)) {
      showCustomToast("Tidak dapat membuka email.");
    }
  } catch (e) {
    showCustomToast("Coming Soon");
  }
}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(width: 30),
            _SocialItem(
              button: FlutterSocialButton(
                onTap: () {
                  _launchUrl("https://wa.me/?text=${url}");
                },
                mini: true,
                showLabel: true,
                buttonType: ButtonType.whatsapp,
              ),
              label: 'WhatsApp',
            ),
            const SizedBox(width: 30),
            _SocialItem(
              button: FlutterSocialButton(
                onTap: () {
                  launchEmail(url);
                },
                mini: true,
                title: 'Email',
              ),
              label: 'Email',
            ),
            const SizedBox(width: 30),
            _SocialItem(
              button: FlutterSocialButton(
                onTap: () {
                  _launchUrl("https://www.tiktok.com/@username");
                },
                mini: true,
                showLabel: true,
                buttonType: ButtonType.tiktok,
              ),
              label: 'Pesan\nTikTok',
            ),
            const SizedBox(width: 30),
            _SocialItem(
              button: FlutterSocialButton(
                onTap: () {
                  _launchUrl("https://www.instagram.com/qhmd_22");
                },
                mini: true,
                showLabel: true,
                buttonType: ButtonType.instagram,
              ),
              label: 'Pesan\nInstagram',
            ),
            const SizedBox(width: 30),
            _SocialItem(
              button: FlutterSocialButton(
                onTap: () {
                  _launchUrl(
                    "https://line.me/R/msg/text/?Halo%20saya%20ingin%20bertanya",
                  );
                },
                mini: true,
                showLabel: true,
                buttonType: ButtonType.line,
              ),
              label: 'Line',
            ),
            const SizedBox(width: 30),
          ],
        ),
      ),
    );
  }
}

class _SocialItem extends StatelessWidget {
  final Widget button;
  final String label;

  const _SocialItem({required this.button, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        const SizedBox(height: 12),
        SizedBox(
          height: 30,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
