import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:safe_trade/core/base/export.dart';

import '../../utils/export.dart';
import '../login/export.dart';

class HomeController extends BaseController {
  List<List<dynamic>> spreadsheetData = [];
  List<List<dynamic>> stockFormData = [];
  RxBool isLoading = true.obs;

  Rx<DateTime> fromDate=DateTime.now().obs;
  Rx<DateTime> toDate=DateTime.now().add(const Duration(days: 1)).obs;

  @override
  void onInit() {
    fetchSpreadsheetData();
    fetchStockFormData();
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
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2100);

    // Show month/year picker
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Month and Year"),
          content: SizedBox(
            height: 300,
            width: 300,
            child: CalendarDatePicker(
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
              initialCalendarMode: DatePickerMode.year,
              onDateChanged: (DateTime date) {
                // Set the date to the first day of the selected month
                if (isFromDate) {
                  fromDate.value = DateTime(date.year, date.month, 1);
                } else {
                  toDate.value = DateTime(date.year, date.month, 1);
                }
                Get.back(); // Close the dialog
                update();
              },
            ),
          ),
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  String? getUserEmail() {
    return super.getUserEmail();
  }
}
