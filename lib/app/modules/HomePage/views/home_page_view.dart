import 'package:dummy_lat_long_app/app/routes/app_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../controllers/home_page_controller.dart';

class HomePageView extends GetView<HomePageController> {
  const HomePageView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
        actions: [
          Obx(
            () => controller.isEnabled.value
                ? PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: const [
                              Icon(
                                Icons.currency_rupee,
                                color: Colors.red,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("My Expenses"),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Row(
                            children: const [
                              Icon(
                                Icons.turn_slight_right_sharp,
                                color: Colors.red,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("My Trips"),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 3,
                          child: Row(
                            children: [
                              Transform.scale(
                                  scaleX: -1,
                                  child: const Icon(
                                    Icons.logout,
                                    color: Colors.red,
                                  )),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text("Log Out"),
                            ],
                          ),
                        ),
                      ];
                    },
                    onSelected: (value) {
                      if (value == 1) {
                        Get.toNamed(Routes.EXPENSES);
                      } else if (value == 2) {
                        Get.toNamed(Routes.MY_TRIPS);
                      } else if (value == 3) {
                        Get.defaultDialog(
                          title: "Logout",
                          middleText: "Your trip will also end ",
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text("No"),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (controller.tripApproved.value) {
                                  await controller.endTrip();
                                }
                                FlutterBackgroundService()
                                    .invoke("stopService");
                                controller.storage.remove("driverId");
                                controller.storage.remove("driverName");
                                controller.storage.remove("token");

                                controller.isEnabled.value = false;
                                controller.clearploylines();
                                Get.offAllNamed(Routes.HOME_PAGE);
                              },
                              child: const Text("Yes"),
                            ),
                          ],
                        );
                      }
                    },
                  )
                : Container(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: Get.height * 0.5,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                  child: Obx(
                    () {
                      return controller.isLoading.value
                          ? GoogleMap(
                              gestureRecognizers: <
                                  Factory<OneSequenceGestureRecognizer>>{
                                Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer(),
                                ),
                              },
                              mapType: MapType.normal,
                              onMapCreated: controller.registerlistner,
                              initialCameraPosition:
                                  controller.cameraPosition.value,
                              markers: {
                                Marker(
                                  markerId: const MarkerId("1"),
                                  position: LatLng(
                                    controller.lat.value,
                                    controller.lng.value,
                                  ),
                                ),
                                controller.isEnabled.isTrue
                                    ? Marker(
                                        icon: BitmapDescriptor
                                            .defaultMarkerWithHue(
                                                BitmapDescriptor.hueGreen),
                                        markerId: const MarkerId("2"),
                                        position: LatLng(
                                          controller.newlat.value,
                                          controller.newlng.value,
                                        ),
                                      )
                                    : Marker(
                                        markerId: const MarkerId("1"),
                                        position: LatLng(
                                          controller.lat.value,
                                          controller.lng.value,
                                        ),
                                      ),
                              },
                              polylines:
                                  controller.polyline.value.values.toSet(),
                            )
                          : const Center(
                              child: CircularProgressIndicator.adaptive(),
                            );
                    },
                  ),
                ),
              ),
            ),
            Obx(
              () => RichText(
                text: TextSpan(
                  text: "Current Vehicle is ",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                  children: [
                    TextSpan(
                      text: controller.vehicleName.value,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: Get.height * 0.01,
            ),
            Obx(
              () => !controller.isEnabled.value
                  ? Column(
                      children: [
                        Text(
                          "Enter ${controller.vehicleSet.value ? "Admin" : "Driver"} Pin",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 0.01 * Get.height,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: PinCodeTextField(
                            onChanged: (value) {
                              controller.driverPin.value = value;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            appContext: context,
                            length: 6,
                            validator: (value) {
                              if (value != null) {
                                if (value.length < 6) {
                                  Future.delayed(
                                      const Duration(milliseconds: 0), () {
                                    controller.isEnabled.value = false;
                                  });
                                  return "Please Enter valid Pin";
                                }
                              } else {
                                return "Enter Pin";
                              }
                              return null;
                            },
                            onCompleted: (value) {
                              controller.verifyId();
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                                text: TextSpan(
                              text: "Forgot Pin? ",
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                              ),
                              children: [
                                TextSpan(
                                  text: "Click Here",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    // decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      controller.driverPin.value = "";
                                      Get.toNamed(Routes.NEW_PIN_PAGE);
                                    },
                                )
                              ],
                            )),
                          ),
                        ),
                      ],
                    )
                  : controller.vehicleSet.value
                      ? const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "Logout and please set vehile using admin login to start",
                            style: TextStyle(
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.red,
                                  offset: Offset(5.0, 5.0),
                                ),
                              ],
                              fontSize: 19,
                            ),
                          ),
                        )
                      : Obx(
                          () => SizedBox(
                            child: Column(
                              children: [
                                Text(
                                  !controller.locationStarted.value
                                      ? "Trip Stopped "
                                      : controller.tripApproved.value
                                          ? "Trip Started "
                                          : "Trip Request Sent",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: IntrinsicWidth(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Container(
                                              height: Get.height * 0.1,
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.5),
                                                      spreadRadius: 5,
                                                      blurRadius: 7,
                                                      offset: const Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                  color: Colors.grey[200],
                                                  shape: BoxShape.circle),
                                              child: Obx(
                                                () => Center(
                                                  child: Text(
                                                      "${controller.speed.value > 0 ? controller.speed.value.toStringAsFixed(2) : "0"} km/h"),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: RichText(
                                          // overflow: TextOverflow.clip,
                                          text: TextSpan(
                                            text: "Driver Name: ",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 18,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: controller.storage
                                                    .read("driverName"),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
            ),
            SizedBox(
              height: 0.03 * Get.height,
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => !controller.isEnabled.value || controller.vehicleSet.value
            ? Container()
            : FloatingActionButton.extended(
                label: controller.progress.value
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : !controller.locationStarted.value
                        ? const Text("Start Trip")
                        : const Text("Stop Trip"),
                backgroundColor: Colors.red,
                onPressed: controller.progress.value
                    ? null
                    : !controller.locationStarted.value
                        ? () async {
                            controller.progress.value = true;
                            await controller.getCurrentLocationAndSet();
                            Get.defaultDialog(
                              title:
                                  "Starting Trip at ${DateFormat.jm().format(DateTime.now())}",
                              content: SizedBox(
                                height: Get.height * 0.3,
                                child: SingleChildScrollView(
                                  child: Form(
                                    key: formKey,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        children: [
                                          Text(
                                              "Current Location: ${controller.currentAddress.value}"),
                                          TextFormField(
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty ||
                                                  value.length < 3) {
                                                return "Enter valid name";
                                              } else {
                                                return null;
                                              }
                                            },
                                            controller:
                                                controller.passengerController,
                                            decoration: const InputDecoration(
                                              hintText: "Passenger Name",
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          TextFormField(
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9.]')),
                                            ],
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Enter valid Km";
                                              } else {
                                                return null;
                                              }
                                            },
                                            controller:
                                                controller.odometerController,
                                            decoration: const InputDecoration(
                                              hintText: "Km in Odometer",
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          TextFormField(
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Enter valid destination";
                                              } else {
                                                return null;
                                              }
                                            },
                                            controller: controller
                                                .destinationController,
                                            decoration: const InputDecoration(
                                              hintText: "Destination",
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          TextFormField(
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Enter valid description";
                                              } else {
                                                return null;
                                              }
                                            },
                                            controller: controller
                                                .descriptionController,
                                            decoration: const InputDecoration(
                                              hintText: "Description",
                                            ),
                                            maxLines: 4,
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              FlutterBackgroundService()
                                                  .startService();
                                              if (formKey.currentState!
                                                  .validate()) {
                                                Get.back();
                                                await controller.createTrip();
                                              }
                                            },
                                            child: const Text(
                                              "Start Trip",
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                            controller.progress.value = false;
                          }
                        : () async {
                            controller
                                .getAddress(controller.currentPosition.value);
                            Get.defaultDialog(
                                title:
                                    "Stopping Trip at ${DateFormat.jm().format(DateTime.now())}",
                                content: Form(
                                  key: formKey,
                                  child: Column(
                                    children: [
                                      Text(
                                          "Current Location: ${controller.currentAddress.value}"),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      TextFormField(
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9.]')),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Enter valid Km";
                                          } else {
                                            return null;
                                          }
                                        },
                                        controller:
                                            controller.odometerController,
                                        decoration: const InputDecoration(
                                          hintText: "Km in Odometer",
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (formKey.currentState!
                                              .validate()) {
                                            await controller.endTrip();
                                            
                                          }
                                        },
                                        child: const Text(
                                          "Stop Trip",
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      )
                                    ],
                                  ),
                                ));
                          },
              ),
      ),
    );
  }
}
