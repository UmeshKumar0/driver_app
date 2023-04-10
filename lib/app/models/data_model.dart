import 'package:hive/hive.dart';
part 'data_model.g.dart';

@HiveType(typeId: 0)
class DataModel {
  @HiveField(0)
  late double? lat;
  @HiveField(1)
  late double? long;
  @HiveField(2)
  late String? driverId;
  @HiveField(3)
  late String? vehicleId;
  @HiveField(4)
  late int? currentTime;
  @HiveField(5)
  late String? tripId;

  DataModel({
    this.lat,
    this.long,
    this.driverId,
    this.vehicleId,
    this.currentTime,
    this.tripId,
  });
  Map<String, dynamic> toJson() => {
        "vehicle_id": vehicleId,
        "driver_id": driverId,
        "time": currentTime,
        "location": {
          "latitute": lat,
          "longitude": long,
        },
        "trip_id": tripId,
      };
}
