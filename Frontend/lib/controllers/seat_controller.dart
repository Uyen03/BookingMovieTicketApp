import 'dart:convert';
import 'package:bookingmovieticket/models/seatdetail_model.dart';
import 'package:http/http.dart' as http;

class SeatController {
  final String apiUrl = 'http://10.0.2.2:5130/api/seat'; // URL API của bạn

  /// Lấy danh sách ghế theo `screenId`
  Future<List<List<SeatDetail>>> fetchSeats(int screenId) async {
    try {
      print('Fetching seats for screenId: $screenId');

      // Gửi yêu cầu GET tới API
      final response = await http.get(Uri.parse('$apiUrl?screenId=$screenId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('API Response: $data');

        // Tìm `ScreenId` trong danh sách trả về
        final screenData = data.firstWhere(
          (screen) => screen['ScreenId'] == screenId,
          orElse: () {
            print('Screen with ID $screenId not found.');
            return null; // Trả về null nếu không tìm thấy
          },
        );

        if (screenData == null) {
          throw Exception('Screen not found for the given ScreenId: $screenId');
        }

        // Kiểm tra `Arrangement`
        if (screenData['Arrangement'] == null) {
          throw Exception('No seat arrangement found for ScreenId: $screenId');
        }

        // Giải mã `Arrangement`
        final arrangementJson = json.decode(screenData['Arrangement']);
        return (arrangementJson as List)
            .map((row) =>
                (row as List).map((seat) => SeatDetail.fromJson(seat)).toList())
            .toList();
      } else {
        throw Exception(
            'Failed to load seats. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching seats: $e');
      throw Exception('Error fetching seats: $e');
    }
  }
}
