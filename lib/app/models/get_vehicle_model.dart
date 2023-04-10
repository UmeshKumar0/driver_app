class GetVehicleModel {
  String? sId;
  String? name;
  String? number;
  String? type;
  String? createdAt;
  String? updatedAt;
  int? iV;

  GetVehicleModel(
      {this.sId,
      this.name,
      this.number,
      this.type,
      this.createdAt,
      this.updatedAt,
      this.iV});

  GetVehicleModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    number = json['number'];
    type = json['type'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['number'] = number;
    data['type'] = type;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
