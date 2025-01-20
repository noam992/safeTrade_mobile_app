import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'export.dart';

class DriverConstants{

  // User authentication spreadsheet
  static String get userSpreadsheetId => dotenv.env['USER_SPREADSHEET_ID'] ?? '';
  static String userSheetRange = 'Sheet1!A:C';

  // Stock list spreadsheet
  static String get stockListSpreadsheetId => dotenv.env['STOCK_LIST_SPREADSHEET_ID'] ?? '';
  static String stockListRange = 'Sheet1!A1:V12'; // 'list!A1:V12'

  // Stock form spreadsheet
  static String get stockFormSpreadsheetId => dotenv.env['STOCK_FORM_SPREADSHEET_ID'] ?? '';
  static String stockFormRange = 'Sheet1!A:P';

  // Drive folder
  static String get imageFolderId => dotenv.env['IMAGE_FOLDER_ID'] ?? '';

  static Future<AutoRefreshingAuthClient> authenticate() async {
    final credentials = json.decode(
      await rootBundle.loadString(AppAssets.credentials),
    );
    final accountCredentials = ServiceAccountCredentials.fromJson(credentials);

    const scopes = [
      sheets.SheetsApi.spreadsheetsScope,
    ];

    return clientViaServiceAccount(accountCredentials, scopes);
  }

}