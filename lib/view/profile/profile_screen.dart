/* ---------------- PROFILE / SETTINGS (WHATSAPP STYLE + DIVIDERS) ---------------- */


import 'package:chatx/view/auth/settings/aboutapp_screen.dart';
import 'package:chatx/view/auth/settings/chatSettings_screen.dart';

import 'package:chatx/view/auth/settings/help_support_screen.dart';
import 'package:chatx/view/auth/settings/privacy_security.dart' show PrivacySecurityScreen;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatx/view/auth/settings/change_password.dart';
import '../../core/utils/colors.dart';
import '../../core/utils/logout_helper.dart';
import '../../core/utils/navigation_helper.dart';
import '../../providers/user_profile_provider.dart';
import '../../model/user_profile_model.dart';

import 'component/edit_profile.dart';



class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),

      /// APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          ProfileHeader(profile: profile),
          const SizedBox(height: 28),

          SettingsSection(
            title: 'Account',
            color: Colors.blue,
            children: [
              SettingsTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () => NavigationHelper.push(
                  context,
                  const EditProfilePage(),
                ),
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () => NavigationHelper.push(
                  context,
                  const ChangePasswordScreen(),
                ),
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.security_outlined,
                title: 'Privacy & Security',
                onTap: () => NavigationHelper.push(
                  context,
                  const PrivacySecurityScreen(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

    
          SettingsSection(
            title: 'Preferences',
            color: kAccent,
            children: [
              SettingsTile(
                icon: Icons.notifications_none,
                title: 'Notifications',
                onTap: () => _openDummy(
                  context,
                  'Notifications',
                ),
              ),
             
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.chat_bubble_outline,
                title: 'Chat Settings',
                onTap: () => NavigationHelper.push(
                  context,
                  const ChatSettingsScreen(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

       
          SettingsSection(
            title: 'Support',
            color: Colors.green,
            children: [
              SettingsTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () => NavigationHelper.push(
                  context,
                  const HelpSupportScreen(),
                ),
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.info_outline,
                title: 'About App',
                onTap: ()  => NavigationHelper.push(
                  context,
                  const AboutAppScreen(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),
          const LogoutTile(),
          const SizedBox(height: 28),
          const AppInfo(),
        ],
      ),
    );
  }

  /// Dummy navigation helper
  void _openDummy(BuildContext context, String title) {
    NavigationHelper.push(
      context,
      DummySettingsPage(title: title),
    );
  }
}

/* ========================= HEADER ========================= */

class ProfileHeader extends StatelessWidget {
  final ProfileState profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: kPrimary.withOpacity(0.15),
              backgroundImage: profile.photoUrl != null
                  ? NetworkImage(profile.photoUrl!)
                  : null,
              child: profile.photoUrl == null
                  ? const Icon(Icons.person, size: 32)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name ?? '--',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email ?? '--',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class SettingsSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}



class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: kAccent),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

/* ========================= DIVIDER ========================= */

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 56),
      child: Divider(height: 8),
    );
  }
}

/* ========================= LOGOUT ========================= */

class LogoutTile extends ConsumerWidget {
  const LogoutTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsCard(
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.red),
        ),
        onTap: () => showLogoutDialog(context, ref),
      ),
    );
  }
}

/* ========================= APP INFO ========================= */

class AppInfo extends StatelessWidget {
  const AppInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          Text('ChatX', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

/* ========================= CARD ========================= */

class SettingsCard extends StatelessWidget {
  final Widget child;

  const SettingsCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

/* ========================= DUMMY PAGE ========================= */

class DummySettingsPage extends StatelessWidget {
  final String title;

  const DummySettingsPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          '$title screen coming soon',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
