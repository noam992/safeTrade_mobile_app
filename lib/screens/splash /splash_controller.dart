import 'dart:async';

import 'package:get/get.dart';
import 'package:safe_trade/core/base/export.dart';
import 'package:safe_trade/screens/home/home_view.dart';

import '../login/export.dart';

class SplashController extends BaseController {
  bool? get isLogin => getIsLogin();

  @override
  void onInit() {
    checkUserLogin();
    super.onInit();
  }

  checkUserLogin() {
    Timer(
      const Duration(seconds: 3),
      () {
        Future.delayed(Duration.zero, () {
          if (isLogin == true) {
            Get.offAll(
              () => const HomeView(),
              binding: AppBindings(),
              transition: Transition.circularReveal,
              duration: const Duration(milliseconds: 500),
            );
          } else {
            Get.offAll(
              () => const LoginView(),
              binding: AppBindings(),
              transition: Transition.circularReveal,
              duration: const Duration(milliseconds: 500),
            );
          }
        });
      },
    );
  }
}
