/* ---------------- SETTINGS ---------------- */

import 'package:chatx/core/utils/navigation_helper.dart';
import 'package:chatx/view/profile/component/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/logout_helper.dart';
import '../../core/widgets/card_decoration.dart';
import '../../model/user_profile_model.dart';
import '../../providers/user_profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _profileHeader(profile),
        const SizedBox(height: 24),

        _sectionTitle('Account'),
        _profileTile(Icons.person_outline, 'Edit Profile', () {
          NavigationHelper.push(context, EditProfilePage());
        }),
        // _profileTile(Icons.lock_outline, 'Privacy & Security', () {}),
        // _profileTile(Icons.notifications_none, 'Notifications', () {}),
        //
        // const SizedBox(height: 20),
        // _sectionTitle('Preferences'),
        // _profileTile(Icons.color_lens_outlined, 'Appearance', () {}),
        // _profileTile(Icons.chat_bubble_outline, 'Chat Settings', () {}),
        // _profileTile(Icons.storage_outlined, 'Storage & Data', () {}),
        //
        // const SizedBox(height: 20),
        // _sectionTitle('Support'),
        // _profileTile(Icons.help_outline, 'Help Center', () {}),
        // _profileTile(Icons.info_outline, 'About App', () {}),

        const SizedBox(height: 10),
        _logoutTile(context, ref),
      ],
    );
  }

  /* ---------------- HEADER ---------------- */

  Widget _profileHeader(ProfileState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card3D(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: state.photoUrl != null
                ? NetworkImage(state.photoUrl!)
                : null,
            child: state.photoUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.name ?? '--',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                state.email ?? '--',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }


  /* ---------------- TILES ---------------- */

  Widget _profileTile(IconData icon, String title, VoidCallback? onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: AppDecorations.card3D(),
      child: ListTile(
        leading: Icon(icon, color: kAccent),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _logoutTile(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () => showLogoutDialog(context, ref),
      ),
    );
  }


  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }
}
