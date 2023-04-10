import 'package:get/get.dart';

import '../modules/HomePage/bindings/home_page_binding.dart';
import '../modules/HomePage/views/home_page_view.dart';
import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_view.dart';
import '../modules/expenses/bindings/expenses_binding.dart';
import '../modules/expenses/views/expenses_view.dart';
import '../modules/my_trips/bindings/my_trips_binding.dart';
import '../modules/my_trips/views/my_trips_view.dart';
import '../modules/newPinPage/bindings/new_pin_page_binding.dart';
import '../modules/newPinPage/views/new_pin_page_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME_PAGE;

  static final routes = [
    GetPage(
      name: _Paths.HOME_PAGE,
      page: () => const HomePageView(),
      binding: HomePageBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN,
      page: () => const AdminView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: _Paths.NEW_PIN_PAGE,
      page: () => NewPinPageView(),
      binding: NewPinPageBinding(),
    ),
    GetPage(
      name: _Paths.EXPENSES,
      page: () => const ExpensesView(),
      binding: ExpensesBinding(),
    ),
    GetPage(
      name: _Paths.MY_TRIPS,
      page: () => const MyTripsView(),
      binding: MyTripsBinding(),
    ),
  ];
}
