import 'dart:io';
import 'package:chatx/providers/contact_list_provider.dart';
import 'package:chatx/providers/provider.dart';
import 'package:chatx/providers/user_profile_provider.dart';
import 'package:chatx/view/auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';
import 'navigation_helper.dart';

Future<void> showLogoutDialog(BuildContext context, WidgetRef ref) async {
  final auth = ref.read(authMethodProvider);

  Future<void> onLogout() async {
    Navigator.of(context).pop(); // close dialog
    await auth.signOut();
    ref.invalidate(profileProvider);
    ref.invalidate(contactProvider);
    ref.invalidate(requestProvider);
    ref.invalidate(userListProvider);
    ref.invalidate(filteredUsersProvider);
    ref.invalidate(searchQueryProvider);
    // Navigate to login (clear stack)
    NavigationHelper.pushAndRemoveUntil(context, const UserLoginScreen());
  }

  if (Platform.isIOS) {
    /// 🍎 iOS Style
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: onLogout,
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  } else {
    /// 🤖 Android / Material Style
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: onLogout,
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
