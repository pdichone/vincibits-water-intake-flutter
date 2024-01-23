import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:water_intake/firebase_options.dart';
import 'package:water_intake/providers/auth_provider.dart';
import 'package:water_intake/providers/home_provider.dart';
import 'package:water_intake/providers/statistics_provider.dart';
import 'package:water_intake/root.dart';
import 'package:water_intake/screens/data_entry_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
  //   DeviceOrientation.portraitDown,
  //   DeviceOrientation.portraitUp
  // ]);

  FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings android =
      const AndroidInitializationSettings('notification_icon');
  DarwinInitializationSettings ios = const DarwinInitializationSettings();
  InitializationSettings settings =
      InitializationSettings(android: android, iOS: ios);
  await notificationsPlugin.initialize(
    settings,
  );

  // Get the env variables
  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProviderr>(
          create: (context) => AuthProviderr(),
        ),
        ChangeNotifierProxyProvider<AuthProviderr, HomeProvider>(
          create: (context) => HomeProvider(),
          update: (context, authProvider, homeProvider) {
            homeProvider?.update(authProvider.user!);
            return homeProvider!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProviderr, StatisticsProvider>(
          create: (context) => StatisticsProvider(),
          update: (context, authProvider, statisticsProvider) {
            statisticsProvider?.update(authProvider.user!);
            return statisticsProvider!;
          },
        )
      ],
      child: MaterialApp(
        // showPerformanceOverlay: true,
        debugShowCheckedModeBanner: false,
        title: 'Drinkable',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder()
          }),
        ),
        home: const Root(),
        routes: {
          DataEntryScreen.routeName: (ctx) => const DataEntryScreen(),
        },
      ),
    );
  }
}
