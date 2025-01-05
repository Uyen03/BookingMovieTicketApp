import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/theatre_model.dart';

class TheatreController extends GetxController {
  var isLoading = true.obs;
  var theatres = <Theatre>[].obs;
  var filteredTheatres = <Theatre>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTheatres();
  }

  Future<void> fetchTheatres() async {
    try {
      isLoading(true);
      var url = Uri.parse("http://10.0.2.2:5130/api/theatres");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        theatres.value = List<Theatre>.from(
          jsonData.map((item) => Theatre.fromJson(item)),
        );
        filteredTheatres.value = theatres.toList();
      } else {
        print("Failed to fetch theatres: ${response.statusCode}");
        Get.snackbar(
            'Error', 'Failed to fetch theatres: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching theatres: $e");
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  void searchTheatre(String query) {
    if (query.isEmpty) {
      filteredTheatres.value = theatres.toList();
    } else {
      filteredTheatres.value = theatres
          .where((theatre) =>
              theatre.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}
