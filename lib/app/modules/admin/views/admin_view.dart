import 'package:dummy_lat_long_app/app/routes/app_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Screen'),
          centerTitle: true,
        ),
        body: Center(
          child: Obx(
            () => controller.isLoading.value
                ? const CircularProgressIndicator.adaptive()
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: DropdownButtonFormField(
                          hint: const Text("Select Vehicle"),
                          decoration:
                              const InputDecoration(label: Text("Vehicle")),
                          items: controller.data.map((element) {
                            return DropdownMenuItem(
                              value: element.sId.toString(),
                              child: Row(
                                children: [
                                  Text(element.name ?? " "),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(element.number ?? "")
                                ],
                              )
                              //
                              ,
                            );
                          }).toList(),
                          onChanged: (value) {
                            controller.vehicleId.value = value ?? "";
                            controller.vehicleName.value = controller
                                    .data[controller.data.indexWhere(
                                        (element) =>
                                            element.sId.toString() == value)]
                                    .name ??
                                "";
                          if(kDebugMode)  print(controller.vehicleName.value);
                          },
                        ),
                      ),
                      Expanded(child: Container()),
                      Obx(
                        () => ElevatedButton(
                            onPressed: controller.vehicleId.value.isEmpty
                                ? null
                                : () {
                                    controller.storage.write("vehicleId",
                                        controller.vehicleId.value);
                                    controller.storage.write("vehicleName",
                                        controller.vehicleName.value);
                                    Get.offAndToNamed(Routes.HOME_PAGE);
                                  },
                            child: const Text("Submit")),
                      ),
                      Expanded(
                        child: Container(),
                      )
                    ],
                  ),
          ),
        ));
  }
}
