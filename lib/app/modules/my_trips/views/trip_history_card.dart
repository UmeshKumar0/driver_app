import 'package:dummy_lat_long_app/app/models/my_trip_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TripHistoryCard extends StatelessWidget {
  TripHistoryCard({super.key, required this.myTrip});
  MyTripClass myTrip;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8),
      child: InkWell(
        onTap: () {
          Get.defaultDialog(
            title: "Trip Details",
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text("Description: ${myTrip.tripPurpose}"),
                  Text("Status: ${myTrip.status}"),
                  Text("Passenger: ${myTrip.passenger}"),
                  Text("Start Odometer: ${myTrip.startOdometer}"),
                  Text("End Odometer: ${myTrip.endOdometer}"),
                  Text("Trip Destination: ${myTrip.tripDestination}"),
                ],
              ),
            ),
          );
        },
        child: Container(
          height: 135,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            DateTime.fromMillisecondsSinceEpoch(
                                    myTrip.startTime ?? 0)
                                .toString()
                                .split(' ')[1]
                                .split('.')[0],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.date_range,
                            size: 20,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            myTrip.createdAt.toString().split('T')[0],
                            style: const TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 12,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 5),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 20,
                              color: Colors.green,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              myTrip.startGeolocation.toString(),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_history_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              myTrip.endGeolocation.toString(),
                              style: const TextStyle(
                                  // fontWeight: FontWeight.w100,
                                  fontSize: 10,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blueGrey[200],
                          child: const Icon(
                            Icons.no_crash_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          myTrip.vehicleId!.name.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          myTrip.vehicleId!.number.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
