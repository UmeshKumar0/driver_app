import 'package:dummy_lat_long_app/app/network/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class NewPinPageController extends GetxController {

 final ApiService _apiService = ApiService();

  TextEditingController phoneController = TextEditingController();

  sendOtp() async {
    var response = await _apiService
        .postCall("/user/regenrate/pin?phone=${phoneController.text}", {});

    if (!response.status.hasError) {
      if (response.body["message"] != null) {
       if(kDebugMode) print(response.body["message"]);
        Fluttertoast.showToast(msg: response.body["message"]);
        FocusManager.instance.primaryFocus?.unfocus();
        phoneController.clear();
      }
    } else {
      if (response.body["message"] != null) {
        Get.snackbar("Error", response.body["message"]);
      } else {
        Get.snackbar("Error", response.statusText.toString());
      }
    }
  }
}
