// import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

// import '../widgets/user_imagepicker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _isAuthenticating = false;
  var _obscurePassword = true;
  var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredPassword = '';
  // File? _selectedImage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isAuthenticating = true);

    try {
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        final credentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        final uid = credentials.user!.uid;

        // String? imageUrl;
        // if (_selectedImage != null) {
        //   final ref = FirebaseStorage.instance
        //       .ref()
        //       .child('user_images')
        //       .child('$uid.jpg');
        //   await ref.putFile(_selectedImage!);
        //   imageUrl = await ref.getDownloadURL();
        // }

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          // 'image_url': imageUrl,
        });
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication failed.')),
      );
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, scheme.tertiary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: scheme.onPrimary.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chat_bubble_rounded,
                        size: 44,
                        color: scheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'FlutterChat',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLogin
                          ? 'Welcome back! Sign in to continue.'
                          : 'Create your account to start chatting.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimary.withAlpha(220),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                child: _isLogin
                                    ? const SizedBox(width: double.infinity)
                                    : Column(
                                        children: [
                                          // UserImagePicker(
                                          //   onPickImage: (image) =>
                                          //       _selectedImage = image,
                                          // ),
                                          // const SizedBox(height: 20),
                                          TextFormField(
                                            decoration: const InputDecoration(
                                              labelText: 'Username',
                                              prefixIcon: Icon(
                                                Icons.person_outline_rounded,
                                              ),
                                            ),
                                            enableSuggestions: false,
                                            textInputAction:
                                                TextInputAction.next,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().length < 4) {
                                                return 'Username must be at least 4 characters long.';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) =>
                                                _enteredUsername = value!
                                                    .trim(),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains('@')) {
                                    return 'Please enter a valid email address.';
                                  }
                                  return null;
                                },
                                onSaved: (value) =>
                                    _enteredEmail = value!.trim(),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                validator: (value) {
                                  if (value == null || value.length < 6) {
                                    return 'Password must be at least 6 characters long.';
                                  }
                                  return null;
                                },
                                onSaved: (value) => _enteredPassword = value!,
                              ),
                              const SizedBox(height: 24),
                              FilledButton(
                                onPressed: _isAuthenticating ? null : _submit,
                                child: _isAuthenticating
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(_isLogin ? 'Sign in' : 'Sign up'),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _isAuthenticating
                                    ? null
                                    : () =>
                                          setState(() => _isLogin = !_isLogin),
                                child: Text(
                                  _isLogin
                                      ? "Don't have an account? Sign up"
                                      : 'I already have an account',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
