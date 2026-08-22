import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../ads/add_ad_screen.dart';
import '../favorites/favorites_screen.dart';
import '../messages/messages_screen.dart';
import '../profile/profile_screen.dart';
import 'views/home_main_content_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeMainContentView(),
      const FavoritesScreen(),
      const SizedBox(),
      const MessagesScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AddAdScreen()),
            );
          } else {
            setState(() => _currentIndex = i);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConfig.primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'المفضلة'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 30), label: 'أضف إعلان'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'الرسائل'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}