import 'dart:isolate';

import 'package:abacus_project/Services/PostData.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:neumorphic_container/neumorphic_container.dart';
import 'package:permission_handler/permission_handler.dart';

import 'notification.dart' as noti;

const fetchBackground = "fetchBackground";
var position;

getUserPosition() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.location,
    Permission.storage,
  ].request();
  print(statuses[Permission.location]);

  Position userLocation = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      forceAndroidLocationManager: true);
  noti.Notification notification = noti.Notification();
  notification.showNotificationWithoutSound(userLocation);
  position = userLocation;
  print("uppperrrr   $position");
  PostData(position: position).postData();
  TrackingPage(
    p: position,
  );
  return position;
}

void alarmRunner() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  getUserPosition();
}

class TrackingPage extends StatefulWidget {
  TrackingPage({this.p});
  var p;
  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  var day;
  var date;
  var time;
  var positions;
  void getDate() {
    print(DateTime.now().millisecondsSinceEpoch);
    day = formatDate(DateTime.now(), [MM]);
    date = formatDate(DateTime.now(), [dd]);
    time = formatDate(DateTime.now(), [HH, ':', nn, ':', ss]);
  }

  getPos() async {
    positions = await getUserPosition();
    print("triiggeree $positions");
    setState(() {});
  }

  startAlarm() async {
    await AndroidAlarmManager.initialize();
    await AndroidAlarmManager.periodic(
        const Duration(seconds: 2), 1, alarmRunner,
        exact: true);
  }

  @override
  void initState() {
    super.initState();
    getDate();
    startAlarm();
    getPos();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              getPos();
            });
          },
        ),
        backgroundColor: Color(0xfff0f0f0),
        body: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: NeumorphicContainer(
                    width: double.infinity,
                    borderRadius: 10,
                    primaryColor: Color(0xfff0f0f0),
                    curvature: Curvature.flat,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                                text: 'On ',
                                style: TextStyle(
                                    color: Colors.black38, fontSize: 22),
                                children: [
                                  TextSpan(
                                      text: '$day ',
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 25)),
                                  TextSpan(
                                      text: '${date}th',
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 25)),
                                ]),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text('Your Current Location is-',
                              style: TextStyle(
                                  color: Colors.black38, fontSize: 20)),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  'X: ${positions == null ? 'geting position' : double.parse(positions!.latitude.toString()).toStringAsFixed(6)}',
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                    'Y: ${positions == null ? 'geting position' : double.parse(positions!.longitude.toString()).toStringAsFixed(6)}',
                                    style: TextStyle(fontSize: 17)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 35,
                          ),
                          RichText(
                            text: TextSpan(
                                text: 'Last time tracked: ',
                                style: TextStyle(
                                    color: Colors.black38, fontSize: 22),
                                children: [
                                  TextSpan(
                                      text: '$time ',
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 25)),
                                ]),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Future<Position> _determinePosition() async {
//   bool serviceEnabled;
//   LocationPermission permission;
//
//   // Test if location services are enabled.
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     // Location services are not enabled don't continue
//     // accessing the position and request users of the
//     // App to enable the location services.
//     return Future.error('Location services are disabled.');
//   }
//
//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       // Permissions are denied, next time you could try
//       // requesting permissions again (this is also where
//       // Android's shouldShowRequestPermissionRationale
//       // returned true. According to Android guidelines
//       // your App should show an explanatory UI now.
//       return Future.error('Location permissions are denied');
//     }
//   }
//
//   if (permission == LocationPermission.deniedForever) {
//     // Permissions are denied forever, handle appropriately.
//     return Future.error(
//         'Location permissions are permanently denied, we cannot request permissions.');
//   }
//
//   // When we reach here, permissions are granted and we can
//   // continue accessing the position of the device.
// //   return await Geolocator.getCurrentPosition(
// //       desiredAccuracy: LocationAccuracy.bestForNavigation);
// // }
