import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:camera/camera.dart';
import 'package:dummy_lat_long_app/app/network/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../routes/app_pages.dart';

class HomePageController extends GetxController {
  RxBool tripApproved = false.obs;
  RxBool isLoading = false.obs;
  RxBool locationStarted = false.obs;
  RxBool vehicleSet = false.obs;
  RxBool progress = false.obs;
  RxBool isRecording = false.obs;
  RxList<CameraDescription>? cameras = <CameraDescription>[].obs;
  CameraController? cameraController;
  final ApiService _apiService = ApiService();
  RxString currentAddress = ''.obs;
  RxString driverPin = ''.obs;
  RxString driverName = ''.obs;
  RxString vehicleName = ''.obs;
  TextEditingController passengerController = TextEditingController();
  TextEditingController odometerController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Rx<Position> currentPosition = Position(
    latitude: 0.0,
    longitude: 0.0,
    timestamp: DateTime.now(),
    accuracy: 0.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  ).obs;

  RxDouble newlat = 0.0.obs, newlng = 0.0.obs;
  RxDouble lat = 0.0.obs, lng = 0.0.obs;

  var subscription;
  RxInt speed = 0.obs;

  GoogleMapController? mapController;
  GetStorage storage = GetStorage();
  RxList<LatLng> points = <LatLng>[].obs;
  RxMap<PolylineId, Polyline> polyline = <PolylineId, Polyline>{}.obs;
  RxBool isEnabled = false.obs;

  RxInt statusCode = 0.obs;

