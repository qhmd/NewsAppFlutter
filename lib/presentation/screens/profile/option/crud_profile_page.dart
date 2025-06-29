import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:image_picker/image_picker.dart';
import 'package:newsapp/presentation/state/auth_providers.dart';
import 'package:newsapp/presentation/widget/profile_image_picker.dart';
import 'dart:io';

import 'package:newsapp/services/imgur_service.dart';
import 'package:newsapp/presentation/widget/bookmark_toast.dart';
import 'package:newsapp/services/user_profil_service.dart';
import 'package:provider/provider.dart';

class CrudProfilePage extends StatefulWidget {
  const CrudProfilePage({super.key});

  @override
  State<CrudProfilePage> createState() => _CrudProfilePageState();
}

class _CrudProfilePageState extends State<CrudProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  File? _imageFile;
  String? _photoURL;
  String? _deleteHash;
  DateTime? _createdAt;

  String? _error;
  bool _loading = false;

  final _auth = FirebaseAuth.instance;
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final userDoc = await _userService.getUserDoc();
      final rawData = userDoc.data();
      if (rawData != null) {
        final data = rawData as Map<String, dynamic>; // lakukan casting
        _usernameController.text = data['username'] ?? '';
        _photoURL = data['photoURL'];
        _deleteHash = data['deleteHash'];
        final ts = data['createdAt'];
        if (ts is Timestamp) _createdAt = ts.toDate();
      }
    } catch (e) {
      _error = 'Failed to load profile: $e';
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to pick image: $e";
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final username = _usernameController.text.trim();

    // Cek username
    if (!await _userService.isUsernameUnique(username)) {
      setState(() {
        _error = "Username is already taken";
        _loading = false;
      });
      return;
    }

    String? newPhotoUrl = _photoURL;
    String? newDeleteHash = _deleteHash;

    // Upload gambar baru
    if (_imageFile != null) {
      if (_deleteHash != null && _deleteHash!.isNotEmpty) {
        await ImgurService.deleteImage(_deleteHash!);
      }
      final result = await ImgurService.uploadImage(_imageFile!);
      if (result != null) {
        newPhotoUrl = result['link'];
        newDeleteHash = result['deleteHash'];
      } else {
        setState(() {
          _error = "Gagal meng-upload gambar";
          _loading = false;
        });
        return;
      }
    }

    try {
      await _userService.updateProfile(
        username: username,
        photoURL: newPhotoUrl,
        deleteHash: newDeleteHash,
      );
      setState(() {
        _photoURL = newPhotoUrl;
        _deleteHash = newDeleteHash;
        _loading = false;
      });
      if (mounted) {
        Navigator.pop(context);
        showCustomToast("Profile updated successfully");
        final authProvider = context.read<AuthProvider>();
        authProvider.setUserData({
          'username': username,
          'photoURL': newPhotoUrl,
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to save profile: $e";
        _loading = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    setState(() => _loading = true);
    try {
      await _userService.deleteUserData();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      setState(() {
        _error = "Gagal menghapus akun: $e";
        _loading = false;
      });
    }
  }

  void _showDeleteConfirmation() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primaryContainer,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileImagePicker(
                    imageFile: _imageFile,
                    photoURL: _photoURL,
                    onEdit: _pickImage,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        TextFormField(
                          style: TextStyle(color: theme.colorScheme.onPrimary),
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(
                              color: theme.colorScheme.onPrimary,
                            ),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            child: const Text("Save"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showDeleteConfirmation,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Delete Account"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
