import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tourpis/screens/signin_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tourpis/utils/custom_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = 'pk_test_51OVMbUGRgwR2xYrTbuWKyFwCdHLlyXy6L1r8WDbUzqb9t54tiVUsJzJ8qkWtYiHfNLGeERticsRRyLwwRajSPdfG00hXFSofgq';
  await dotenv.load(fileName: "assets/.env");
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.Tourips';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate();
  } catch (e, stackTrace) {
    print('Error initializing Firebase: $e\n$stackTrace');
  }

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tourips',
      theme: CustomTheme.of(context),
      home: const SignInScreen(),
    );
  }
}
