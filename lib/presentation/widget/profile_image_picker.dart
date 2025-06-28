// lib/widgets/profile_image_picker.dart

import 'package:flutter/material.dart';
import 'dart:io';

class ProfileImagePicker extends StatelessWidget {
  final File? imageFile;
  final String? photoURL;
  final VoidCallback onEdit;

  const ProfileImagePicker({
    super.key,
    required this.imageFile,
    required this.photoURL,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: imageFile != null
              ? FileImage(imageFile!)
              : (photoURL != null && photoURL!.isNotEmpty
                  ? NetworkImage(photoURL!)
                  : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
              onPressed: onEdit,
              iconSize: 20,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
        ),
      ],
    );
  }
}
