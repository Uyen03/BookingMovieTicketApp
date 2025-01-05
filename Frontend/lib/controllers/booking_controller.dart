import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bookingmovieticket/models/booking_model.dart';

class BookingController {
  static const String baseUrl = 'http://10.0.2.2:5130/api/Booking';

  // Lấy danh sách tất cả các booking
  Future<List<Booking>> getAllBookings() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookings: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error fetching bookings: $error');
    }
  }

  // Lấy thông tin chi tiết một booking
  Future<Booking> getBookingById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        return Booking.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load booking details: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error fetching booking details: $error');
    }
  }

  // Tạo một booking mới
  Future<Booking?> createBooking(Booking booking) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(booking.toJson()),
      );
      if (response.statusCode == 201) {
        return Booking.fromJson(json.decode(response.body));
      } else {
        print('Failed to create booking: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error creating booking: $error');
      return null;
    }
  }

  // Cập nhật một booking
  Future<Booking?> updateBooking(int id, Booking booking) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(booking.toJson()),
      );
      if (response.statusCode == 200) {
        return Booking.fromJson(json.decode(response.body));
      } else {
        print('Failed to update booking: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error updating booking: $error');
      return null;
    }
  }

  // Xóa một booking
  Future<bool> deleteBooking(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 204) {
        return true;
      } else {
        print('Failed to delete booking: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error deleting booking: $error');
      return false;
    }
  }
}
