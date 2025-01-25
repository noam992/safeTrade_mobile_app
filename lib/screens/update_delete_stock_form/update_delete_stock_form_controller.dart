import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:safe_trade/core/base/export.dart';
import 'package:safe_trade/screens/home/home_controller.dart';
import '../../utils/export.dart';

class UpdateDeleteStockFormController extends BaseController {
  final List<dynamic> stockData;
  
  UpdateDeleteStockFormController({required this.stockData}) {
    _initializeControllers();
  }

  final formKey = GlobalKey<FormState>();

  final buyDate = TextEditingController();
  final stockSymbol = TextEditingController();
  final buyPrice = TextEditingController();
  final numberOfShares = TextEditingController();
  final sellDate = TextEditingController();
  final sellPrice = TextEditingController();

  Rx<DateTime> date = DateTime.now().obs;
  RxBool isLoading = false.obs;

  final spreadsheetId = DriverConstants.stockFormSpreadsheetId;
  final range = DriverConstants.stockFormRange;

  void _initializeControllers() {
    buyDate.text = stockData[1].toString();
    stockSymbol.text = stockData[2].toString();
    buyPrice.text = stockData[3].toString();
    numberOfShares.text = stockData[4].toString();
    if (stockData.length > 5) {
      sellDate.text = stockData[5].toString() == '-' ? '' : stockData[5].toString();
    }
    if (stockData.length > 6) {
      sellPrice.text = stockData[6].toString() == '-' ? '' : stockData[6].toString();
    }
  }

  Future<void> updateForm({required BuildContext context, required int rowIndex}) async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading.value = true;
        final client = await DriverConstants.authenticate();
        final sheetsApi = SheetsApi(client);

        // First, get all existing data to find the correct row
        final response = await sheetsApi.spreadsheets.values.get(
          spreadsheetId,
          range,
        );
        final rows = response.values ?? [];

        // Find the actual row index in the sheet
        int actualRowIndex = 1; // Start from 1 to account for header
        bool found = false;
        
        for (int i = 0; i < rows.length; i++) {
          if (i == 0) continue; // Skip header row
          
          final row = rows[i];
          if (row.isEmpty) continue;
          
          if (row[0].toString() == getUserEmail()) {
            if (rowIndex == 0) {
              actualRowIndex = i + 1; // Add 1 because sheet rows are 1-based
              found = true;
              break;
            }
            rowIndex--;
          }
        }

        if (!found) {
          throw Exception('Row not found');
        }

        // Prepare the updated row data
        final updatedRow = [
          getUserEmail(),
          buyDate.text,
          stockSymbol.text,
          buyPrice.text,
          numberOfShares.text,
          sellDate.text.isEmpty ? "-" : sellDate.text,
          sellPrice.text.isEmpty ? "-" : sellPrice.text,
        ];

        // Update the range to match the number of columns
        final updateRange = "${DriverConstants.stockFormRange.split('!')[0]}!A$actualRowIndex:G$actualRowIndex";
        
        await sheetsApi.spreadsheets.values.update(
          ValueRange(values: [updatedRow]),
          spreadsheetId,
          updateRange,
          valueInputOption: 'USER_ENTERED',
        );

        client.close();
        isLoading.value = false;

        // Refresh home screen data
        await _refreshHomeData();

        // Show success message and navigate back
        AppUtils.showSuccessSnackBar(
          context: context,
          message: "Record updated successfully",
        );
        Get.back();
      } catch (e) {
        debugPrint("Update error: $e"); // Add error logging
        isLoading.value = false;
        AppUtils.showFailureSnackBar(
          context: context,
          message: "Failed to update record",
        );
      }
    }
  }

  Future<void> deleteRecord(BuildContext context, int rowIndex) async {
    try {
      // Show confirmation dialog
      bool? confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this record?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text(
                'Delete',
                style: TextStyle(color: AppColors.redColor),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      isLoading.value = true;
      final client = await DriverConstants.authenticate();
      final sheetsApi = SheetsApi(client);

      // First, get all existing data to find the correct row
      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        range,
      );
      final rows = response.values ?? [];

      // Find the actual row index in the sheet
      int actualRowIndex = 1; // Start from 1 to account for header
      bool found = false;
      
      for (int i = 0; i < rows.length; i++) {
        if (i == 0) continue; // Skip header row
        
        final row = rows[i];
        if (row.isEmpty) continue;
        
        if (row[0].toString() == getUserEmail()) {
          if (rowIndex == 0) {
            actualRowIndex = i + 1; // Add 1 because sheet rows are 1-based
            found = true;
            break;
          }
          rowIndex--;
        }
      }

      if (!found) {
        throw Exception('Row not found');
      }

      // Update the clear range to only include columns A through F
      final clearRange = "${DriverConstants.stockFormRange.split('!')[0]}!A$actualRowIndex:G$actualRowIndex";
      await sheetsApi.spreadsheets.values.clear(
        ClearValuesRequest(),
        spreadsheetId,
        clearRange,
      );

      client.close();
      isLoading.value = false;

      // Refresh home screen data
      await _refreshHomeData();

      // Show success message and navigate back
      AppUtils.showSuccessSnackBar(
        context: context,
        message: "Record deleted successfully",
      );
      Get.back();
    } catch (e) {
      debugPrint("Delete error: $e"); // Add error logging
      isLoading.value = false;
      AppUtils.showFailureSnackBar(
        context: context,
        message: "Failed to delete record",
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
    }
    return null;
  }

  Future<void> _refreshHomeData() async {
    final homeController = Get.find<HomeController>();
    await homeController.fetchSpreadsheetData();
    await homeController.fetchStockFormData();
    await homeController.updateCurrentStockPrices();
    homeController.startStockPriceUpdates();
  }

  @override
  void onClose() {
    buyDate.dispose();
    stockSymbol.dispose();
    buyPrice.dispose();
    numberOfShares.dispose();
    sellDate.dispose();
    sellPrice.dispose();
    super.onClose();
  }
}
