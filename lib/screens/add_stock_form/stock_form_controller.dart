import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:http/http.dart' as http;
import 'package:safe_trade/core/base/export.dart';

import '../../utils/export.dart';

class StockFormController extends BaseController {
  final formKey = GlobalKey<FormState>();

  final buyDate = TextEditingController();
  final stockSymbol = TextEditingController();
  final buyPrice = TextEditingController();
  final numberOfShares = TextEditingController();
  final currentSharePrice = TextEditingController();
  final sellDate = TextEditingController();
  final sellPrice = TextEditingController();
  final profitPercentage = TextEditingController();

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
        currentSharePrice.text.isEmpty ? "-" : currentSharePrice.text,
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

  fetchStockPrice({context}) async {
    AppUtils.showLoading(context);
    final url = Uri.parse(
        'https://alpha-vantage.p.rapidapi.com/query?function=GLOBAL_QUOTE&symbol=${stockSymbol.text}&datatype=json');
    final response = await http.get(
      url,
      headers: {
        "x-rapidapi-key": "016364ab47msh5cbdc1eca1d2fd9p1a99aajsnffc0409877c7",
        "x-rapidapi-host": "alpha-vantage.p.rapidapi.com",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      currentSharePrice.text = data['Global Quote']["02. open"];
    } else {
      throw Exception('Failed to load stock price');
    }
    AppUtils.dismissLoading(context);
  }
}
