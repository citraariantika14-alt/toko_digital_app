import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/shop_provider.dart';
import 'pages/main_navigation_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShopProvider()..loadData(),
      child: MaterialApp(
        title: 'toko_digital_app',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF154D37),
            primary: const Color(0xFF154D37),
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const MainNavigationPage(),
      ),
    );
  }
}