import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:myapp/pages/home_page.dart';
import 'package:myapp/services/task_service.dart';
import 'package:myapp/services/theme_service.dart';
import 'package:myapp/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskService()),
        ChangeNotifierProvider(create: (context) => ThemeService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get theme service
    final themeService = Provider.of<ThemeService>(context);
    
    // Load tasks on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskService>(context, listen: false).loadTasks();
    });
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Todo App',
      theme: themeService.getLightTheme(),
      darkTheme: themeService.getDarkTheme(),
      themeMode: themeService.themeMode,
      home: const HomePage(),
    );
  }
}
