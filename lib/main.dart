import 'dart:async';
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:camera/camera.dart';
import 'package:dummy_lat_long_app/app/modules/HomePage/controllers/home_page_controller.dart';
import 'package:dummy_lat_long_app/app/network/api_service.dart';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'app/models/data_model.dart';
import 'app/routes/app_pages.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;

final local = GetStorage();

Future sendLocation({required List<Map<String, dynamic>> data}) async {
  try {
    http.Response res = await http.post(
      Uri.parse('${ApiService().APIbaseUrl}/location'),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        "Token": "${local.read("token")}"
      },
    );
  } catch (e) {
    if (kDebugMode) {
      print("Send Location API : $e");
    }
  }
}

Future<void> initService() async {
  /**
   * This function is used for initialize flutter_background_service
   */

  FlutterBackgroundService service = FlutterBackgroundService();
  AndroidConfiguration androidConfiguration = AndroidConfiguration(
    onStart: onStart,
    isForegroundMode: true,
    autoStartOnBoot: false,
    autoStart: true,
  );
  await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: androidConfiguration);
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  bool alive = false;
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(DataModelAdapter().typeId)) {
    Hive.registerAdapter(DataModelAdapter());
  }
  HomePageController homePageController = Get.put(HomePageController());
  var myBox = await Hive.openBox<DataModel>('data');
  Socket socket;
  GetStorage storage = GetStorage();
  storage.initStorage;

  Connectivity connectivity = Connectivity();

  connectivity.onConnectivityChanged.listen((event) async {
    if (event == ConnectivityResult.none) {
      alive = false;
      if (service is AndroidServiceInstance) {
        await service.setForegroundNotificationInfo(
          title: 'Location Background Service',
          content: 'No Internet Connection',
        );
      }
    } else {
      alive = true;
      if (service is AndroidServiceInstance) {
        await service.setForegroundNotificationInfo(
          title: 'Location Background Service',
          content: 'Internet Connection Available',
        );
      }
    }
  });

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((Map<String, dynamic>? event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((Map<String, dynamic>? event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((Map<String, dynamic>? event) {
    service.stopSelf();
  });

  service.on('startService').listen((Map<String, dynamic>? d) async {
    var tripId = d!['tripId'];
    var driverId = d['driverId'];
    alive = true;
    if (service is AndroidServiceInstance) {
      await storage.initStorage;
      if (kDebugMode) {
        print("Driver Id : $driverId");
      }

      socket = io(
          'https://vehicle-backend.spideyworld.co.in/?id=$driverId',
          <String, dynamic>{
            'transports': ['websocket'],
            'autoConnect': false,
          });
      socket.connect();
      socket.onConnect((_) {
        socket.emit('msg', 'test');
      });
      socket.on(
          'tripApproved',
          (data) => {
                service.invoke("tripApproved", {"tripId": tripId}),
                // homePageController.tripApproved(true),
                // homePageController.startLoactionService(tripId: tripId),

                if (kDebugMode)
                  {
                    print(data),
                  },
                geo.Geolocator.getPositionStream(
                  locationSettings: const geo.LocationSettings(
                    accuracy: geo.LocationAccuracy.high,
                    distanceFilter: 5,
                  ),
                ).listen((event) async {
                  if (tripId == null) {
                    if (kDebugMode) {
                      print("55");
                    }
                  }

                  var vehicleId = storage.read("vehicleId");

                  // ignore: unnecessary_type_check
                  if (service is AndroidServiceInstance) {
                    await service.setForegroundNotificationInfo(
                      title: 'Running in Background',
                      content:
                          'Location Changed: ${event.latitude} ${event.longitude}',
                    );
                  }

                  if (alive) {
                    // if (kDebugMode) {
                    //   print('Connection Is On ${event.latitude}, ${event.longitude}');
                    // }
                    if (myBox.values.isNotEmpty) {
                      if (kDebugMode) {
                        print(
                            'Local database is not empty ${event.latitude}, ${event.longitude}');
                      }

                      List<Map<String, dynamic>> data =
                          myBox.values.toList().map((e) => e.toJson()).toList();

                      if (kDebugMode) {
                        //  print(data);
                      }

                      await sendLocation(data: data);
                      await myBox.clear();
                    } else {
                      // if (kDebugMode) {
                      //   print('Sending Live Location ');
                      // }
                      List<Map<String, dynamic>> location = [
                        {
                          "vehicle_id": vehicleId,
                          "driver_id": driverId,
                          "time": DateTime.now().millisecondsSinceEpoch,
                          "location": {
                            "latitude": event.latitude,
                            "longitude": event.longitude,
                          },
                          "trip_id": tripId,
                          "speed": event.speed,
                        }
                      ];
                      // print(location);
                      await sendLocation(data: location);
                    }
                  } else {
                    DataModel dmodel = DataModel(
                      vehicleId: vehicleId,
                      driverId: driverId,
                      lat: event.latitude,
                      long: event.longitude,
                      tripId: tripId,
                    );
                    await myBox.add(dmodel);
                    if (kDebugMode) {
                      // print('Data Inserted In Local Database');
                    }
                  }
                  if (kDebugMode) {
                    //  print('Location Changed: ${event.latitude} ${event.longitude}');
                  }
                })
              });

      await service.setForegroundNotificationInfo(
        title: 'Location Background Service',
        content: 'Service Started',
      );
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  await GetStorage.init();
  await initService();
  local.initStorage;
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic Notification',
            channelDescription: 'Notification channel for basic test',
            defaultColor: Colors.red,
            ledColor: Colors.red,
            importance: NotificationImportance.Max,
            criticalAlerts: true)
      ],
      debug: true);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top]);

  runApp(
    GetMaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
