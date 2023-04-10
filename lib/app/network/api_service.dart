import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ApiService extends GetConnect {
  final String APIbaseUrl =
      // localBool
      //     ? 'http://172.30.1.97:7002/vehicle'
      //     :
      //:
      //2 API's, one in main.dart and second one is  expense post which is using form data so i have implemented it individually

      // kDebugMode
      //     ? "http://172.30.1.97:7002/vehicle"
      //     :
           "https://vehicle-backend.spideyworld.co.in/vehicle";

  final String APIbaseUrl2 = "http://172.30.1.97:7002";
  final local = GetStorage();

  Future<Response> getCall(String url, {String? adminPin}) async =>
      await get('$APIbaseUrl$url',
          headers: adminPin != null
              ? {"token": adminPin}
              : {"token": "${local.read("token")}"});

  Future<Response> postCall(
    String url,
    Map<String, dynamic> data,
  ) async =>
      await post('$APIbaseUrl$url', data,
          headers: {"token": "${local.read("token")}"});

  Future<Response> patchCall(
    String url,
    Map<String, dynamic> data,
  ) async =>
      await patch('$APIbaseUrl$url', data,
          headers: {"token": "${local.read("token")}"});
}
