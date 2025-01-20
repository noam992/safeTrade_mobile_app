import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:safe_trade/core/base/export.dart';
import 'dart:async';

import '../../utils/export.dart';

class SignUpController extends BaseController {
  final formKey = GlobalKey<FormState>();

  ///edt controllers
  final userNameTEC = TextEditingController();
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

  Future<bool> signUp({context}) async {
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

      // Check if email already exists
      for (var row in rows) {
        if (row.length >= 2 && row[1] == emailTEC.text) {
          client.close();
          isLoading.value = false;
          update();
          if (context != null) {
            AppUtils.showFailureSnackBar(
              context: context,
              message: "User already exists!",
            );
          }
          return false;
        }
      }

      // Add new user data
      final newRow = [
        userNameTEC.text,
        emailTEC.text,
        passwordTEC.text,
      ];

      await sheetsApi.spreadsheets.values.append(
        ValueRange(values: [newRow]),
        spreadsheetId,
        range,
        valueInputOption: 'RAW',
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Adding user data timed out');
        },
      );

      client.close();
      isLoading.value = false;
      update();
      return true;

    } catch (e) {
      print('Sign up error: $e'); // For debugging
      isLoading.value = false;
      update();
      
      if (context != null) {
        AppUtils.showFailureSnackBar(
          context: context,
          message: "Connection error. Please check your internet connection and try again.",
        );
      }
      return false;
    }
  }

  @override
  void dispose() {
    userNameTEC.dispose();
    emailTEC.dispose();
    passwordTEC.dispose();
    super.dispose();
  }
}
