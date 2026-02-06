import 'package:chatx/core/utils/colors.dart';
import 'package:chatx/core/utils/navigation_helper.dart';
import 'package:flutter/material.dart';


class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF0F2F5),

      /// APP BAR
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// HELP
          _Section(
            title: 'Help',
            isDark: isDark,
            children: [
              _Tile(
                icon: Icons.help_outline,
                title: 'FAQs',
                subtitle: 'Frequently asked questions',
                isDark: isDark,
                onTap: () => _open(context, 'FAQs'),
              ),
              const _Divider(),
              _Tile(
                icon: Icons.book_outlined,
                title: 'How to use ChatX',
                subtitle: 'Learn basic features',
                isDark: isDark,
                onTap: () => _open(context, 'How to use ChatX'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// SUPPORT
          _Section(
            title: 'Support',
            isDark: isDark,
            children: [
              _Tile(
                icon: Icons.email_outlined,
                title: 'Contact Support',
                subtitle: 'Get help from our team',
                isDark: isDark,
                onTap: () => _open(context, 'Contact Support'),
              ),
              const _Divider(),
              _Tile(
                icon: Icons.bug_report_outlined,
                title: 'Report a Problem',
                subtitle: 'Tell us what went wrong',
                isDark: isDark,
                onTap: () => _open(context, 'Report a Problem'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// LEGAL
          _Section(
            title: 'Legal',
            isDark: isDark,
            children: [
              _Tile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                isDark: isDark,
                onTap: () => _open(context, 'Privacy Policy'),
              ),
              const _Divider(),
              _Tile(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                subtitle: 'View terms of service',
                isDark: isDark,
                onTap: () => _open(context, 'Terms & Conditions'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, String title) {
    NavigationHelper.push(context, _DummyPage(title: title));
  }
}

/* ========================= SECTION ========================= */

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isDark;

  const _Section({
    required this.title,
    required this.children,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
      ),
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

/* ========================= TILE ========================= */

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: kAccent),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white60 : Colors.black54,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.white38 : Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

/* ========================= DIVIDER ========================= */

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(
        height: 8,
        thickness: 0.6,
        color: isDark ? Colors.white12 : Colors.grey.shade300,
      ),
    );
  }
}

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
          '$title coming soon',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
