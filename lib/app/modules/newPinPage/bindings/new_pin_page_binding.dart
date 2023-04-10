import 'package:get/get.dart';

import '../controllers/new_pin_page_controller.dart';

class NewPinPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewPinPageController>(
      () => NewPinPageController(),
    );
  }
}
