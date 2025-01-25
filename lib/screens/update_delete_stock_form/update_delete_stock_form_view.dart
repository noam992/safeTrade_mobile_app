import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_trade/utils/app_colors.dart';
import 'package:safe_trade/utils/app_utils.dart';
import '../../widgets/export.dart';
import 'update_delete_stock_form_controller.dart';

class UpdateDeleteStockFormView extends GetView<UpdateDeleteStockFormController> {
  final List<dynamic> stockData;
  final int rowIndex;

  const UpdateDeleteStockFormView({
    super.key,
    required this.stockData,
    required this.rowIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UpdateDeleteStockFormController>(
      initState: (_) {
        Get.put(UpdateDeleteStockFormController(stockData: stockData));
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.whiteColor,
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            surfaceTintColor: AppColors.primaryColor,
            title: AppText(
              text: 'Update Investment Details',
              color: AppColors.whiteColor,
            ),
            iconTheme: IconThemeData(
              color: AppColors.whiteColor,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: AppColors.whiteColor,
                ),
                onPressed: () => controller.deleteRecord(context, rowIndex),
              ),
            ],
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
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter investment date' : null,
                      onFieldOnTap: () async {
                        DateTime? dateTime = await controller.selectDate(context);
                        if (dateTime != null) {
                          controller.buyDate.text = AppUtils.formatDate(dateTime);
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
                      hint: 'Sell Date',
                      tec: controller.sellDate,
                      isLabel: true,
                      keyboardType: TextInputType.number,
                      borderColor: AppColors.primaryColor,
                      errorBorderColor: AppColors.redColor,
                      readOnly: true,
                      onFieldOnTap: () async {
                        DateTime? dateTime = await controller.selectDate(context);
                        if (dateTime != null) {
                          controller.sellDate.text = AppUtils.formatDate(dateTime);
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
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => CustomButton(
                        text: 'Update',
                        backgroundColor: AppColors.primaryColor,
                        fontColor: AppColors.whiteColor,
                        isGradient: true,
                        isLoading: controller.isLoading.value,
                        isEnable: !controller.isLoading.value,
                        onTap: () => controller.updateForm(
                          context: context,
                          rowIndex: rowIndex,
                        ),
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
