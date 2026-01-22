import 'dart:io';

class ProfileState {
  final String? photoUrl;
  final String? name;
  final String? email;
  final bool isLoading;
  final bool isUploading;
  final DateTime? createdAt;
  final String? userId;
  final File? localImage;

  const ProfileState({
    this.photoUrl,
    this.name,
    this.localImage,
    this.email,
    this.isLoading = false,
    this.isUploading = false,
    this.createdAt,
    this.userId,
  });

  ProfileState copyWith({
    String? photoUrl,
    String? name,
    String? email,
    bool? isLoading,
    bool? isUploading,
    DateTime? createdAt,
    File? localImage,
    String? userId,
  }) {
    return ProfileState(
      photoUrl: photoUrl ?? this.photoUrl,
      name: name ?? this.name,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      localImage: localImage ?? this.localImage,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
