// Import các thư viện cần thiết
import 'dart:async';
import 'package:bookingmovieticket/models/user_model.dart';
import 'package:bookingmovieticket/pages/home_screen.dart';
import 'package:bookingmovieticket/pages/login_screen.dart';
import 'package:bookingmovieticket/utils/mytheme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  bool isLoging = false;

  User? get user => _user.value;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// **Bổ sung thêm Getter `currentUser`:**
  /// Lấy thông tin `UserModel` từ Firestore của người dùng hiện tại
  Future<UserModel?> get currentUser async {
    if (user != null) {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(auth.currentUser);
    _user.bindStream(auth.authStateChanges());
    ever(_user, loginRedirect);
  }

  void loginRedirect(User? user) async {
    if (user == null) {
      Get.offAll(() => const LoginScreen());
    } else {
      // Lấy thông tin người dùng từ Firestore
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        UserModel currentUserModel =
            UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        Get.put<UserModel>(currentUserModel); // Đăng ký UserModel vào GetX
      }
      Get.offAll(() => HomeScreen());
    }
  }

  // Đăng ký người dùng mới
  void registerUser(
      String email, String password, String username, String phone) async {
    try {
      isLoging = true;
      update();
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        // Tạo UserModel
        UserModel newUser = UserModel(
          userId: currentUser.uid,
          username: username,
          email: email,
          phone: phone,
          role: 'client',
          createdAt: DateTime.now(),
          avatarUrl: '', // Thêm avatarUrl
        );

        // Lưu UserModel vào Firestore
        await firestore
            .collection('users')
            .doc(currentUser.uid)
            .set(newUser.toMap());
        getSuccessSnackBar("User registered successfully!");
      }
    } on FirebaseAuthException catch (e) {
      getErrorSnackBar("Account creation failed", e);
    }
  }

  // Đăng nhập
  void login(String email, String password) async {
    try {
      isLoging = true;
      update();
      await auth.signInWithEmailAndPassword(email: email, password: password);
      updateUserInFirestore(); // Cập nhật thông tin vào Firestore
      getSuccessSnackBar(
          "Successfully logged in as ${auth.currentUser!.email}");
    } on FirebaseAuthException catch (e) {
      getErrorSnackBar("Login failed", e);
    }
  }

  // Cập nhật thông tin người dùng vào Firestore nếu chưa có
  void updateUserInFirestore() async {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists) {
        // Lấy username từ Firestore
        String username = userDoc['username'] ?? 'New User';

        // Cập nhật username trong AuthController
        _user.value = currentUser;
        update(); // Thông báo cho UI cập nhật
      } else {
        // Nếu chưa có, tạo mới người dùng trong Firestore
        UserModel newUser = UserModel(
          userId: currentUser.uid,
          username: 'New User', // Dùng mặc định nếu không có
          email: currentUser.email ?? '',
          phone: 'Unknown',
          role: 'client',
          createdAt: DateTime.now(),
          avatarUrl: '', // Thêm avatarUrl nếu cần
        );

        await firestore
            .collection('users')
            .doc(currentUser.uid)
            .set(newUser.toMap());
        getSuccessSnackBar("User information updated in Firestore!");
      }
    }
  }

  // Đăng nhập bằng Google
  void googleLogin() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    isLoging = true;
    update();
    try {
      googleSignIn.disconnect();
    } catch (e) {}
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication? googleAuth =
            await googleSignInAccount.authentication;
        final credentials = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        UserCredential userCredential =
            await auth.signInWithCredential(credentials);
        User? currentUser = userCredential.user;

        // Lấy tên và avatar từ tài khoản Google
        String googleUsername = currentUser?.displayName ?? 'Google User';
        String? googleAvatarUrl = currentUser?.photoURL;

        // Cập nhật thông tin vào Firestore
        if (currentUser != null) {
          DocumentSnapshot userDoc =
              await firestore.collection('users').doc(currentUser.uid).get();

          if (!userDoc.exists) {
            UserModel newUser = UserModel(
              userId: currentUser.uid,
              username: googleUsername,
              email: currentUser.email ?? '',
              phone: 'Unknown',
              role: 'client',
              createdAt: DateTime.now(),
              avatarUrl: googleAvatarUrl ?? '', // Lưu URL avatar
            );

            await firestore
                .collection('users')
                .doc(currentUser.uid)
                .set(newUser.toMap());
          } else {
            // Cập nhật avatar nếu đã có trong Firestore
            await firestore.collection('users').doc(currentUser.uid).update({
              'avatarUrl': googleAvatarUrl ?? '', // Cập nhật avatar
            });
          }
        }
        getSuccessSnackBar("Successfully logged in as ${currentUser?.email}");
      }
    } on FirebaseAuthException catch (e) {
      getErrorSnackBar("Google login failed", e);
    }
  }

  // Quên mật khẩu
  void forgotPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      getSuccessSnackBar("Reset mail sent successfully. Check mail!");
    } on FirebaseAuthException catch (e) {
      getErrorSnackBar("Error", e);
    }
  }

  // Đăng xuất
  void signOut() async {
    await auth.signOut();
    Get.offAll(() => const LoginScreen());
  }

  // Hiển thị thông báo lỗi
  void getErrorSnackBar(String message, FirebaseAuthException e) {
    Get.snackbar(
      "Error",
      "$message\n${e.message}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: MyTheme.redTextColor,
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
    );
  }

  // Hiển thị thông báo lỗi chung
  void getErrorSnackBarNew(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: MyTheme.redTextColor,
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
    );
  }

  // Hiển thị thông báo thành công
  void getSuccessSnackBar(String message) {
    Get.snackbar(
      "Success",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: MyTheme.greenTextColor,
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
    );
  }
}
