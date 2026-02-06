import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          'About App',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// APP ICON
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 45,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 12),

            /// APP NAME
            const Text(
              'ChatX',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            /// VERSION
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            /// DESCRIPTION
            const Text(
              'ChatX is a modern messaging application designed to help you '
              'connect with friends and family easily and securely. '
              'Enjoy fast messaging, media sharing, and a smooth user experience.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            /// INFO CARDS
            _infoTile(
              icon: Icons.security_outlined,
              title: 'Privacy & Security',
              subtitle: 'Your chats are protected and secure.',
            ),

            _infoTile(
              icon: Icons.update_outlined,
              title: 'Regular Updates',
              subtitle: 'We frequently improve performance and features.',
            ),

            _infoTile(
              icon: Icons.support_agent_outlined,
              title: 'Support',
              subtitle: 'Contact us anytime for help and feedback.',
            ),

            const SizedBox(height: 30),

            /// COPYRIGHT
            Text(
              '© 2026 ChatX. All rights reserved.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
