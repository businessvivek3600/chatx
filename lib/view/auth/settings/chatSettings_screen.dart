import 'package:flutter/material.dart';

class ChatSettingsScreen extends StatefulWidget {
  const ChatSettingsScreen({super.key});

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  bool enterToSend = true;
  bool mediaVisibility = true;
  bool showPreview = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          'Chat Settings',
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
      body: ListView(
        children: [
          const SizedBox(height: 10),

          /// DISPLAY
          _sectionTitle('Display'),

          _switchTile(
            title: 'Enter is send',
            subtitle: 'Press Enter to send message',
            value: enterToSend,
            onChanged: (val) => setState(() => enterToSend = val),
          ),

          _switchTile(
            title: 'Show preview',
            subtitle: 'Display message text in notifications',
            value: showPreview,
            onChanged: (val) => setState(() => showPreview = val),
          ),

          const SizedBox(height: 20),

          /// MEDIA
          _sectionTitle('Media'),

          _switchTile(
            title: 'Media visibility',
            subtitle: 'Show downloaded media in gallery',
            value: mediaVisibility,
            onChanged: (val) => setState(() => mediaVisibility = val),
          ),

          const SizedBox(height: 20),

          /// CHAT HISTORY
          _sectionTitle('Chat history'),

          _arrowTile(
            title: 'Clear all chats',
            subtitle: 'Remove all messages from this device',
            icon: Icons.delete_outline,
            onTap: () {
              _showConfirmDialog(
                context,
                title: 'Clear chats?',
                message: 'All chats will be permanently removed.',
              );
            },
          ),

          _arrowTile(
            title: 'Archive all chats',
            subtitle: 'Hide chats from main screen',
            icon: Icons.archive_outlined,
            onTap: () {},
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  // SWITCH TILE
  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        activeColor: Colors.blue,
        onChanged: onChanged,
      ),
    );
  }

  // ARROW TILE
  Widget _arrowTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // CONFIRM DIALOG
  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
              // TODO: Clear chat logic
            },
          ),
        ],
      ),
    );
  }
}