  Rx<CameraPosition> cameraPosition = const CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 16,
  ).obs;

  void changeGreenLocation({required double lat, required double lng}) {
    newlat.value = lat;
    newlng.value = lng;
  }

  void changeRedLocation({required double lat, required double lng}) {
    this.lat.value = lat;
    this.lng.value = lng;
  }

  @override
  void onInit() async {
    storage.initStorage;
    await Permission.storage.request();
    FlutterBackgroundService()
        .on("tripApproved")
        .listen((Map<String, dynamic>? d) {
      var tripId = d!['tripId'];

      if (kDebugMode) print("Trip Approved with id $tripId");
      // tripApproved(true);

      startLoactionService(tripId: tripId);
      recordVideo(tripId);
      Fluttertoast.showToast(msg: 'new Trip started');
    });
    await isVehicleSet();
    await isUserLoggedIn();

    await loadCamera();
    permissionForLocation().then((value) async {
      if (kDebugMode) {
        print(value);
      }

      if (value) {
        await getCurrentLocationAndSet();
      } else {
        Get.dialog(
          AlertDialog(
            title: const Text("Location Permission"),
            content:
                const Text("Please allow location permission from settings"),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text("Ok"),
              ),
            ],
          ),
        );
      }
      return value;
    });
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    if (storage.read("token") != null) {
      if (kDebugMode) print("Token is ${storage.read("token")}");
      await isTripOnGoing();
      await alreadyServiceRunning();
    }

    super.onInit();
  }

  loadCamera() async {
    try {
      cameras?.value = await availableCameras();

      if (cameras != null) {
        cameraController =
            CameraController(cameras![0], ResolutionPreset.medium);
        await cameraController!.initialize();

        if (!cameraController!.value.isInitialized) {
          Fluttertoast.showToast(msg: "Camera not initialized");
        }
      } else {
        Fluttertoast.showToast(msg: "Camera not Found");
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
      // Fluttertoast.showToast(msg: e.toString());
    }
  }

  recordVideo(String tripId) async {
    if (!cameraController!.value.isInitialized) {
      Fluttertoast.showToast(msg: "Camera not initialized");
      return;
    }
    if (cameraController!.value.isRecordingVideo) {
      XFile videoFile = await cameraController!.stopVideoRecording();

      final path = await getExternalStorageDirectories();

      if (path == null || path.isEmpty) {
        Fluttertoast.showToast(msg: "Storage not found");
        return;
      }
      //   String tripId = await storage.read("tripId");
      if (kDebugMode) {
        print(path);
      }
      await videoFile.saveTo("${path[0].path}/$tripId(${DateTime.now()}).mp4");
      if (kDebugMode) {
        print("Video Saved to ${path[0].path}");
      }
      Fluttertoast.showToast(msg: "Video Recorded");
    } else {
      try {
        await cameraController!.startVideoRecording();
        Fluttertoast.showToast(msg: "Recording Started");
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  stopVideoRecording() async {
    if (!cameraController!.value.isInitialized) {
      Fluttertoast.showToast(msg: "Camera not initialized");
      return;
    }
    if (cameraController!.value.isRecordingVideo) {
      final file = await cameraController!.stopVideoRecording();
      var filePath = file.path;
      if (kDebugMode) print(filePath);

      Fluttertoast.showToast(msg: "Video Recorded");
    }
  }

  alreadyServiceRunning() async {
    bool status = await FlutterBackgroundService().isRunning();

    if (status) {
      FlutterBackgroundService().reactive();
    }
  }

  Future getCurrentLocationAndSet() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      changeRedLocation(lat: position.latitude, lng: position.longitude);
      isLoading.value = true;
      cameraPosition.value = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 16,
      );

      getAddress(position);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> getAddress(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      currentAddress.value = " ${place.subLocality}, ${place.locality} ";
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  isTripOnGoing() async {
    var response = await _apiService
        .getCall("/trip/status?vehicle_id=${storage.read("vehicleId")}");

    if (!response.status.hasError) {
      List<LatLng>? locations = [];
      if (kDebugMode) {
        print(response.body);
      }
      isEnabled(true);
      if (response.body["status"] == "true") {
        storage.write("tripId", response.body['data'][0]['_id']);
        if (kDebugMode) {
          print("Trip Id :-${storage.read("tripId")}");
        }
        if (response.body['data'][0]['location'] != null &&
            response.body['data'][0]['location'].length > 0) {
          response.body['data'][0]['location'].forEach((e) {
            locations.add(LatLng(e['latitude'], e['longitude']));
          });

          double latitude = response
                      .body['data'][0]['startLocation']['latitude']
                      .runtimeType ==
                  int
              ? response.body['data'][0]['startLocation']['latitude'].toDouble()
              : response.body['data'][0]['startLocation']['latitude'];
          double long = response.body['data'][0]['startLocation']['longitude']
                      .runtimeType ==
                  int
              ? response.body['data'][0]['startLocation']['longitude']
                  .toDouble()
              : response.body['data'][0]['startLocation']['longitude'];
          changeRedLocation(lat: latitude, lng: long);
          cameraPosition.value = CameraPosition(
            target: LatLng(latitude, long),
            zoom: 16,
          );
        }
        await startLoactionService(
            tripId: response.body['data'][0]['_id'], locationList: locations);
        recordVideo(response.body['data'][0]['_id']);
        Fluttertoast.showToast(msg: 'Started Existing Trip');
      } else if (response.body["status"] == "Trip Not Approved Yet") {
        locationStarted(true);
        Fluttertoast.showToast(msg: response.body['status']);
      }
    } else {
      if (kDebugMode) {
        print("Ongoing trip api  ${response.statusText.toString()}");
      }
      if (response.statusText.toString() == "Unauthorized") {
        storage.remove("token");
        Get.currentRoute == Routes.HOME_PAGE
            ? Fluttertoast.showToast(msg: "Session Expired")
            : Get.offAndToNamed(Routes.HOME_PAGE);
      } else {
        Fluttertoast.showToast(msg: response.statusText.toString());
      }
    }
  }

  isVehicleSet() async {
    if (storage.read("vehicleName") == null) {
      vehicleName.value = "Not Set";
      vehicleSet(true);
    } else {
      vehicleName.value = storage.read("vehicleName");
    }
  }

  verifyId() async {
    var response = await _apiService.postCall("/user/login", {
      "pin": driverPin.value,
    });
    // print(response.body);
    if (!response.status.hasError) {
      if (response.body["message"] != null) {
        Get.offAndToNamed(Routes.ADMIN, arguments: driverPin);
      } else if (response.body["id"] != null) {
        //   print(jsonEncode(response.body));
        await storage.write("driverName", response.body["name"]);

        if (vehicleName.value == "Not Set") {
          vehicleSet(true);
        }
        await storage.write("token", response.body["token"]);

        await storage.write("driverId", response.body["id"]);
        isTripOnGoing();
        isEnabled(true);
      }
    } else {
      if (response.statusText.toString() == "Unauthorized") {
        storage.remove("token");
        Get.currentRoute == Routes.HOME_PAGE
            ? Fluttertoast.showToast(msg: "Session Expired Please Login Again")
            : Get.offAndToNamed(Routes.HOME_PAGE);
      } else {
        if (response.body["message"] != null) {
          if (kDebugMode) {
            print("Verify Id API  ${response.body["message"]}");
          }
          Fluttertoast.showToast(
            msg: response.body["message"],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          if (kDebugMode) {
            print("  printing 2");
          }
          Fluttertoast.showToast(
            msg: response.statusText.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    }
  }

  isUserLoggedIn() async {
    if (storage.read("token") != null) {
      isEnabled(true);
    } else {
      isEnabled(false);
    }
  }

  static Future<bool> permissionForLocation() async {
    //  await Geolocator.requestPermission();
    final request = await [Permission.location].request();
    final status = await Permission.location.status;

    if (status.isDenied) {
      request;
      return false;
    } else if (status.isRestricted) {
      request;
      return false;
    } else if (status.isLimited) {
      request;
      return false;
    } else {
      return true;
    }
  }

  cancelPolyline() {
    locationStarted(false);
    speed.value = 0;
    if (kDebugMode) print(subscription.runtimeType);
    if (subscription != null) {
      subscription.cancel();
    }
  }

  registerlistner(GoogleMapController controller) async {
    mapController = controller;
  }

  clearploylines() async {
    points.clear();
    polyline.value = {};
    polyline.refresh();
  }

  createTrip() async {
    progress(true);
    var vehicleId = storage.read("vehicleId");
    if (vehicleId != null) {
      Position position = await Geolocator.getCurrentPosition();
      points.clear();
      polyline.value = {};
      polyline.refresh();
      if (subscription != null) {
        subscription.cancel();
      }
      var response = await _apiService.postCall("/trip", {
        "vehicle_id": vehicleId,
        "driver_id": storage.read("driverId"),
        "startLocation": {
          "longitude": position.longitude,
          "latitude": position.latitude,
        },
        "startTime": DateTime.now().millisecondsSinceEpoch,
        "passenger": passengerController.text,
        "startOdometer": double.parse(odometerController.text),
        "tripDestination": destinationController.text,
        "tripPurpose": descriptionController.text,
        "startGeolocation": currentAddress.value,
      });

      if (!response.status.hasError) {
        if (kDebugMode) {
          print("Trip Id :- ${response.body['_id']}");
        }

        await storage.write("tripId", response.body['_id']);

        passengerController.clear();
        destinationController.clear();
        descriptionController.clear();
        odometerController.clear();

        FlutterBackgroundService().invoke("startService", {
          "tripId": response.body['_id'],
          "driverId": storage.read("driverId")
        });

        locationStarted(true);
        changeRedLocation(lat: position.latitude, lng: position.longitude);
        // startLoactionService(tripId: response.body['_id']);
        Fluttertoast.showToast(msg: "Trip Request Sent");
      } else {
        if (response.statusText.toString() == "Unauthorized") {
          storage.remove("token");
          Get.currentRoute == Routes.HOME_PAGE
              ? Fluttertoast.showToast(msg: "Session Expired")
              : Get.offAndToNamed(Routes.HOME_PAGE);
        } else {
          if (response.body["message"] != null) {
            Fluttertoast.showToast(msg: response.body["message"]);
          } else {
            Fluttertoast.showToast(msg: response.statusText.toString());
          }
        }
      }
      progress(false);
    }
  }

  startLoactionService(
      {required String tripId, List<LatLng>? locationList}) async {
    locationStarted(true);
    tripApproved(true);
    if (locationList != null && locationList.isNotEmpty) {
      List<LatLng> locations = locationList;
      points.value.clear();
      polyline.value = {};
      points.addAll(locations);
      polyline.value = {
        const PolylineId("poly"): Polyline(
          polylineId: const PolylineId("poly"),
          color: Colors.blue,
          width: 5,
          points: points,
        )
      };
      polyline.refresh();
    }

    subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((event) async {
      if (mapController != null) {
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(event.latitude, event.longitude),
              zoom: 16,
            ),
          ),
        );

        speed.value = (event.speed * 18) ~/ 5;
        speed.refresh();
        if (speed.value > 100) {
          triggerNotification();
        }

        if (isEnabled.isTrue) {
          changeGreenLocation(lat: event.latitude, lng: event.longitude);
          currentPosition.value = Position(
              longitude: event.longitude,
              latitude: event.latitude,
              timestamp: event.timestamp,
              accuracy: event.accuracy,
              altitude: event.altitude,
              heading: event.heading,
              speed: event.speed,
              speedAccuracy: event.speedAccuracy);
          points.add(
            LatLng(event.latitude, event.longitude),
          );
          polyline.value = {
            const PolylineId("poly"): Polyline(
              polylineId: const PolylineId("poly"),
              color: Colors.blue,
              width: 5,
              points: points,
            )
          };

          polyline.refresh();
        }
      }
    });
  }

  endTrip() async {
    progress(true);
    var body = {
      "trip_id": storage.read("tripId"),
      "endLocation": {
        "logitude": newlng.value,
        "latitude": newlat.value,
      },
      "endTime": DateTime.now().millisecondsSinceEpoch,
      "endOdometer": double.parse(odometerController.text),
      "endGeolocation": currentAddress.value,
    };

    var response = await _apiService.patchCall("/trip/update", body);

    if (!response.status.hasError) {
      await storage.remove('location-${storage.read('tripId')}');
      tripApproved(false);
      Get.back();
      cancelPolyline();
      FlutterBackgroundService().invoke("stopService");
      Fluttertoast.showToast(msg: "Trip Ended");
      speed.value = 0;
      odometerController.clear();
      await recordVideo(storage.read("tripId"));
      storage.remove("tripId");
    } else {
      if (kDebugMode) {
        print("End Trip: ${response.body}");
      }

      if (response.statusText.toString() == "Unauthorized") {
        storage.remove("token");
        Get.currentRoute == Routes.HOME_PAGE
            ? Fluttertoast.showToast(msg: "Session Expired")
            : Get.offAndToNamed(Routes.HOME_PAGE);
      } else {
        if (response.body["message"] != null) {
          Fluttertoast.showToast(msg: response.body["message"]);
        } else {
          Fluttertoast.showToast(msg: response.statusText.toString());
        }
      }
    }
    progress(false);
  }

  triggerNotification() {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: 'basic_channel',
            title: 'Speed Limit',
            body: 'Your Speed has been off the limit',
            displayOnForeground: true,
            criticalAlert: true,
            showWhen: true));
  }
}

enum PermissionGroup { locationAlways, locationWhenInUse }
