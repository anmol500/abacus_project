import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class PostData {
  PostData({required this.position});
  Position? position;

  postData() async {
    try {
      final Map<String, dynamic> activityData = {
        "longitude": position!.longitude,
        "latitude": position!.latitude,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "accuracy": position!.accuracy,
        "altitude": position!.altitude,
        "floor": null,
        "heading": position!.heading,
        "speed": position!.speed,
        "speed_accuracy": position!.speedAccuracy,
        "is_mocked": false
      };
      var url = Uri.parse('http://142.93.212.17:9043/saveLocation');
      var response = await http.post(
        url,
        body: json.encode(activityData),
        headers: {
          "content-type": "application/json",
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response status: ${response.body}');
    } catch (e) {
      print(e);
    }
  }
}
