import 'package:dio/dio.dart';
import 'package:google_map_app/models/directions_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionRerpository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';
  final Dio _dio;
  DirectionRerpository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await _dio.get(_baseUrl, queryParameters: {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'key': 'YOUR API KEY',
    });

    if (response.statusCode == 200) {
      return Directions.fromMap(response.data);
    } else {
      return null;
    }
  }
}
