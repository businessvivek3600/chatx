import 'dart:ui';

import 'package:chatx/core/widgets/custom_textfield.dart';
import 'package:chatx/view/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_utils.dart';
import '../../core/utils/colors.dart';
import '../../core/utils/navigation_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import 'google_login_screen.dart';

class UserLoginScreen extends ConsumerWidget {
  const UserLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(authFormProvider);
    final formNotifier = ref.read(authFormProvider.notifier);
    final authMethod = ref.read(authMethodProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    void login() async {
      formNotifier.setLoading(true);
      final res = await authMethod.loginUser(
        email: formState.email,
        password: formState.password,
      );
      formNotifier.setLoading(false);

      showAppSnackbar(
        context: context,
        type: res == "success" ? SnackbarType.success : SnackbarType.error,
        description: res == "success" ? "Successful Login" : res,
      );

      if (res == "success") {
        await ref.read(profileProvider.notifier).refreshUserData();
        NavigationHelper.pushAndRemoveUntil(
          context,
          const HomeScreen(),
        );
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient:  const LinearGradient(
            colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
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
                      /// Title
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : kTextDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Login to continue",
                        style: TextStyle(
                          color:
                          isDark ? Colors.white70 : kAccent,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// Email
                      GlassTextField(
                        hint: "Email",
                        icon: Icons.email_outlined,
                        errorText: formState.emailError,
                        onChanged: formNotifier.updateEmail,
                      ),

                      const SizedBox(height: 18),

                      /// Password
                      GlassTextField(
                        hint: "Password",
                        icon: Icons.lock_outline,
                        obscureText: formState.isPasswordHidden,
                        errorText: formState.passwordError,
                        suffix: IconButton(
                          icon: Icon(
                            formState.isPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: isDark
                                ? Colors.white
                                : kAccent,
                          ),
                          onPressed:
                          formNotifier.togglePasswordVisibility,
                        ),
                        onChanged: formNotifier.updatePassword,
                      ),

                      const SizedBox(height: 30),

                      /// Login Button (Micro-interaction)
                      formState.isLoading
                          ? const CircularProgressIndicator(
                        color: kPrimary,
                      )
                          : _AnimatedButton(
                        enabled: formState.isFormValid,
                        onTap: login,
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      /// Divider
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8),
                            child: Text(
                              "OR",
                              style:
                              TextStyle(color: Colors.grey),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// Google Login
                      GoogleLoginScreen(),

                      const SizedBox(height: 18),

                      /// Signup
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don’t have an account? ",
                            style:
                            TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () {
                              NavigationHelper.push(
                                context,
                                SignupScreen(),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: kPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
  State<_AnimatedButton> createState() =>
      _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) =>
          setState(() => _pressed = true),
      onTapUp: (_) =>
          setState(() => _pressed = false),
      onTapCancel: () =>
          setState(() => _pressed = false),
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
