import 'package:dummy_lat_long_app/app/modules/my_trips/views/trip_history_card.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/my_trips_controller.dart';

class MyTripsView extends GetView<MyTripsController> {
  const MyTripsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        centerTitle: true,
      ),
      body: Center(
        child: Obx(
          () {
            return controller.isLoading.value
                ? Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: controller.myTrips.length,
                      itemBuilder: (context, index) {
                        return TripHistoryCard(
                          myTrip: controller.myTrips[index],
                        );
                      },
                    ),
                  )
                : const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
