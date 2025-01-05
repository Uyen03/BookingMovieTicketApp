import 'package:bookingmovieticket/models/theatre_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/calendar_controller.dart';
import '../utils/mytheme.dart';

class TheatreBlock extends StatelessWidget {
  final Theatre model;
  final bool isBooking;
  final Function(int) onTimeTap;
  final List<String> timings; // Thêm danh sách timings từ `Showtime`

  const TheatreBlock({
    Key? key,
    required this.model,
    this.isBooking = false,
    required this.onTimeTap,
    required this.timings, // Truyền danh sách timings từ ngoài vào
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var instance = CalendarController.instance;

    // Vị trí Google Maps
    CameraPosition cameraPosition = CameraPosition(
      target: model.coordinates != null
          ? LatLng(
              double.tryParse(model.coordinates!.split(',')[0]) ?? 10.823099,
              double.tryParse(model.coordinates!.split(',')[1]) ?? 106.629662,
            )
          : const LatLng(10.823099, 106.629662),
      zoom: 14.4746,
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên rạp và nút thông tin
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(model.name, style: const TextStyle(fontSize: 18)),
              GestureDetector(
                onTap: () {
                  _showTheatreDetails(context, model, cameraPosition);
                },
                child: Icon(
                  Icons.info_outline,
                  color: Colors.black45.withOpacity(0.3),
                  size: 25,
                ),
              )
            ],
          ),
          const SizedBox(height: 5),

          // Hiển thị ngày chiếu
          isBooking
              ? Text(
                  instance.format.format(instance.selectedMovieDate.value),
                  style: const TextStyle(color: Color(0xff999999)),
                )
              : RichText(
                  text: TextSpan(
                    children: [
                      const WidgetSpan(
                        child: Icon(
                          Icons.location_on,
                          size: 18,
                          color: Color(0xff999999),
                        ),
                      ),
                      TextSpan(
                        text: "${model.fullAddress}, ",
                        style: const TextStyle(color: Color(0xff999999)),
                      ),
                      const TextSpan(
                        text: "2.3km Away",
                        style: TextStyle(color: Color(0xff444444)),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 10),

          // Danh sách thời gian chiếu
          Wrap(
            runSpacing: 10,
            spacing: 20,
            children: timings.asMap().entries.map((entry) {
              int index = entry.key;
              String time = entry.value;

              Color color =
                  index % 2 == 0 ? MyTheme.orangeColor : MyTheme.greenColor;

              return GestureDetector(
                onTap: () {
                  onTimeTap(index); // Gọi sự kiện chọn thời gian
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x22E5E5E5),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      width: 1,
                      color: const Color(0xffE5E5E5),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text(
                    time,
                    style: TextStyle(color: color),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Hiển thị thông tin chi tiết của rạp trong BottomSheet
  void _showTheatreDetails(
      BuildContext context, Theatre model, CameraPosition cameraPosition) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      builder: (_) {
        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 40),
              height: double.maxFinite,
              width: double.maxFinite,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bản đồ
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: cameraPosition,
                        zoomControlsEnabled: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tên rạp và địa chỉ
                  Text(
                    model.name,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    model.fullAddress,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xff999999),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tiện ích
                  const Text(
                    "Available Facilities",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: model.facilities.map((facility) {
                      return Chip(
                        label: Text(
                          facility,
                          style: const TextStyle(color: Color(0xff444444)),
                        ),
                        backgroundColor: MyTheme.splash.withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Icon hiển thị vị trí GPS
            Container(
              height: 80,
              child: Center(
                child: CircleAvatar(
                  backgroundColor: MyTheme.splash,
                  radius: 40,
                  child: SvgPicture.asset(
                    "assets/icons/gps.svg",
                    height: 40,
                    width: 40,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
