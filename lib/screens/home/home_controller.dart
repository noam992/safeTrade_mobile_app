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
  RxBool isLoading = true.obs;

  Rx<DateTime> fromDate=DateTime.now().obs;
  Rx<DateTime> toDate=DateTime.now().add(const Duration(days: 1)).obs;

  @override
  void onInit() {
    fetchSpreadsheetData();
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

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      if (isFromDate) {
        fromDate.value = pickedDate;
      } else {
        toDate.value = pickedDate;
      }
      update();
    }
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
}
