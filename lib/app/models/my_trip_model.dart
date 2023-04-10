class MyTripClass {
  StartLocation? startLocation;
  EndLocation? endLocation;
  String? sId;
  VehicleId? vehicleId;
  String? driverId;
  String? startGeolocation;
  String? passenger;
  int? startOdometer;
  String? tripDestination;
  String? tripPurpose;
  int? startTime;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? endGeolocation;
  int? endOdometer;
  int? endTime;

  MyTripClass(
      {this.startLocation,
      this.endLocation,
      this.sId,
      this.vehicleId,
      this.driverId,
      this.startGeolocation,
      this.passenger,
      this.startOdometer,
      this.tripDestination,
      this.tripPurpose,
      this.startTime,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.endGeolocation,
      this.endOdometer,
      this.endTime});

  MyTripClass.fromJson(Map<String, dynamic> json) {
    startLocation = json['startLocation'] != null
        ? StartLocation.fromJson(json['startLocation'])
        : null;
    endLocation = json['endLocation'] != null
        ? EndLocation.fromJson(json['endLocation'])
        : null;
    sId = json['_id'];
    vehicleId = json['vehicle_id'] != null
        ? VehicleId.fromJson(json['vehicle_id'])
        : null;
    driverId = json['driver_id'];
    startGeolocation = json['startGeolocation'];
    passenger = json['passenger'];
    startOdometer = json['startOdometer'].runtimeType == int
        ? json['startOdometer']
        : int.parse(json['startOdometer']);
    tripDestination = json['tripDestination'];
    tripPurpose = json['tripPurpose'];
    startTime = json['startTime'].runtimeType == int
        ? json['startTime']
        : int.parse(json['startTime']);
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'].runtimeType == int ? json['__v'] : int.parse(json['__v']);
    endGeolocation = json['endGeolocation'];
    endOdometer = json['endOdometer'] == null
        ? -1
        : json['endOdometer'].runtimeType == int
            ? json['endOdometer']
            : int.parse(json['endOdometer']);
    endTime = 
    json['endTime'] == null
        ? -1
        :
     json['endTime'].runtimeType == int
        ? json['endTime']
        : int.parse(json['endTime']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (startLocation != null) {
      data['startLocation'] = startLocation!.toJson();
    }
    if (endLocation != null) {
      data['endLocation'] = endLocation!.toJson();
    }
    data['_id'] = sId;
    if (vehicleId != null) {
      data['vehicle_id'] = vehicleId!.toJson();
    }
    data['driver_id'] = driverId;
    data['startGeolocation'] = startGeolocation;
    data['passenger'] = passenger;
    data['startOdometer'] = startOdometer;
    data['tripDestination'] = tripDestination;
    data['tripPurpose'] = tripPurpose;
    data['startTime'] = startTime;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['endGeolocation'] = endGeolocation;
    data['endOdometer'] = endOdometer;
    data['endTime'] = endTime;
    return data;
  }
}

class StartLocation {
  double? latitude;
  double? longitude;

  StartLocation({this.latitude, this.longitude});

  StartLocation.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'].runtimeType == int
        ? json['latitude'].toDouble()
        : json['latitude'];
    longitude = json['longitude'].runtimeType == int
        ? json['longitude'].toDouble()
        : json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class EndLocation {
  double? latitude;

  EndLocation({this.latitude});

  EndLocation.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'].runtimeType == int
        ? json['latitude'].toDouble()
        : json['latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    return data;
  }
}

class VehicleId {
  String? sId;
  String? name;
  String? number;
  String? type;
  bool? selected;
  String? createdAt;
  String? updatedAt;
  int? iV;

  VehicleId(
      {this.sId,
      this.name,
      this.number,
      this.type,
      this.selected,
      this.createdAt,
      this.updatedAt,
      this.iV});

  VehicleId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    number = json['number'];
    type = json['type'];
    selected = json['selected'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'].runtimeType == int ? json['__v'] : int.parse(json['__v']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['number'] = number;
    data['type'] = type;
    data['selected'] = selected;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
