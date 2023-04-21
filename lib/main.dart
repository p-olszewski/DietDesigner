import 'package:diet_designer/providers/date_provider.dart';
import 'package:diet_designer/providers/navbar_provider.dart';
import 'package:diet_designer/routes.dart';
import 'package:diet_designer/providers/authentication_provider.dart';
import 'package:diet_designer/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthenticationProvider>(create: (_) => AuthenticationProvider(FirebaseAuth.instance)),
        StreamProvider<User?>(create: (context) => context.read<AuthenticationProvider>().authStateChanges, initialData: null),
        ChangeNotifierProvider<NavBarProvider>(create: (_) => NavBarProvider()),
        ChangeNotifierProvider<DateProvider>(create: (_) => DateProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DietDesigner',
      theme: appTheme,
      initialRoute: firebaseUser == null ? '/login' : '/home', // temporary
      routes: appRoutes,
    );
  }
}
