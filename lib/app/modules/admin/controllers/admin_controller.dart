import 'package:dummy_lat_long_app/app/models/get_vehicle_model.dart';
import 'package:dummy_lat_long_app/app/network/api_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AdminController extends GetxController {
  RxList<GetVehicleModel> data = <GetVehicleModel>[].obs;
  GetStorage storage = GetStorage();
  RxBool isLoading = true.obs;
  RxString vehicleId = "".obs;
  RxString vehicleName = "".obs;
  ApiService apiService = ApiService();
  var pin = Get.arguments;
 
  @override
  void onInit() {
    storage.initStorage;
    getVehicle();
    
    super.onInit();
  }

  getVehicle() async {
    isLoading(true);
    var response = await apiService.getCall("/get?type=all", adminPin: "$pin");

    if (!response.status.hasError) {
      if (response.body.length > 0) {
        response.body.forEach((e) {
          data.add(GetVehicleModel.fromJson(e));
        });
      }
    } else {
      Get.snackbar("Error", response.body.toString());
    }
    isLoading(false);
  }
}
