class GetExpenseData {
  List<ExpenseData>? data;
  int? count;

  GetExpenseData({this.data, this.count});

  GetExpenseData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ExpenseData>[];
      json['data'].forEach((v) {
        data!.add(ExpenseData.fromJson(v));
      });
    }
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['count'] = count;
    return data;
  }
}

class ExpenseData {
  String? sId;
  Driver? driver;
  int? amount;
  String? description;
  int? date;
  String? approved;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? image;

  ExpenseData(
      {this.sId,
      this.driver,
      this.amount,
      this.description,
      this.date,
      this.approved,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.image});

  ExpenseData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    driver = json['driver'] != null ? Driver.fromJson(json['driver']) : null;
    amount = json['amount'];
    description = json['description'];
    date = json['date'];
    approved = json['approved'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (driver != null) {
      data['driver'] = driver!.toJson();
    }
    data['amount'] = amount;
    data['description'] = description;
    data['date'] = date;
    data['approved'] = approved;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['image'] = image;
    return data;
  }
}

class Driver {
  String? sId;
  String? name;
  String? email;
  String? phone;

  Driver({this.sId, this.name, this.email, this.phone});

  Driver.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    return data;
  }
}
