import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatx/services/auth_service.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widgets/custom_textfield.dart';

class ChangePasswordScreen extends ConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authMethod = ref.read(authMethodProvider);

    final currentPassword = ValueNotifier('');
    final newPassword = ValueNotifier('');
    final confirmPassword = ValueNotifier('');

    final hideCurrent = ValueNotifier(true);
    final hideNew = ValueNotifier(true);
    final hideConfirm = ValueNotifier(true);

    Future<void> changePassword() async {
      if (newPassword.value != confirmPassword.value) {
        showAppSnackbar(
          context: context,
          type: SnackbarType.error,
          description: "Passwords do not match",
        );
        return;
      }

      final res = await authMethod.changePassword(
        currentPassword: currentPassword.value,
        newPassword: newPassword.value,
      );

      showAppSnackbar(
        context: context,
        type: res == "success" ? SnackbarType.success : SnackbarType.error,
        description: res == "success" ? "Password changed successfully" : res,
      );

      if (res == "success") {
        Navigator.pop(context);
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'Change Password',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      extendBodyBehindAppBar: true,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.white.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 30,
                        offset: Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Change Password",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : kTextDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Secure your account",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : kAccent,
                        ),
                      ),

                      const SizedBox(height: 30),

                      ValueListenableBuilder(
                        valueListenable: hideCurrent,
                        builder: (_, bool hide, __) {
                          return GlassTextField(
                            hint: "Current Password",
                            icon: Icons.lock_outline,
                            obscureText: hide,
                            suffix: IconButton(
                              icon: Icon(
                                hide ? Icons.visibility_off : Icons.visibility,
                                color: isDark ? Colors.white : kAccent,
                              ),
                              onPressed: () => hideCurrent.value = !hide,
                            ),
                            onChanged: (v) => currentPassword.value = v,
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      ValueListenableBuilder(
                        valueListenable: hideNew,
                        builder: (_, bool hide, __) {
                          return GlassTextField(
                            hint: "New Password",
                            icon: Icons.lock_reset,
                            obscureText: hide,
                            suffix: IconButton(
                              icon: Icon(
                                hide ? Icons.visibility_off : Icons.visibility,
                                color: isDark ? Colors.white : kAccent,
                              ),
                              onPressed: () => hideNew.value = !hide,
                            ),
                            onChanged: (v) => newPassword.value = v,
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      ValueListenableBuilder(
                        valueListenable: hideConfirm,
                        builder: (_, bool hide, __) {
                          return GlassTextField(
                            hint: "Confirm New Password",
                            icon: Icons.lock,
                            obscureText: hide,
                            suffix: IconButton(
                              icon: Icon(
                                hide ? Icons.visibility_off : Icons.visibility,
                                color: isDark ? Colors.white : kAccent,
                              ),
                              onPressed: () => hideConfirm.value = !hide,
                            ),
                            onChanged: (v) => confirmPassword.value = v,
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      _AnimatedButton(
                        enabled: true,
                        onTap: changePassword,
                        child: const Text(
                          "Update Password",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool enabled;

  const _AnimatedButton({
    required this.child,
    required this.onTap,
    required this.enabled,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 54,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: kPrimary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
