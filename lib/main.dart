import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/tws_service.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0C0E14),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TwsManagerApp());
}

class TwsManagerApp extends StatefulWidget {
  const TwsManagerApp({super.key});

  @override
  State<TwsManagerApp> createState() => _TwsManagerAppState();
}

class _TwsManagerAppState extends State<TwsManagerApp> {
  late final TwsService _twsService;

  @override
  void initState() {
    super.initState();
    _twsService = TwsService();
  }

  @override
  void dispose() {
    _twsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _twsService,
      builder: (context, _) {
        return MaterialApp(
          title: 'TWS Manager',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0C0E14),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00BBF9),
              secondary: Color(0xFF00F5D4),
              surface: Color(0xFF161922),
            ),
            fontFamily: 'Roboto',
          ),
          home: DashboardScreen(service: _twsService),
        );
      },
    );
  }
}
