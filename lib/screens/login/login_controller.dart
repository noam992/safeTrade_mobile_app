import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:safe_trade/core/base/export.dart';
import 'dart:async';

import '../../utils/export.dart';

class LoginController extends BaseController {
  final loginFormKey = GlobalKey<FormState>();

  ///
  final emailTEC = TextEditingController();
  final passwordTEC = TextEditingController();

  RxBool isLoading = false.obs;

  ///sheet credentials
  final spreadsheetId = DriverConstants.userSpreadsheetId;
  final range = DriverConstants.userSheetRange;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  Future<bool> loginUser({context}) async {
    try {
      isLoading.value = true;
      update();
      
      final client = await DriverConstants.authenticate().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Authentication timed out');
        },
      );

      final sheetsApi = SheetsApi(client);

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        range,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Spreadsheet request timed out');
        },
      );

      final rows = response.values ?? [];

      /// Check if email and password match any row
      for (var row in rows) {
        if (row.length >= 3 && row[1] == emailTEC.text && row[2] == passwordTEC.text) {
          client.close();
          isLoading.value = false;
          update();
          return true;
        }
      }
      
      client.close();
      isLoading.value = false;
      update();
      return false;
      
    } catch (e) {
      print('Login error: $e'); // For debugging
      isLoading.value = false;
      update();
      
      if (context != null) {
        AppUtils.showFailureSnackBar(
          context: context,
          message: "Connection error. Please check your internet connection and credentials.",
        );
      }
      return false;
    }
  }

  @override
  void dispose() {
    emailTEC.dispose();
    passwordTEC.dispose();
    super.dispose();
  }
}
