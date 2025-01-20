import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_trade/core/base/app_bindings.dart';
import 'package:safe_trade/screens/login/export.dart';

import '../../utils/export.dart';
import '../../widgets/export.dart';
import 'export.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignUpController>(
      initState: (_) {
        Get.put(SignUpController());
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppAssets.background),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      getLightOne(),
                      getLightTwo(),
                      getClock(),
                      Positioned(
                        child: FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: Container(
                              margin: const EdgeInsets.only(top: 50),
                              child: const Center(
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )),
                      )
                    ],
                  ),
                ),
                getLoginFields(context),
              ],
            ),
          ),
        );
      },
    );
  }

  getLightOne() {
    return Positioned(
      left: 30,
      width: 80,
      height: 200,
      child: FadeInUp(
        duration: const Duration(seconds: 1),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                AppAssets.light_1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  getLightTwo() {
    return Positioned(
      left: 140,
      width: 80,
      height: 150,
      child: FadeInUp(
        duration: const Duration(milliseconds: 1200),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                AppAssets.light_2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  getClock() {
    return Positioned(
      right: 40,
      top: 40,
      width: 80,
      height: 150,
      child: FadeInUp(
          duration: const Duration(milliseconds: 1300),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  AppAssets.clock,
                ),
              ),
            ),
          )),
    );
  }

  getLoginFields(context) {
    return Form(
      key: controller.formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: <Widget>[
            FadeInUp(
                duration: const Duration(milliseconds: 1800),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryColor),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(143, 148, 251, .2),
                        blurRadius: 20.0,
                        offset: Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      CustomFormField(
                        hint: "User Name",
                        tec: controller.userNameTEC,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter first name';
                          }
                          return null;
                        },
                      ),
                      Divider(color: AppColors.primaryColor),
                      CustomFormField(
                        hint: "Email",
                        tec: controller.emailTEC,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      Divider(color: AppColors.primaryColor),
                      CustomFormField(
                        hint: "Password",
                        tec: controller.passwordTEC,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 30),
            FadeInUp(
              duration: const Duration(milliseconds: 1900),
              child: Obx(
                () => CustomButton(
                  text: 'Sign Up',
                  backgroundColor: AppColors.primaryColor,
                  fontColor: AppColors.whiteColor,
                  isGradient: true,
                  isLoading: controller.isLoading.value,
                  isEnable: !controller.isLoading.value,
                  onTap: () async {
                    if (controller.formKey.currentState!.validate()) {
                      bool isRegister =
                          await controller.signUp(context: context);
                      if (isRegister) {
                        Get.offAll(
                          () => const LoginView(),
                          binding: AppBindings(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 500),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            FadeInUp(
              duration: const Duration(milliseconds: 2000),
              child: GestureDetector(
                onTap: () {
                  Get.offAll(
                    () => const LoginView(),
                    binding: AppBindings(),
                    transition: Transition.noTransition,
                    duration: const Duration(milliseconds: 500),
                  );
                },
                child: Text(
                  "Already have a account, Login?",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
