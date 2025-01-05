import 'package:bookingmovieticket/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:io';

class ProfileController extends GetxController {
  static ProfileController instance = Get.find();
  RxString username = ''.obs;
  RxString phone = ''.obs;
  RxString avatarUrl = ''.obs; // Avatar URL mới
  RxBool isEdit = false.obs;

  // Lấy thông tin người dùng từ Firestore
  Future<void> loadUserData(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      var data = userDoc.data() as Map<String, dynamic>;
      username.value = data['username'] ?? '';
      phone.value = data['phone'] ?? '';
      avatarUrl.value = data['avatarUrl'] ?? '';
    }
  }

  // Cập nhật thông tin người dùng vào Firestore
  Future<void> saveProfile(
      String userId, String newUsername, String newPhone) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'username': newUsername,
        'phone': newPhone,
      });
      username.value = newUsername;
      phone.value = newPhone;
      isEdit.value = false; // Đóng chế độ chỉnh sửa
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile: $e");
    }
  }

  // Cập nhật ảnh đại diện URL vào Firestore
  Future<void> updateAvatarUrl(String localPath) async {
    try {
      // Lưu đường dẫn ảnh vào Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(AuthController.instance.user!.uid)
          .update({
        'avatarUrl': localPath,
      });
      avatarUrl.value = localPath; // Cập nhật ảnh đại diện mới
    } catch (e) {
      Get.snackbar("Error", "Failed to update avatar: $e");
    }
  }

  // Chuyển trạng thái chỉnh sửa
  void toggleEdit() {
    isEdit.value = !isEdit.value;
  }
}
