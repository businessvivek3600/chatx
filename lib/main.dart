import 'package:chatx/firebase_options.dart';
import 'package:chatx/providers/provider.dart';
import 'package:chatx/services/fcm_token_service.dart';
import 'package:chatx/services/notification_service.dart';
import 'package:chatx/view/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'core/constants/app_secrets.dart';
import 'core/utils/colors.dart';
import 'core/wrapper_state/auth_wrapper.dart';

///define a navigator globalKey
final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.init();

// Listen token refresh globally
  FcmTokenService.listenTokenRefresh();
  ///request permission before initialized zeGoCloud
  await requestPermission();
  final user = FirebaseAuth.instance.currentUser;
  final String userId = user?.uid ?? '0000';
  final String userName = user?.displayName ?? 'Guest';

  ///Set navigator key to ZeGoUIKit
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  await ZegoUIKitPrebuiltCallInvitationService()
      .init(
        appID: AppSecrets.appId,
        appSign: AppSecrets.appSign,
        userID: userId,
        userName: userName,
        plugins: [ZegoUIKitSignalingPlugin()],
        invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(),
      )
      .catchError((error) {
        print("ZeGo initialization error $error");
      });
  runApp(ProviderScope(child: MyApp(navigatorKey: navigatorKey)));
}

Future<void> requestPermission() async {
  await [
    Permission.camera,
    Permission.microphone,
    Permission.notification,
  ].request();
}

class MyApp extends ConsumerStatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyApp({super.key, required this.navigatorKey});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    return MaterialApp(
      navigatorKey: widget.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'chatx',
      theme: ThemeData(
        scaffoldBackgroundColor: kBackground,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: kAccent,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kAccent,
        ),
      ),
      home: authState.when(
        data: (user) {
          if (user != null) {
            return AuthWrapper();
          } else {
            return UserLoginScreen();
          }
        },
        error: (error, _) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 65, color: Colors.red),
                SizedBox(height: 16),
                Text("Error: $error"),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(authStateProvider),
                  child: Text('retry'),
                ),
              ],
            ),
          ),
        ),
        loading: () => CircularProgressIndicator(),
      ),
    );
  }
}
