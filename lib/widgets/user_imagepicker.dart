import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});

  final void Function(File image) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 300,
    );
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    setState(() => _pickedImage = file);
    widget.onPickImage(file);
  }

  void _showSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: GestureDetector(
        onTap: _showSourceSheet,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: scheme.primaryContainer,
              foregroundImage: _pickedImage != null
                  ? FileImage(_pickedImage!)
                  : null,
              child: Icon(
                Icons.person_rounded,
                size: 46,
                color: scheme.onPrimaryContainer,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: scheme.primary,
                child: Icon(
                  Icons.add_a_photo_rounded,
                  size: 16,
                  color: scheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
