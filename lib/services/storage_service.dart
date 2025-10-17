import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:culture_connection/constants/app_constants.dart';

/// Firebase Storage service for file uploads
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile photo
  Future<String> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child(
          '${AppConstants.storageProfilePhotos}/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  /// Upload post photo
  Future<String> uploadPostPhoto(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child(
          '${AppConstants.storagePostPhotos}/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload post photo: $e');
    }
  }

  /// Upload event photo
  Future<String> uploadEventPhoto(File imageFile) async {
    try {
      final ref = _storage.ref().child(
          '${AppConstants.storageEventPhotos}/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload event photo: $e');
    }
  }

  /// Delete file from storage
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
}
