import 'package:flutter/material.dart';

class ActionIconService extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? colors;
  final VoidCallback onTap;

  const ActionIconService({required this.icon, required this.label, this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              radius: 33,
              child: Icon(icon, color: colors ?? Colors.black),
            ),
            SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _AppIcon extends StatelessWidget {
  final String label;
  final String asset;
  final VoidCallback onTap;

  const _AppIcon({required this.label, required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade100,
            radius: 24,
            backgroundImage: AssetImage(asset),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
