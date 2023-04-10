import 'dart:convert';
import 'dart:io';

import 'package:dummy_lat_long_app/app/models/get_expense_model.dart';
import 'package:dummy_lat_long_app/app/network/api_service.dart';
import 'package:dummy_lat_long_app/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ExpensesController extends GetxController {
  final ApiService _apiService = ApiService();
  @override
  void onInit() {
    getExpenses();
    super.onInit();
  }

  RxList<ExpenseData> expenses = <ExpenseData>[].obs;
  int amount = 0;
  TextEditingController description = TextEditingController();
  GetStorage store = GetStorage();
  RxString img64 = ''.obs;
  RxString imageName = ''.obs;
  RxString imagePath = ''.obs;
  RxBool isLoading = false.obs;

  getExpenses() async {
    expenses.clear();
    isLoading(false);
    var driverId = store.read("driverId");

    var response = await _apiService.getCall("/expense?id=$driverId");
    if (kDebugMode) {
      print(response.request?.url);
    }
//
    if (response.status.hasError) {
      Fluttertoast.showToast(msg: response.statusText.toString());
      return;
    } else {
      response.body["data"].forEach((element) {
        expenses.add(ExpenseData.fromJson(element));
      });
      refresh();
      expenses.refresh();
    }
    isLoading(true);
  }

  pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path ?? '');
      imagePath.value = file.path;
      imageName.value = file.path.split('/').last;
      final bytes = file.readAsBytesSync();
      img64.value = base64Encode(bytes);
    } else {
      Fluttertoast.showToast(msg: "Please Select Image");
    }
  }

  addExpense() async {
    var driverId = store.read("driverId");
    var tripId = store.read("tripId");

    if (img64.value == '' || description.text.isEmpty || amount == 0) {
      Fluttertoast.showToast(msg: "Please fill all the fields");
      return;
    }
// used http for FORM data
    final uri = Uri.parse('${ApiService().APIbaseUrl}/expense');
    if (kDebugMode) {
      print(uri);
    }
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({"token": local.read("token")});
    request.fields['driver'] = driverId;
    request.fields['amount'] = amount.toString();
    request.fields['description'] = description.text;
    if (tripId != null) {
      request.fields['trip'] = tripId;
    }

    request.fields['date'] = DateTime.now().millisecondsSinceEpoch.toString();
    final httpImage = await http.MultipartFile.fromPath(
        'image', imagePath.value,
        contentType: MediaType('image', '${imageName.value.split('.').last}}'));
    request.files.add(httpImage);
    final response = await request.send();

    if (response.statusCode.toString().startsWith("2")) {
      Fluttertoast.showToast(msg: "Expense Added");
      Get.back();
    } else {
      Fluttertoast.showToast(msg: response.reasonPhrase.toString());
    }
  }
}
