import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_utils.dart';
import '../../core/utils/navigation_helper.dart';
import '../../core/widgets/animated_button.dart';
import '../../core/widgets/custom_textfield.dart'; // GlassTextField lives here
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(authFormProvider);
    final formNotifier = ref.read(authFormProvider.notifier);
    final authMethod = ref.read(authMethodProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    void signup() async {
      formNotifier.setLoading(true);
      final res = await authMethod.signUpUser(
        email: formState.email,
        password: formState.password,
        name: formState.name,
      );
      formNotifier.setLoading(false);

      if (res == "success" && context.mounted) {
        NavigationHelper.pushReplacement(
          context,
          const UserLoginScreen(),
        );
        showAppSnackbar(
          context: context,
          type: SnackbarType.success,
          description: "Signup successful. Please login.",
        );
      } else if (context.mounted) {
        showAppSnackbar(
          context: context,
          type: SnackbarType.error,
          description: res,
        );
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
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
                        "Create Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,

                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Join the conversation",
                        style: TextStyle(

                        ),
                      ),

                      const SizedBox(height: 30),

                      /// Name
                      GlassTextField(
                        hint: "Full Name",
                        icon: Icons.person_outline,
                        errorText: formState.nameError,
                        onChanged: formNotifier.updateName,
                      ),

                      const SizedBox(height: 18),

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
                          ),
                          onPressed:
                          formNotifier.togglePasswordVisibility,
                        ),
                        onChanged: formNotifier.updatePassword,
                      ),

                      const SizedBox(height: 32),

                      /// Sign Up Button (Micro-interaction)
                      formState.isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : AnimatedButton(
                        enabled: formState.isFormValid,
                        onTap: signup,
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      /// Login redirect
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                          ),
                          GestureDetector(
                            onTap: () {
                              NavigationHelper.push(
                                context,
                                const UserLoginScreen(),
                              );
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
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
