import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_note/auth_helper.dart';
import 'package:flutter_note/pages/note_home_page.dart';
import 'package:flutter_note/firestore_user_helper.dart'; 
import 'package:flutter_note/models/user_model.dart';
// -----------------------------
class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final AuthHelper authHelper = AuthHelper();
  final FirestoreUserHelper fsUserHelper = FirestoreUserHelper();

  TextEditingController emailController = TextEditingController();
  TextEditingController psswdController = TextEditingController();

  bool passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'Signin',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Input Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: psswdController,
                  obscureText: passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Input Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // --- TOMBOL SIGNIN EMAIL ---
                ElevatedButton(
                  // PERBAIKAN UTAMA: Ditambahkan 'async' di sini
                  onPressed: () async {
                    await _signInWithEmail();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: const Text('Signin'),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                const Text('or'),
                const SizedBox(height: 16),
                
                // --- TOMBOL SIGNIN GOOGLE ---
                ElevatedButton(
                  // PERBAIKAN UTAMA: Ditambahkan 'async' di sini
                  onPressed: () async {
                    await _signInWithGoogle();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: const Text('Signin with Google'),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Text('Not have an account?'),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text('Signup'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithEmail() async {
    try {
      final result = await authHelper.signInWithEmailAndPassword(
        emailController.text,
        psswdController.text,
      );

      if (mounted) {
        _showSnackbar('Signin success as ${result.user?.email}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NoteHomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showSnackbar('Signin fail: ${e.message}');
    } catch (e) {
      _showSnackbar('Signin fail: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final result = await authHelper.signInWithGoogle();

      if (result?.user != null) {
        // Simpan data user ke Firestore
        await fsUserHelper.addUser(
          UserModel(
            userId: result?.user?.uid ?? '',
            userEmail: result?.user?.email ?? '',
            // userName: result?.user?.displayName, // Aktifkan jika perlu
          ),
        );

        if (mounted) {
          _showSnackbar('Signin success as ${result?.user?.email}');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NoteHomePage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      _showSnackbar('Signin fail: ${e.message}');
    } catch (e) {
      _showSnackbar('Signin fail: $e');
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}