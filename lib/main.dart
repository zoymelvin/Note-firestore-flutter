import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_note/auth_helper.dart';
import 'package:flutter_note/firebase_options.dart';
import 'package:flutter_note/pages/note_home_page.dart';
import 'package:flutter_note/pages/signin_page.dart';
import 'package:flutter_note/pages/singup_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final authHelper = AuthHelper();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authHelper.checkUserSignInState(),
      builder: (context, snapshots) {
        return MaterialApp(
          title: 'Flutter Note',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lime),
          ),
          //home: const NoteHomePage(),
          initialRoute: snapshots.data != null ? '/home' : '/signin',
          routes: {
            '/home': (context) => const NoteHomePage(),
            '/signup': (context) => const SignupPage(),
            '/signin': (context) => const SigninPage(),
          },
        );
      },
    );
  }
}