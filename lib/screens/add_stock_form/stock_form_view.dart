import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_trade/screens/add_stock_form/export.dart';
import 'package:safe_trade/utils/app_colors.dart';
import 'package:safe_trade/utils/app_utils.dart';

import '../../widgets/export.dart';

class StockFormView extends GetView<StockFormController> {
  const StockFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StockFormController>(
      initState: (_) {
        Get.put(StockFormController());
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.whiteColor,
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            surfaceTintColor: AppColors.primaryColor,
            title: AppText(
              text: 'Add Investment Details',
              color: AppColors.whiteColor,
            ),
            iconTheme: IconThemeData(
              color: AppColors.whiteColor,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: controller.formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomFormField(
                      hint: 'Investment Date',
                      tec: controller.buyDate,
                      readOnly: true,
                      isLabel: true,
                      borderColor: AppColors.primaryColor,
                      errorBorderColor: AppColors.primaryColor,
                      validator: (value) => value!.isEmpty
                          ? 'Please enter investment date'
                          : null,
                      onFieldOnTap: () async {
                        DateTime? dateTime =
                            await controller.selectDate(context);
                        if (dateTime != null) {
                          controller.buyDate.text = dateTime.toString();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomFormField(
                      hint: 'Stock Symbol',
                      tec: controller.stockSymbol,
                      isLabel: true,
                      borderColor: AppColors.primaryColor,
                      errorBorderColor: AppColors.redColor,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter stock symbol' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomFormField(
                      hint: 'Number of Shares Purchased',
                      tec: controller.numberOfShares,
                      keyboardType: TextInputType.number,
                      isLabel: true,
                      borderColor: AppColors.primaryColor,
                      errorBorderColor: AppColors.redColor,
                      validator: (value) => value!.isEmpty
                          ? 'Please enter number of shares'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomFormField(
                      hint: 'Buy Price',
                      tec: controller.buyPrice,
                      isLabel: true,
                      keyboardType: TextInputType.number,
                      borderColor: AppColors.primaryColor,
                      errorBorderColor: AppColors.redColor,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter purchase price' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomFormField(
                      hint: 'Current Share Price',
                      tec: controller.currentSharePrice,
                      isLabel: true,
                      keyboardType: TextInputType.number,
                      borderColor: AppColors.primaryColor,
                      errorBorderColor: AppColors.redColor,
                      readOnly: true,
                      validator: (value) => value!.isEmpty
                          ? 'Please enter current share price'
                          : null,
                      suffixIcon: IconButton(
                        onPressed: () async {
                          if (controller.stockSymbol.text.isNotEmpty) {
                            await controller.fetchStockPrice(context: context);
                          } else {
                            AppUtils.showFailureSnackBar(
                              context: context,
                              message: "Please enter the stock symbol!",
                            );
                          }
                        },
                        icon: AppText(
                          text: "Get Price",
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomFormField(
                      hint: 'Sell Date',
                      tec: controller.sellDate,
                      isLabel: true,
                      keyboardType: TextInputType.number,
                      borderColor: AppColors.primaryColor,
                      errorBorderColor: AppColors.primaryColor,
                      readOnly: true,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter sell date' : null,
                      onFieldOnTap: () async {
                        DateTime? dateTime =
                            await controller.selectDate(context);
                        if (dateTime != null) {
                          controller.sellDate.text = dateTime.toString();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomFormField(
                      hint: 'Sell Price',
                      isLabel: true,
                      tec: controller.sellPrice,
                      keyboardType: TextInputType.number,
                      borderColor: AppColors.primaryColor,
                      errorBorderColor: AppColors.redColor,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter sell price' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomFormField(
                      hint: 'Profit Percentage',
                      isLabel: true,
                      tec: controller.profitPercentage,
                      keyboardType: TextInputType.number,
                      borderColor: AppColors.primaryColor,
                      errorBorderColor: AppColors.redColor,
                      validator: (value) => value!.isEmpty
                          ? 'Please enter profit percentage'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => CustomButton(
                        text: 'Add',
                        backgroundColor: AppColors.primaryColor,
                        fontColor: AppColors.whiteColor,
                        isGradient: true,
                        isLoading: controller.isLoading.value,
                        isEnable: !controller.isLoading.value,
                        onTap: () => controller.submitForm(context: context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
