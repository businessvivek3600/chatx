import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatx/model/user_profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  late final StreamSubscription<User?> _authSubscription;
  ProfileNotifier() : super(ProfileState(isLoading: true)) {_listenToAuthChange();}

  ///Listen to firebase auth state changes
  void _listenToAuthChange() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        ///user logged in load their data
        if (state.userId != user.uid) {
          ///only reload if it's a different user
          loadUserData();
        }
      } else {
        ///user logged out-clear state
        state = ProfileState(isLoading: false);
      }
    });
  }

  ///Load user data from firebase
  Future<void> loadUserData([User? user]) async {
    final currentUser = user ?? FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      state = ProfileState(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        state = ProfileState(
          userId: currentUser.uid,
          name: userDoc['name'],
          email: userDoc['email'],
          photoUrl: userDoc['photoURL'],
          createdAt: (userDoc['createdAt'] as Timestamp?)?.toDate(),
          isLoading: false,
          isUploading: false,
        );
      } else {
        state = ProfileState(
          userId: currentUser.uid,
          isLoading: false,
        );
      }
    } catch (e) {
      state = ProfileState(
        userId: currentUser.uid,
        isLoading: false,
      );
    }
  }

  ///force refresh user data
  Future<void> refreshUserData() async {
    await loadUserData();
  }

  ///pick and upload new profile image
  Future<void> pickAndUploadProfileImage(ImageSource source) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('❌ No logged-in user');
      return;
    }

    print('👤 User ID: ${user.uid}');

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);

    if (picked == null) {
      print('⚠️ Image picking cancelled');
      return;
    }

    final file = File(picked.path);

    print('📸 Image selected');
    print('📁 Local path: ${picked.path}');
    print('📏 File size: ${file.lengthSync()} bytes');

    // show image immediately
    state = state.copyWith(
      localImage: file,
      isUploading: true,
    );

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_picture')
          .child(user.uid)
          .child('profile.jpg');



      print('⬆️ Uploading image to Firebase Storage...');
      print('🗂️ Storage path: profile_picture/${user.uid}');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );

      final uploadTask = await ref.putFile(
        file,
        metadata,
      );

      print('✅ Upload completed');
      print('📊 Bytes transferred: ${uploadTask.bytesTransferred}');

      final url = await ref.getDownloadURL();

      print('🔗 Download URL received from Firebase:');
      print(url);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'photoURL': url});

      print('📝 Firestore updated with photoURL');

      state = state.copyWith(
        photoUrl: url,
        localImage: null,
        isUploading: false,
      );

      print('✅ State updated successfully');
    } catch (e) {
      print('❌ Error during upload');
      print(e);

      state = state.copyWith(
        localImage: null,
        isUploading: false,
      );
    }
  }




  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> updateName(String trim) async {}

  void removeProfilePhoto() {}
}

///provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier();
});
