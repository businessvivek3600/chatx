import 'package:flutter/material.dart';

import 'package:chatx/core/utils/colors.dart';
import 'package:chatx/core/utils/navigation_helper.dart';

/* ========================= PRIVACY & SECURITY ========================= */

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),

      /// APP BAR WITH BACK BUTTON
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'Privacy & Security',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          /// ================= PRIVACY =================
          _Section(
            title: 'Privacy',
            children: [
              _Tile(
                icon: Icons.visibility_outlined,
                title: 'Last Seen',
                subtitle: 'Everyone',
                target: 'Last Seen',
              ),
              _Divider(),
              _Tile(
                icon: Icons.person_outline,
                title: 'Profile Photo',
                subtitle: 'My Contacts',
                target: 'Profile Photo',
              ),
              _Divider(),
              _Tile(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Everyone',
                target: 'About',
              ),
            ],
          ),

          SizedBox(height: 24),

         
          _Section(
            title: 'Security',
            children: [
              _Tile(
                icon: Icons.lock_outline,
                title: 'Screen Lock',
                subtitle: 'Disabled',
                target: 'Screen Lock',
              ),
              _Divider(),
              _Tile(
                icon: Icons.phonelink_lock_outlined,
                title: 'Two-Step Verification',
                subtitle: 'Disabled',
                target: 'Two-Step Verification',
              ),
              _Divider(),
              _Tile(
                icon: Icons.devices_outlined,
                title: 'Devices',
                subtitle: 'Manage logged-in devices',
                target: 'Devices',
              ),
            ],
          ),

          SizedBox(height: 24),

          _Section(
            title: 'Advanced',
            children: [
              _Tile(
                icon: Icons.delete_outline,
                title: 'Clear Chat History',
                subtitle: 'Remove all chats',
                target: 'Clear Chat History',
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}



class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kAccent,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}



class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String target;
  final bool isDestructive;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.target,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : kAccent,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        NavigationHelper.push(
          context,
          _DummyPage(title: target),
        );
      },
    );
  }
}



class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(
        height: 8,
        thickness: 0.6,
        color: Colors.grey.shade300,
      ),
    );
  }
}



final _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  boxShadow: const [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
  ],
);

/* ========================= DUMMY PAGE ========================= */

class _DummyPage extends StatelessWidget {
  final String title;

  const _DummyPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title settings coming soon',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
