/* ---------------- PROFILE / SETTINGS (WHATSAPP STYLE + DIVIDERS) ---------------- */

import 'package:chatx/core/utils/navigation_helper.dart';
import 'package:chatx/model/user_profile_model.dart';
import 'package:chatx/view/profile/component/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/logout_helper.dart';
import '../../providers/user_profile_provider.dart';

/* ========================= PAGE ========================= */

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // WhatsApp background
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: [
          ProfileHeader(profile: profile),
          const SizedBox(height: 28),

          /// ACCOUNT
          SettingsSection(
            title: 'Account',
            color: Colors.blue,
            children: const [
              SettingsTile(icon: Icons.person_outline, title: 'Edit Profile'),
              SettingsDivider(),
              SettingsTile(icon: Icons.lock_outline, title: 'Change Password'),
              SettingsDivider(),
              SettingsTile(
                icon: Icons.security_outlined,
                title: 'Privacy & Security',
              ),
            ],
            onEditProfile: true,
          ),

          const SizedBox(height: 24),

          /// PREFERENCES
          SettingsSection(
            title: 'Preferences',
            color: kAccent,
            children: const [
              SettingsTile(
                icon: Icons.notifications_none,
                title: 'Notifications',
              ),
              SettingsDivider(),
              SettingsTile(icon: Icons.dark_mode_outlined, title: 'Dark Mode'),
              SettingsDivider(),
              SettingsTile(
                icon: Icons.chat_bubble_outline,
                title: 'Chat Settings',
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// SUPPORT
          SettingsSection(
            title: 'Support',
            color: Colors.green,
            children: const [
              SettingsTile(icon: Icons.help_outline, title: 'Help & Support'),
              SettingsDivider(),
              SettingsTile(icon: Icons.info_outline, title: 'About App'),
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
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email ?? '--',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
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

/* ========================= SECTION ========================= */

class SettingsSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<Widget> children;
  final bool onEditProfile;

  const SettingsSection({
    super.key,
    required this.title,
    required this.color,
    required this.children,
    this.onEditProfile = false,
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
            ...children.map((widget) {
              if (widget is SettingsTile && widget.title == 'Edit Profile') {
                return GestureDetector(
                  onTap: () {
                    NavigationHelper.push(context, const EditProfilePage());
                  },
                  child: widget,
                );
              }
              return widget;
            }).toList(),
          ],
        ),
      ),
    );
  }
}

/* ========================= TILE ========================= */

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const SettingsTile({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: kAccent),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}

/* ========================= DIVIDER ========================= */

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(height: 8, thickness: 0.6, color: Colors.grey.shade300),
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
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
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
          Text(
            'Version 1.0.0',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
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
