import 'package:get/get.dart';
import 'package:safe_trade/screens/login/export.dart';
import 'package:safe_trade/screens/sign_up/sign_up_controller.dart';

import '../../screens/splash /export.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    ///Start Up
    Get.lazyPut<SplashController>(() => SplashController());

    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<SignUpController>(() => SignUpController());
  }
}
