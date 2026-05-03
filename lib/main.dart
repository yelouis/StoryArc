import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // NOTE: Firebase initialization requires firebase_options.dart
  // try {
  //   await Firebase.initializeApp();
  //   FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  // } catch (e) {
  //   debugPrint("Firebase initialization failed: $e");
  // }

  runApp(const ProviderScope(child: StoryArcApp()));
}

class StoryArcApp extends ConsumerWidget {
  const StoryArcApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'StoryArc',
      theme: CosmicTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
