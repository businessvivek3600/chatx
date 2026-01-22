import 'package:chatx/core/constants/assets_constant.dart';
import 'package:chatx/core/utils/navigation_helper.dart';
import 'package:chatx/view/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';

class GoogleLoginScreen extends ConsumerWidget {
  const GoogleLoginScreen({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final authMethod = ref.read(authMethodProvider);

    return InkWell(
      onTap: () async {
        final res = await authMethod.signInWithGoogle();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                res == "success" ? "Google login successful" : res,
              ),
            ),
          );

          if (res == "success") {
            NavigationHelper.pushAndRemoveUntil(context, const HomeScreen());
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Image.asset(AppIcons.googleIcon,height: 25,width: 25) ,
            const SizedBox(width: 10),
            const Text(
              "Continue with Google",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
