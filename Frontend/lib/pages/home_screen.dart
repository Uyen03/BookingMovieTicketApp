import 'dart:async';
import 'package:bookingmovieticket/controllers/auth_controller.dart';
import 'package:bookingmovieticket/controllers/location_controller.dart';
import 'package:bookingmovieticket/pages/profile_screen.dart';
import 'package:bookingmovieticket/pages/select_location_screen.dart';
import 'package:bookingmovieticket/utils/constants.dart';
import 'package:bookingmovieticket/utils/custom_slider.dart';
import 'package:bookingmovieticket/utils/dummy_data.dart';
import 'package:bookingmovieticket/utils/event_items.dart';
import 'package:bookingmovieticket/utils/menu_item.dart';
import 'package:bookingmovieticket/utils/movies_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bookingmovieticket/utils/mytheme.dart';
import 'package:bookingmovieticket/controllers/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/auth_controller.dart';
import '../utils/mytheme.dart';
import '../utils/menu_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username; // Khai báo biến username
  String city = cities[0];

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(10.823099, 106.629662), // HCM
    zoom: 14.4746,
  );

  @override
  void initState() {
    SharedPref.getLocation()
        .then((value) => LocationController.instance.setCity(value));
    super.initState();
    fetchUserData(); // Lấy dữ liệu user khi khởi tạo
  }

  void fetchUserData() async {
    User? currentUser = AuthController.instance.user;
    if (currentUser != null) {
      // Kiểm tra tài khoản đăng nhập bằng Google
      if (currentUser.providerData
          .any((provider) => provider.providerId == "google.com")) {
        // Lấy tên người dùng từ Google
        if (mounted) {
          setState(() {
            username = currentUser.displayName;
          });
        }
      } else {
        // Nếu không phải Google, lấy tên người dùng từ Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists) {
          if (mounted) {
            setState(() {
              username = userDoc['username']; // Lấy từ Firestore
            });
          }
        }
      }
    }
  }

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(10.823099, 106.629662),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: MyTheme.statusBar,
    ));
    String? picUrl = AuthController.instance.user!.photoURL;
    picUrl = picUrl ?? Constants.dummyAvatar;

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: GestureDetector(
                onTap: () {
                  Get.to(ProfileScreen());
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: picUrl,
                    height: 60,
                    width: 60,
                  ),
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hiển thị tên người dùng đã được lấy từ Firestore hoặc Google
                  Text(
                    username ??
                        "Name", // Nếu username không có thì hiển thị "Name"
                    style: TextStyle(color: Colors.white),
                  ),
                  Obx(
                    () => GestureDetector(
                      onTap: () {
                        Get.to(() => const SelectionLocationScreen());
                      },
                      child: Row(
                        children: [
                          Text(
                            LocationController.instance.city.value,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                inherit: true,
                                fontSize: 14),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white.withOpacity(0.7),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset("assets/icons/search.svg"),
              ),
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  "assets/icons/notification.svg",
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          height: size.height,
          width: size.width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: size.height * 0.22,
                  color: Colors.red,
                  child: PageView.builder(
                      itemCount: 3,
                      itemBuilder: (_, i) {
                        return CustomSlider(
                          index: i,
                        );
                      }),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 20),
                  child: Text(
                    "SEAT CATEGORIES",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.8)),
                  ),
                ),
                MyMenuItem(),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 10),
                  child: Text(
                    "RECOMMEND SEATS",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.8)),
                  ),
                ),
                MyMovieItem(),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 10, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        " NEARBY THEATRES ".toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.8)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          " View All ",
                          style: TextStyle(color: MyTheme.splash),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: size.height * 0.2,
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _kGooglePlex,
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      )
                    },
                    onMapCreated: (GoogleMapController controller) {
                      //_controller.complete(controller);
                    },
                    zoomControlsEnabled: true,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 10, right: 20),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/spotlights.svg",
                        color: Colors.black.withOpacity(0.8),
                        height: 18,
                        width: 18,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Events".toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.8)),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "View All",
                          style: TextStyle(color: MyTheme.splash),
                        ),
                      ),
                    ],
                  ),
                ),
                EventItems(
                  events: events,
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 10, right: 20),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/theater_masks.svg",
                        color: Colors.black.withOpacity(0.8),
                        height: 18,
                        width: 18,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Plays".toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.8)),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "View All",
                          style: TextStyle(color: MyTheme.splash),
                        ),
                      ),
                    ],
                  ),
                ),
                EventItems(
                  events: plays,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
