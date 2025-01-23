import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_trade/core/base/export.dart';
import 'package:safe_trade/core/service/cache_manager.dart';
import 'package:safe_trade/screens/add_stock_form/export.dart';
import 'package:safe_trade/utils/app_colors.dart';

import '../../widgets/export.dart';
import 'export.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      initState: (_) {
        Get.put(HomeController());
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.whiteColor,
          appBar: getAppBar(context: context),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.to(
                () => const StockFormView(),
                binding: AppBindings(),
                transition: Transition.downToUp,
                duration: const Duration(milliseconds: 500),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchSpreadsheetData();
              await controller.fetchStockFormData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - AppBar().preferredSize.height,
                child: Column(
                  children: [
                    // First Section - Date Filters
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          getDateFilter(context: context),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(
                                AppColors.primaryColor.withOpacity(0.1),
                              ),
                              columns: const [
                                DataColumn(label: Text('Buy Date')),
                                DataColumn(label: Text('Symbol')),
                                DataColumn(label: Text('Shares')),
                                DataColumn(label: Text('Buy Price')),
                                DataColumn(label: Text('Current Price')),
                                DataColumn(label: Text('Sell Date')),
                                DataColumn(label: Text('Sell Price')),
                                DataColumn(label: Text('Entry (total)')),
                                DataColumn(label: Text('Portfolio (total)')),
                                DataColumn(label: Text('Days (total)')),
                                DataColumn(label: Text('Days (selected period)')),
                                DataColumn(label: Text('Profit (total)')),
                                DataColumn(label: Text('% Profit (total)')),
                                DataColumn(label: Text('Profit (selected period)')),
                                DataColumn(label: Text('% Profit (selected period)')),
                              ],
                              rows: controller.stockFormData
                                  .where((row) {
                                    if (row[0] == 'User Email') return false;
                                    return row[0].toString() == controller.getUserEmail();
                                  })
                                  .map((row) {
                                    double shares = double.tryParse(row[4].toString()) ?? 0;
                                    double buyPrice = double.tryParse(row[3].toString()) ?? 0;
                                    String symbol = row[2].toString();
                                    double currentPrice = controller.currentStockPrices[symbol] ?? 0.0;
                                    double entryTotal = shares * buyPrice;
                                    
                                    // Calculate portfolio total
                                    double sellPrice = double.tryParse(row[8].toString()) ?? 0.0;
                                    double portfolioTotal = shares * (sellPrice > 0 ? sellPrice : currentPrice);
                                    
                                    // Calculate days total
                                    DateTime buyDate = DateTime.tryParse(row[1].toString()) ?? DateTime.now();
                                    DateTime sellDate = DateTime.tryParse(row[7].toString()) ?? DateTime.now();
                                    DateTime endDate = sellPrice > 0 ? sellDate : DateTime.now();
                                    int daysTotal = endDate.difference(buyDate).inDays;
                                    
                                    // Calculate profit and profit percentage
                                    double profitTotal = portfolioTotal == 0 ? 0 : portfolioTotal - entryTotal;
                                    double profitPercentage = entryTotal != 0 ? (profitTotal / entryTotal) * 100 : 0;
                                    
                                    // Calculate days in selected period
                                    DateTime endStockPrice = sellDate ?? DateTime.now();
                                    
                                    // Calculate start and end of selected period
                                    DateTime periodStart = DateTime(controller.fromDate.value.year, controller.fromDate.value.month, 1);
                                    DateTime periodEnd = DateTime(controller.toDate.value.year, controller.toDate.value.month + 1, 0);
                                    
                                    // Calculate days in selected period
                                    int? daysInPeriod = calculateDaysInPeriod(
                                      buyDate: buyDate,
                                      endStockPrice: endStockPrice,
                                      periodStart: periodStart,
                                      periodEnd: periodEnd,
                                    );
                                    
                                    // Calculate profit for selected period
                                    double? profitSelectedPeriod;
                                    double? profitPercentageSelectedPeriod;
                                    
                                    if (daysInPeriod != null && daysTotal > 0) {
                                      profitSelectedPeriod = (profitTotal / daysTotal) * daysInPeriod;
                                      
                                      // Calculate percentage profit for selected period
                                      if (entryTotal > 0) {
                                        profitPercentageSelectedPeriod = (profitSelectedPeriod / entryTotal) * 100;
                                      }
                                    }
                                    
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(row[1].toString().split(' ')[0])), // Buy Date
                                        DataCell(Text(symbol)), // Stock Symbol
                                        DataCell(Text(row[4].toString())), // Shares
                                        DataCell(Text(row[3].toString())), // Buy Price
                                        DataCell(Text(currentPrice.toStringAsFixed(2))), // Current Price (real-time)
                                        DataCell(Text(row[7].toString().split(' ')[0])), // Sell Date
                                        DataCell(Text(row[8].toString())), // Sell Price
                                        DataCell(Text(entryTotal.toStringAsFixed(2))), // Entry total
                                        DataCell(Text(portfolioTotal.toStringAsFixed(2))), // Portfolio total
                                        DataCell(Text(daysTotal.toString())), // Days total
                                        DataCell(Text(daysInPeriod?.toString() ?? '')), // Days in selected period
                                        DataCell(Text(profitTotal.toStringAsFixed(2))), // Profit total
                                        DataCell(Text('${profitPercentage.toStringAsFixed(2)}%')), // Profit percentage
                                        DataCell(Text(profitSelectedPeriod?.toStringAsFixed(2) ?? '')), // Profit selected period
                                        DataCell(Text(profitPercentageSelectedPeriod != null 
                                          ? '${profitPercentageSelectedPeriod.toStringAsFixed(2)}%' 
                                          : '')), // Profit percentage selected period
                                      ],
                                    );
                                  })
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Divider Line
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: 1,
                      color: Colors.grey[300],
                    ),
                    // Second Section - Empty
                    Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                    ),
                    // Third Section - Items List
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            controller.isLoading.isTrue
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : controller.spreadsheetData.isNotEmpty
                                    ? Expanded(
                                        child: ListView.builder(
                                          itemCount: controller.spreadsheetData.length,
                                          itemBuilder: (context, index) {
                                            return recordItems(context, index);
                                          },
                                        ),
                                      )
                                    : const Center(
                                        child: Text('No data found'),
                                      ),
                          ],
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

  AppBar getAppBar({context}) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      surfaceTintColor: AppColors.primaryColor,
      title: Row(
        children: [
          Expanded(
            flex: 2,
            child: AppText(
              text: controller.getUserEmail() ?? '',
              color: AppColors.whiteColor,
              fontSize: 12,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: AppText(
                text: 'Safe Trade',
                color: AppColors.whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      iconTheme: IconThemeData(
        color: AppColors.whiteColor,
      ),
      actions: [
        GestureDetector(
          onTap: () {
            onLogout(context);
          },
          child: AppText(
            text: "Logout",
            color: AppColors.whiteColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  getDateFilter({context}) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'From: ${_formatMonthYear(controller.fromDate.value)}',
              backgroundColor: AppColors.primaryColor,
              fontColor: AppColors.whiteColor,
              isGradient: true,
              fontSize: 14,
              onTap: () => controller.selectDate(context, true),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'To: ${_formatMonthYear(controller.toDate.value)}',
              backgroundColor: AppColors.primaryColor,
              fontColor: AppColors.whiteColor,
              isGradient: true,
              fontSize: 14,
              onTap: () => controller.selectDate(context, false),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonthYear(DateTime date) {
    // Format date to show three-letter month and year (e.g., "Jan 2024")
    return "${_getMonthName(date.month).substring(0, 3)} ${date.year}";
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'January';
      case 2: return 'February';
      case 3: return 'March';
      case 4: return 'April';
      case 5: return 'May';
      case 6: return 'June';
      case 7: return 'July';
      case 8: return 'August';
      case 9: return 'September';
      case 10: return 'October';
      case 11: return 'November';
      case 12: return 'December';
      default: return '';
    }
  }

  recordItems(BuildContext context, int index) {
    final row = controller.spreadsheetData[index];
    return index == 0 ? const SizedBox.shrink() : GestureDetector(
      onTap: () {
        controller.fetchAndDisplayImage(context, row[1].toString());
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 04, horizontal: 08),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyColor.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Stock Data :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(row[1].toString()),
              ],
            ),
            Row(
              children: [
                const Text('Date :'),
                Text(row[0].toString()),
              ],
            ),
            Row(
              children: [
                const Text('Price :'),
                Text(row[10].toString()),
              ],
            ),
            Row(
              children: [
                const Text('Support :'),
                Text(formatToTwoDecimalPlaces(row[12].toString())),
              ],
            ),
            Row(
              children: [
                const Text('Resistance :'),
                Text(formatToTwoDecimalPlaces(row[13].toString())),
              ],
            ),
            Row(
              children: [
                const Text('Channel_Range :'),
                Text(formatToTwoDecimalPlaces(row[14].toString())),
              ],
            ),
            Row(
              children: [
                const Text('Ratio_Channel :'),
                Text(covertToPercentage(row[15].toString())),
              ],
            ),
            Row(
              children: [
                const Text('Ratio_Support :'),
                Text(covertToPercentage(row[16].toString())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  onLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0.5,
          surfaceTintColor: Colors.white,
          title: const Text(
            "Log out?",
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Card(
                        elevation: 0.5,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(35),
                          ),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.065,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              // border: Border.all(color: Colors.grey.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(35),
                              border: Border.all(
                                color: AppColors.primaryColor,
                              )),
                          child: const AppText(
                            text: 'Cancel',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      controller.logoutUser(context: context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Card(
                        elevation: 0.5,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(35),
                          ),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.065,
                          decoration: BoxDecoration(
                              color: AppColors.redColor,
                              // border: Border.all(color: Colors.grey.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(35),
                              border: Border.all(
                                color: AppColors.blackColor,
                              )),
                          child: AppText(
                            text: 'Log Out',
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String covertToPercentage(String percentage) {
    // Parse the string to a double
    double? value = double.tryParse(percentage);

    // Check if parsing was successful
    if (value == null) {
      return "";
    }

    // Multiply by 100 and format to two decimal places
    double percentageValue = value * 100;

    // Return the formatted percentage with the % sign
    return "${percentageValue.toStringAsFixed(2)}%";
  }

  String formatToTwoDecimalPlaces(String value) {
    // Parse the string to a double
    double? number = double.tryParse(value);

    // Check if parsing was successful
    if (number == null) {
      return "";
    }

    // Format to two decimal places
    return number.toStringAsFixed(2);
  }

  int? calculateDaysInPeriod({
    required DateTime buyDate,
    required DateTime endStockPrice,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    // Check if date range is outside the period
    if (periodStart.isAfter(endStockPrice) || 
        periodEnd.isBefore(DateTime(buyDate.year, buyDate.month, 1))) {
      return null;
    }

    bool sameEndMonth = endStockPrice.year == periodEnd.year && 
                       endStockPrice.month == periodEnd.month;
    bool sameBuyMonth = buyDate.year == periodStart.year && 
                       buyDate.month == periodStart.month;

    DateTime effectiveStart = sameBuyMonth ? 
        buyDate : 
        DateTime(periodStart.year, periodStart.month, 1);
    
    DateTime effectiveEnd = sameEndMonth ? 
        endStockPrice : 
        periodEnd;

    return effectiveEnd.difference(effectiveStart).inDays;
  }
}
