import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:safe_trade/core/base/export.dart';
import 'package:http/http.dart' as http;
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

import '../../utils/export.dart';
import '../login/export.dart';

class HomeController extends BaseController {
  List<List<dynamic>> spreadsheetData = [];
  List<List<dynamic>> stockFormData = [];
  RxBool isLoading = true.obs;

  Rx<DateTime> fromDate=DateTime.now().obs;
  Rx<DateTime> toDate=DateTime.now().add(const Duration(days: 1)).obs;

  Timer? stockUpdateTimer;
  final Map<String, double> currentStockPrices = <String, double>{}.obs;

  @override
  void onInit() {
    fetchSpreadsheetData();
    fetchStockFormData();
    startStockPriceUpdates();
    super.onInit();
  }

  ///get spread sheet data
  fetchSpreadsheetData() async {
    try {
      final client = await DriverConstants.authenticate();
      final sheetsApi = sheets.SheetsApi(client);

      final response = await sheetsApi.spreadsheets.values.get(
        DriverConstants.stockListSpreadsheetId,
        DriverConstants.stockListRange,
      );

      if (response.values != null) {
        spreadsheetData = response.values!;
        isLoading.value = false;
        update();
      } else {
        spreadsheetData = [];
        isLoading.value = false;
        update();
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      isLoading.value = false;
      update();
    }
  }

  fetchStockFormData() async {
    try {
      final client = await DriverConstants.authenticate();
      final sheetsApi = sheets.SheetsApi(client);

      final response = await sheetsApi.spreadsheets.values.get(
        DriverConstants.stockFormSpreadsheetId,
        DriverConstants.stockFormRange,
      );

      if (response.values != null) {
        stockFormData = response.values!;
        debugPrint("Stock Form Data: $stockFormData");
        update();
      } else {
        debugPrint("No data received from spreadsheet");
      }
    } catch (e) {
      debugPrint("Error fetching stock form data: $e");
    }
  }

  ///get image by click
  fetchAndDisplayImage(
    BuildContext context,
    String imageName,
  ) async {
    AppUtils.showLoading(context, loadingText: "Getting image...");
    String? imageUrl = await getDirectImageUrl(context, imageName);
    if (context.mounted) {
      AppUtils.dismissLoading(context);
      if (imageUrl != null) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Image.network(imageUrl),
          ),
        );
      } else {
        AppUtils.showFailureSnackBar(
          context: context,
          message: "Failed to fetch image URL.",
        );
      }
    }
  }

  Future<String?> getDirectImageUrl(
    BuildContext context,
    String imageName,
  ) async {
    try {
      final clientCredentials = ServiceAccountCredentials.fromJson(
        await rootBundle.loadString(AppAssets.credentials),
      );

      final client = await clientViaServiceAccount(
        clientCredentials,
        [drive.DriveApi.driveScope],
      );
      final driveApi = drive.DriveApi(client);

      final fileList = await driveApi.files.list(
        q: "'${DriverConstants.imageFolderId}' in parents and name = '${imageName}_chart.png'",
        $fields: "files(id, name)",
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final fileId = fileList.files!.first.id;
        if (fileId != null) {
          await driveApi.permissions.create(
            drive.Permission(role: 'reader', type: 'anyone'),
            fileId,
          );
          return "https://drive.google.com/uc?id=$fileId";
        }
      } else {
        if (context.mounted) {
          AppUtils.showFailureSnackBar(
            context: context,
            message: "Image not found: ${imageName}_chart",
          );
        }
        return null;
      }
    } catch (e) {
      if (context.mounted) {
        AppUtils.showFailureSnackBar(
          context: context,
          message: "Error fetching image URL: $e",
        );
      }
      return null;
    }
    return null;
  }

  ///date filters
  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    DateTime initialDate = isFromDate ? fromDate.value : toDate.value;
    int selectedYear = initialDate.year;
    int selectedMonth = initialDate.month;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Select Month and Year"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Year Dropdown
                  DropdownButton<int>(
                    value: selectedYear,
                    items: List.generate(51, (index) => 2000 + index)
                        .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            ))
                        .toList(),
                    onChanged: (year) {
                      if (year != null) {
                        setState(() => selectedYear = year);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  // Month Dropdown
                  DropdownButton<int>(
                    value: selectedMonth,
                    items: List.generate(12, (index) => index + 1)
                        .map((month) => DropdownMenuItem(
                              value: month,
                              child: Text(
                                DateTime(2022, month).toString().split(' ')[0].split('-')[1],
                              ),
                            ))
                        .toList(),
                    onChanged: (month) {
                      if (month != null) {
                        setState(() => selectedMonth = month);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (isFromDate) {
                      fromDate.value = DateTime(selectedYear, selectedMonth, 1);
                    } else {
                      toDate.value = DateTime(selectedYear, selectedMonth, 1);
                    }
                    update();
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void logoutUser({required context}) {
    removeAllData();
    Get.offAll(
          () => const LoginView(),
      binding: AppBindings(),
      transition: Transition.noTransition,
      duration: const Duration(milliseconds: 500),
    );
  }

  void startStockPriceUpdates() {
    stockUpdateTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      updateCurrentStockPrices();
    });
    updateCurrentStockPrices();
  }

  Future<void> updateCurrentStockPrices() async {
    try {
      final symbols = stockFormData
          .where((row) => row[0].toString() == getUserEmail())
          .map((row) => row[2].toString())
          .toSet();

      for (String symbol in symbols) {
        try {
          // Get current stock price using yahoo_finance_data_reader
          YahooFinanceResponse response = await YahooFinanceDailyReader().getDailyDTOs(symbol);
          
          if (response.candlesData.isNotEmpty) {
            // Get the most recent candle data (current price)
            YahooFinanceCandleData latestCandle = response.candlesData.last;
            currentStockPrices[symbol] = latestCandle.close;
            debugPrint('Updated price for $symbol: ${latestCandle.close}');
          }
        } catch (e) {
          debugPrint('Error fetching price for symbol $symbol: $e');
        }
      }
      update();
    } catch (e) {
      debugPrint('Error updating stock prices: $e');
    }
  }

  @override
  void dispose() {
    stockUpdateTimer?.cancel();
    super.dispose();
  }

  String? getUserEmail() {
    return super.getUserEmail();
  }
}
