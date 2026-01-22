import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widgets/card_decoration.dart';
import '../../../model/user_profile_model.dart';
import '../../../providers/user_profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _nameController;
  String? lastUserId;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(profileProvider).name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);
    final currentUser = FirebaseAuth.instance.currentUser;

    ///Check if user has changed and refresh if needed
    if (currentUser != null && currentUser.uid != lastUserId) {
      lastUserId = currentUser.uid;

      ///user addPostFrameCallBack to avoid calling seState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          notifier.refreshUserData();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: RefreshIndicator(
        color: kPrimary,
        backgroundColor: Colors.white,
        onRefresh: () async {
          await notifier.refreshUserData();
        },
        child:state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
          shrinkWrap: true,

              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
              children: [
                _profileAvatar(state),
                const SizedBox(height: 10),
                Text(state.name ?? '--', textAlign: TextAlign.center,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(state.email ?? '--', textAlign: TextAlign.center,style: const TextStyle(fontSize: 16,color: Colors.grey)),
                const SizedBox(height: 10),
                ///Display join date
                Text('Joined ${state.createdAt != null ? DateFormat('MMM d, y').format(state.createdAt!): '--'}', textAlign: TextAlign.center,style: const TextStyle(fontSize: 16,color: Colors.grey)),
                const SizedBox(height: 10),
                const SizedBox(height: 32),
                _saveButton(),
              ],
            ),
      ));
  }

  /* ---------------- PROFILE AVATAR ---------------- */

  Widget _profileAvatar(ProfileState state) {
    ImageProvider? image;

    if (state.localImage != null) {
      image = FileImage(state.localImage!);
    } else if (state.photoUrl != null) {
      image = NetworkImage(state.photoUrl!);
    }

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            decoration: AppDecorations.card3D(),
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              radius: 56,
              backgroundColor: kAccent.withOpacity(0.15),
              backgroundImage: image,
              child: image == null
                  ? const Icon(Icons.person, size: 48, color: kPrimary)
                  : null,
            ),
          ),
          InkWell(
            onTap: state.isUploading ? null : _showImageSourceSheet,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: kPrimary,
              child: state.isUploading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.camera_alt, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /* ---------------- BOTTOM SHEET ---------------- */

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            _sheetHandle(),
            _sheetItem(
              Icons.camera_alt,
              'Camera',
              () => _pick(ImageSource.camera),
            ),
            _sheetItem(
              Icons.photo_library,
              'Gallery',
              () => _pick(ImageSource.gallery),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _pick(ImageSource source) {
    Navigator.pop(context);
    ref.read(profileProvider.notifier).pickAndUploadProfileImage(source);
  }

  Widget _sheetHandle() => Container(
    width: 36,
    height: 4,
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _sheetItem(IconData icon, String label, VoidCallback onTap) =>
      ListTile(
        leading: CircleAvatar(
          backgroundColor: kAccent.withOpacity(0.15),
          child: Icon(icon, color: kAccent),
        ),
        title: Text(label),
        onTap: onTap,
      );

  /* ---------------- SAVE ---------------- */

  Widget _saveButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () {
        final state = ref.read(profileProvider);

        print('💾 Save Changes tapped');
        print('👤 User ID: ${state.userId}');
        print('🧑 Name: ${state.name}');
        print('📧 Email: ${state.email}');
        print('🖼️ Photo URL: ${state.photoUrl}');
        print('📂 Local image exists: ${state.localImage != null}');
        print('⏳ Is uploading: ${state.isUploading}');

        Navigator.pop(context);
      },
      child: const Text(
        'Save Changes',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }

}
