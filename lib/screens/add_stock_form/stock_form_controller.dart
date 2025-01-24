import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:http/http.dart' as http;
import 'package:safe_trade/core/base/export.dart';
import 'package:safe_trade/screens/home/home_controller.dart';

import '../../utils/export.dart';

class StockFormController extends BaseController {
  final formKey = GlobalKey<FormState>();

  final buyDate = TextEditingController();
  final stockSymbol = TextEditingController();
  final buyPrice = TextEditingController();
  final numberOfShares = TextEditingController();
  final sellDate = TextEditingController();
  final sellPrice = TextEditingController();

  Rx<DateTime> date = DateTime.now().obs;

  RxBool isLoading = false.obs;

  ///sheet credentials
  final spreadsheetId = DriverConstants.stockFormSpreadsheetId;
  final range = DriverConstants.stockFormRange;

  @override
  void onInit() {
    super.onInit();
  }

  submitForm({context}) async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      final client = await DriverConstants.authenticate();
      final sheetsApi = SheetsApi(client);

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        range,
      );
      final rows = response.values ?? [];

      ///Add new user data
      final newRow = [
        getUserEmail(),
        buyDate.text,
        stockSymbol.text,
        buyPrice.text,
        numberOfShares.text,
        "",
        "-",
        sellDate.text.isEmpty ? "-" : sellDate.text,
        sellPrice.text.isEmpty ? "-" : sellPrice.text,
      ];
      await sheetsApi.spreadsheets.values.append(
        ValueRange(values: [newRow]),
        spreadsheetId,
        range,
        valueInputOption: 'RAW',
      );
      isLoading.value = false;
      client.close();
      update();

      // Get the HomeController instance and refresh the data
      final homeController = Get.find<HomeController>();
      await homeController.fetchSpreadsheetData();
      await homeController.fetchStockFormData();
      await homeController.updateCurrentStockPrices();
      homeController.startStockPriceUpdates();

      return true;
    } else {
      AppUtils.showFailureSnackBar(
        context: context,
        message: "Please fill all fields correctly",
      );
    }
  }

  Future<DateTime?> selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      return pickedDate;
    } else {
      return null;
    }
  }
}
