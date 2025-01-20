import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_trade/core/base/export.dart';
import 'package:safe_trade/core/service/cache_manager.dart';
import 'package:safe_trade/screens/add_stock_form/export.dart';
import 'package:safe_trade/utils/app_colors.dart';

import '../../widgets/export.dart';
import 'export.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      initState: (_) {
        Get.put(HomeController());
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.whiteColor,
          appBar: getAppBar(context: context),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.to(
                () => const StockFormView(),
                binding: AppBindings(),
                transition: Transition.downToUp,
                duration: const Duration(milliseconds: 500),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              const SizedBox(height: 16),
              getDateFilter(context: context),
              const SizedBox(height: 16),
              controller.isLoading.isTrue
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : controller.spreadsheetData.isNotEmpty
                      ? Expanded(
                        child: ListView.builder(
                            itemCount: controller.spreadsheetData.length,
                            itemBuilder: (context, index) {
                              return recordItems(context, index);
                            },
                          ),
                      )
                      : const Center(
                          child: Text('No data found'),
                        ),
            ],
          ),
        );
      },
    );
  }

  AppBar getAppBar({context}) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      surfaceTintColor: AppColors.primaryColor,
      title: AppText(
        text: 'Safe Trade',
        color: AppColors.whiteColor,
      ),
      iconTheme: IconThemeData(
        color: AppColors.whiteColor,
      ),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: () {
            onLogout(context);
          },
          child: AppText(
            text: "Logout",
            color: AppColors.whiteColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  getDateFilter({context}) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: CustomButton(
              text:'From: ${controller.fromDate.value.toLocal()}'.split(' ')[0],
              backgroundColor: AppColors.primaryColor,
              fontColor: AppColors.whiteColor,
              isGradient: true,
              onTap: () => controller.selectDate(context, true),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'To: ${controller.toDate.value.toLocal()}'.split(' ')[0],
              backgroundColor: AppColors.primaryColor,
              fontColor: AppColors.whiteColor,
              isGradient: true,
              onTap: () => controller.selectDate(context, false),
            ),
          ),
        ],
      ),
    );
  }

  recordItems(BuildContext context, int index) {
    final row = controller.spreadsheetData[index];
    return index == 0 ? const SizedBox.shrink() : GestureDetector(
      onTap: () {
        controller.fetchAndDisplayImage(context, row[1].toString());
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 04, horizontal: 08),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyColor.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Stock Data :'),
                Text(row[1].toString()),
              ],
            ),
            Row(
              children: [
                const Text('Date :'),
                Text(row[0].toString()),
              ],
            ),
            Row(
              children: [
                const Text('Price :'),
                Text(row[10].toString()),
              ],
            ),
            Row(
              children: [
                const Text('Support :'),
                Text(formatToTwoDecimalPlaces(row[12].toString())),
              ],
            ),
            Row(
              children: [
                const Text('Resistance :'),
                Text(formatToTwoDecimalPlaces(row[13].toString())),
              ],
            ),
            Row(
              children: [
                const Text('Channel_Range :'),
                Text(formatToTwoDecimalPlaces(row[14].toString())),
              ],
            ),
            Row(
              children: [
                const Text('Ratio_Channel :'),
                Text(covertToPercentage(row[15].toString())),
              ],
            ),
            Row(
              children: [
                const Text('Ratio_Support :'),
                Text(covertToPercentage(row[16].toString())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  onLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0.5,
          surfaceTintColor: Colors.white,
          title: const Text(
            "Log out?",
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Card(
                        elevation: 0.5,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(35),
                          ),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.065,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              // border: Border.all(color: Colors.grey.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(35),
                              border: Border.all(
                                color: AppColors.primaryColor,
                              )),
                          child: const AppText(
                            text: 'Cancel',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      controller.logoutUser(context: context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Card(
                        elevation: 0.5,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(35),
                          ),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.065,
                          decoration: BoxDecoration(
                              color: AppColors.redColor,
                              // border: Border.all(color: Colors.grey.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(35),
                              border: Border.all(
                                color: AppColors.blackColor,
                              )),
                          child: AppText(
                            text: 'Log Out',
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String covertToPercentage(String percentage) {
    // Parse the string to a double
    double? value = double.tryParse(percentage);

    // Check if parsing was successful
    if (value == null) {
      return "";
    }

    // Multiply by 100 and format to two decimal places
    double percentageValue = value * 100;

    // Return the formatted percentage with the % sign
    return "${percentageValue.toStringAsFixed(2)}%";
  }

  String formatToTwoDecimalPlaces(String value) {
    // Parse the string to a double
    double? number = double.tryParse(value);

    // Check if parsing was successful
    if (number == null) {
      return "";
    }

    // Format to two decimal places
    return number.toStringAsFixed(2);
  }
}
