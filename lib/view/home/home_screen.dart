import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';

import '../../core/utils/colors.dart';
import '../call_history/call_history.dart';
import '../chats/chat_list_screen.dart';
import '../contacts/contact_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotchBottomBarController _notchController = NotchBottomBarController(
    index: 0,
  );

  late final PageController _pageController;

  final List<Widget> _pages = [
    const ChatListScreen(),
    const ContactsPage(),
    CallHistoryScreen(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
      ),

      /// 🔴 ONLY CHANGE IS HERE (background color)
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _notchController,
        color: kBackground,
        showLabel: true,
        shadowElevation: 12,
        notchColor: kAccent,
        kIconSize: 20,
        kBottomRadius: 20,
        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: Icon(Icons.chat_bubble_outline, color: Colors.grey),
            activeItem: Icon(Icons.chat_bubble, color: Colors.white),
            itemLabel: 'Chats',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.people_outline, color: Colors.grey),
            activeItem: Icon(Icons.people, color: Colors.white),
            itemLabel: 'Contacts',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.call_outlined, color: Colors.grey),
            activeItem: Icon(Icons.call, color: Colors.white),
            itemLabel: 'Calls',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.person_outline, color: Colors.grey),
            activeItem: Icon(Icons.person, color: Colors.white),
            itemLabel: 'Profile',
          ),
        ],
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}
