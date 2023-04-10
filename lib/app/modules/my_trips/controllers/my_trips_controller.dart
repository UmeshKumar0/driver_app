import 'package:dummy_lat_long_app/app/models/my_trip_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../network/api_service.dart';

class MyTripsController extends GetxController {
  final ApiService _apiService = ApiService();
// late PagingController<int, LeaveRequestModel> pagingController;
  GetStorage local = GetStorage();
  RxBool isLoading = false.obs;
  RxList<MyTripClass> myTrips = <MyTripClass>[].obs;
  @override
  void onInit() {
    // TODO: implement onInit
    getMyTrips();
    super.onInit();
  }

  getMyTrips() async {
    try {
      var driverId = local.read('driverId');
      if (kDebugMode) {
        print(driverId);
      }
      if (driverId != null) {
        var response = await _apiService.getCall('/mytrip?id=$driverId');
        // if (kDebugMode) {
        //   print(response.body);
        // }
        response.body.forEach((element) {
          // if (kDebugMode) {
          //   print(element);
          // }
          myTrips.add(MyTripClass.fromJson(element));
        });
        myTrips.refresh();
        isLoading.value = true;
      } else {
        if (kDebugMode) {
          print('driverId is null');
        }
        isLoading.value = true;
      }
    } catch (e) {
      isLoading.value = true;
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
