import 'dart:convert';
import 'package:bookingmovieticket/models/snack_model.dart';
import 'package:http/http.dart' as http;

class SnackPackageController {
  final String apiUrl = 'http://10.0.2.2:5130/api/snackpackages';

  Future<List<SnackPackage>> fetchSnackPackages() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      // Kiểm tra dữ liệu trả về
      print(data);

      return data.map((item) => SnackPackage.fromJson(item)).toList();
    } else {
      throw Exception("Không thể tải dữ liệu từ server");
    }
  }
}
