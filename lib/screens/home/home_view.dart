import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_trade/core/base/export.dart';
import 'package:safe_trade/core/service/cache_manager.dart';
import 'package:safe_trade/screens/add_stock_form/export.dart';
import 'package:safe_trade/utils/app_colors.dart';
import 'dart:math';

import '../../widgets/export.dart';
import 'export.dart';
import '../../widgets/kpi_cards.dart';

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
              await controller.updateCurrentStockPrices();
              controller.startStockPriceUpdates();
            },
            child: OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.portrait) {
                  // Portrait mode (Vertical)
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Column(
                        children: [
                          // First Section - Date Filters and Table
                          Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                getDateFilter(context: context),
                                const SizedBox(height: 16),
                                KPICards(
                                  profit: _calculateTotalProfit(controller),
                                  profitPercentage: _calculateTotalProfitPercentage(controller),
                                  fee: controller.calculateTotalFee(),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: max(
                                        MediaQuery.of(context).size.width * 4,
                                        1800.0, // minimum width to accommodate all columns
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            color: AppColors.primaryColor.withOpacity(0.1),
                                            child: Row(
                                              children: const [
                                                _HeaderCell('Buy Date', flex: 1, width: 100),
                                                _HeaderCell('Symbol', flex: 1, width: 100),
                                                _HeaderCell('Profit (selected period)', flex: 2, width: 160),
                                                _HeaderCell('% Profit (selected period)', flex: 2, width: 160),
                                                _HeaderCell('Days (selected period)', flex: 2, width: 160),
                                                _HeaderCell('Buy Price', flex: 1, width: 100),
                                                _HeaderCell('Current Price', flex: 1, width: 120),
                                                _HeaderCell('Sell Price', flex: 1, width: 100),
                                                _HeaderCell('Sell Date', flex: 1, width: 100),
                                                _HeaderCell('Shares', flex: 1, width: 100),
                                                _HeaderCell('Entry (total)', flex: 1, width: 120),
                                                _HeaderCell('Portfolio (total)', flex: 1, width: 120),
                                                _HeaderCell('Profit (total)', flex: 1, width: 120),
                                                _HeaderCell('% Profit (total)', flex: 1, width: 120),
                                                _HeaderCell('Days (total)', flex: 1, width: 100),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: controller.stockFormData
                                                    .where((row) {
                                                      if (row[0] == 'User Email') return false;
                                                      if (row[0].toString() != controller.getUserEmail()) return false;
                                                      
                                                      // Calculate all the values first
                                                      DateTime buyDate = DateTime.tryParse(row[1].toString()) ?? DateTime.now();
                                                      DateTime sellDate = DateTime.tryParse(row[7].toString()) ?? DateTime.now();
                                                      DateTime endStockPrice = sellDate;
                                                      
                                                      // Calculate start and end of selected period
                                                      DateTime periodStart = DateTime(controller.fromDate.value.year, controller.fromDate.value.month, 1);
                                                      DateTime periodEnd = DateTime(controller.toDate.value.year, controller.toDate.value.month + 1, 0);
                                                      
                                                      // Calculate days in period
                                                      int? daysInPeriod = calculateDaysInPeriod(
                                                        buyDate: buyDate,
                                                        endStockPrice: endStockPrice,
                                                        periodStart: periodStart,
                                                        periodEnd: periodEnd,
                                                      );
                                                      
                                                      // Include rows where days in period is not null (including 0)
                                                      return daysInPeriod != null;
                                                    })
                                                    .length,
                                                itemBuilder: (context, index) {
                                                  final row = controller.stockFormData
                                                      .where((row) {
                                                        if (row[0] == 'User Email') return false;
                                                        if (row[0].toString() != controller.getUserEmail()) return false;
                                                        
                                                        // Calculate all the values first
                                                        DateTime buyDate = DateTime.tryParse(row[1].toString()) ?? DateTime.now();
                                                        DateTime sellDate = DateTime.tryParse(row[7].toString()) ?? DateTime.now();
                                                        DateTime endStockPrice = sellDate;
                                                        
                                                        // Calculate start and end of selected period
                                                        DateTime periodStart = DateTime(controller.fromDate.value.year, controller.fromDate.value.month, 1);
                                                        DateTime periodEnd = DateTime(controller.toDate.value.year, controller.toDate.value.month + 1, 0);
                                                        
                                                        // Calculate days in period
                                                        int? daysInPeriod = calculateDaysInPeriod(
                                                          buyDate: buyDate,
                                                          endStockPrice: endStockPrice,
                                                          periodStart: periodStart,
                                                          periodEnd: periodEnd,
                                                        );
                                                        
                                                        // Include rows where days in period is not null (including 0)
                                                        return daysInPeriod != null;
                                                      })
                                                      .toList()[index];
                                                  
                                                  double shares = double.tryParse(row[4].toString()) ?? 0;
                                                  double buyPrice = double.tryParse(row[3].toString()) ?? 0;
                                                  String symbol = row[2].toString();
                                                  double currentPrice = controller.currentStockPrices[symbol] ?? 0.0;
                                                  double entryTotal = shares * buyPrice;
                                                  
                                                  // Calculate portfolio total
                                                  double sellPrice = double.tryParse(row[8].toString()) ?? 0.0;
                                                  double portfolioTotal = shares * (sellPrice > 0 ? sellPrice : currentPrice);
                                                  
                                                  // Calculate days total (modified to include start day)
                                                  DateTime buyDate = DateTime.tryParse(row[1].toString()) ?? DateTime.now();
                                                  DateTime sellDate = DateTime.tryParse(row[7].toString()) ?? DateTime.now();
                                                  DateTime endDate = sellPrice > 0 ? sellDate : DateTime.now();
                                                  int daysTotal = endDate.difference(buyDate).inDays + 1;  // Added +1 to include start day
                                                  
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
                                                  
                                                  return Row(
                                                    children: [
                                                      _ContentCell(row[1].toString().split(' ')[0], flex: 1, width: 100),
                                                      _ContentCell(symbol, flex: 1, width: 100),
                                                      _ContentCell(
                                                        profitSelectedPeriod?.toStringAsFixed(2) ?? '',
                                                        flex: 2,
                                                        width: 160,
                                                        color: (profitSelectedPeriod ?? 0) > 0 
                                                          ? Colors.green 
                                                          : (profitSelectedPeriod ?? 0) < 0 
                                                            ? Colors.red 
                                                            : null,
                                                      ),
                                                      _ContentCell(
                                                        profitPercentageSelectedPeriod != null 
                                                          ? '${profitPercentageSelectedPeriod.toStringAsFixed(2)}%' 
                                                          : '',
                                                        flex: 2,
                                                        width: 160,
                                                        color: (profitPercentageSelectedPeriod ?? 0) > 0 
                                                          ? Colors.green 
                                                          : (profitPercentageSelectedPeriod ?? 0) < 0 
                                                            ? Colors.red 
                                                            : null,
                                                      ),
                                                      _ContentCell(daysInPeriod?.toString() ?? '', flex: 2, width: 160),
                                                      _ContentCell(row[3].toString(), flex: 1, width: 100),
                                                      _ContentCell(currentPrice.toStringAsFixed(2), flex: 1, width: 120),
                                                      _ContentCell(row[8].toString(), flex: 1, width: 100),
                                                      _ContentCell(row[7].toString().split(' ')[0], flex: 1, width: 100),
                                                      _ContentCell(row[4].toString(), flex: 1, width: 100),
                                                      _ContentCell(entryTotal.toStringAsFixed(2), flex: 1, width: 120),
                                                      _ContentCell(portfolioTotal.toStringAsFixed(2), flex: 1, width: 120),
                                                      _ContentCell(
                                                        profitTotal.toStringAsFixed(2),
                                                        flex: 1,
                                                        width: 120,
                                                        color: profitTotal > 0 
                                                          ? Colors.green 
                                                          : profitTotal < 0 
                                                            ? Colors.red 
                                                            : null,
                                                      ),
                                                      _ContentCell(
                                                        '${profitPercentage.toStringAsFixed(2)}%',
                                                        flex: 1,
                                                        width: 120,
                                                        color: profitPercentage > 0 
                                                          ? Colors.green 
                                                          : profitPercentage < 0 
                                                            ? Colors.red 
                                                            : null,
                                                      ),
                                                      _ContentCell(daysTotal.toString(), flex: 1, width: 100),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Second Section - Items List
                          Container(
                            height: MediaQuery.of(context).size.height * 0.5,
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
                        ],
                      ),
                    ),
                  );
                } else {
                  // Landscape mode (Horizontal)
                  return Row(
                    children: [
                      // First Section - Date Filters and Table
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              getDateFilter(context: context),
                              const SizedBox(height: 16),
                              KPICards(
                                profit: _calculateTotalProfit(controller),
                                profitPercentage: _calculateTotalProfitPercentage(controller),
                                fee: controller.calculateTotalFee(),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: max(
                                      MediaQuery.of(context).size.width * 4,
                                      1800.0, // minimum width to accommodate all columns
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          color: AppColors.primaryColor.withOpacity(0.1),
                                          child: Row(
                                            children: const [
                                              _HeaderCell('Buy Date', flex: 1, width: 100),
                                              _HeaderCell('Symbol', flex: 1, width: 100),
                                              _HeaderCell('Profit (selected period)', flex: 2, width: 160),
                                              _HeaderCell('% Profit (selected period)', flex: 2, width: 160),
                                              _HeaderCell('Days (selected period)', flex: 2, width: 160),
                                              _HeaderCell('Buy Price', flex: 1, width: 100),
                                              _HeaderCell('Current Price', flex: 1, width: 120),
                                              _HeaderCell('Sell Price', flex: 1, width: 100),
                                              _HeaderCell('Sell Date', flex: 1, width: 100),
                                              _HeaderCell('Shares', flex: 1, width: 100),
                                              _HeaderCell('Entry (total)', flex: 1, width: 120),
                                              _HeaderCell('Portfolio (total)', flex: 1, width: 120),
                                              _HeaderCell('Profit (total)', flex: 1, width: 120),
                                              _HeaderCell('% Profit (total)', flex: 1, width: 120),
                                              _HeaderCell('Days (total)', flex: 1, width: 100),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: controller.stockFormData
                                                  .where((row) {
                                                    if (row[0] == 'User Email') return false;
                                                    if (row[0].toString() != controller.getUserEmail()) return false;
                                                    
                                                    // Calculate all the values first
                                                    DateTime buyDate = DateTime.tryParse(row[1].toString()) ?? DateTime.now();
                                                    DateTime sellDate = DateTime.tryParse(row[7].toString()) ?? DateTime.now();
                                                    DateTime endStockPrice = sellDate;
                                                    
                                                    // Calculate start and end of selected period
                                                    DateTime periodStart = DateTime(controller.fromDate.value.year, controller.fromDate.value.month, 1);
                                                    DateTime periodEnd = DateTime(controller.toDate.value.year, controller.toDate.value.month + 1, 0);
                                                    
                                                    // Calculate days in period
                                                    int? daysInPeriod = calculateDaysInPeriod(
                                                      buyDate: buyDate,
                                                      endStockPrice: endStockPrice,
                                                      periodStart: periodStart,
                                                      periodEnd: periodEnd,
                                                    );
                                                    
                                                    // Include rows where days in period is not null (including 0)
                                                    return daysInPeriod != null;
                                                  })
                                                  .length,
                                              itemBuilder: (context, index) {
                                                final row = controller.stockFormData
                                                    .where((row) {
                                                      if (row[0] == 'User Email') return false;
                                                      if (row[0].toString() != controller.getUserEmail()) return false;
                                                      
                                                      // Calculate all the values first
                                                      DateTime buyDate = DateTime.tryParse(row[1].toString()) ?? DateTime.now();
                                                      DateTime sellDate = DateTime.tryParse(row[7].toString()) ?? DateTime.now();
                                                      DateTime endStockPrice = sellDate;
                                                      
                                                      // Calculate start and end of selected period
                                                      DateTime periodStart = DateTime(controller.fromDate.value.year, controller.fromDate.value.month, 1);
                                                      DateTime periodEnd = DateTime(controller.toDate.value.year, controller.toDate.value.month + 1, 0);
                                                      
                                                      // Calculate days in period
                                                      int? daysInPeriod = calculateDaysInPeriod(
                                                        buyDate: buyDate,
                                                        endStockPrice: endStockPrice,
                                                        periodStart: periodStart,
                                                        periodEnd: periodEnd,
                                                      );
                                                      
                                                      // Include rows where days in period is not null (including 0)
                                                      return daysInPeriod != null;
                                                    })
                                                    .toList()[index];
                                                
                                                double shares = double.tryParse(row[4].toString()) ?? 0;
                                                double buyPrice = double.tryParse(row[3].toString()) ?? 0;
                                                String symbol = row[2].toString();
                                                double currentPrice = controller.currentStockPrices[symbol] ?? 0.0;
                                                double entryTotal = shares * buyPrice;
                                                
                                                // Calculate portfolio total
                                                double sellPrice = double.tryParse(row[8].toString()) ?? 0.0;
                                                double portfolioTotal = shares * (sellPrice > 0 ? sellPrice : currentPrice);
                                                
                                                // Calculate days total (modified to include start day)
                                                DateTime buyDate = DateTime.tryParse(row[1].toString()) ?? DateTime.now();
                                                DateTime sellDate = DateTime.tryParse(row[7].toString()) ?? DateTime.now();
                                                DateTime endDate = sellPrice > 0 ? sellDate : DateTime.now();
                                                int daysTotal = endDate.difference(buyDate).inDays + 1;  // Added +1 to include start day
                                                
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
                                                
                                                return Row(
                                                  children: [
                                                    _ContentCell(row[1].toString().split(' ')[0], flex: 1, width: 100),
                                                    _ContentCell(symbol, flex: 1, width: 100),
                                                    _ContentCell(
                                                      profitSelectedPeriod?.toStringAsFixed(2) ?? '',
                                                      flex: 2,
                                                      width: 160,
                                                      color: (profitSelectedPeriod ?? 0) > 0 
                                                        ? Colors.green 
                                                        : (profitSelectedPeriod ?? 0) < 0 
                                                          ? Colors.red 
                                                          : null,
                                                    ),
                                                    _ContentCell(
                                                      profitPercentageSelectedPeriod != null 
                                                        ? '${profitPercentageSelectedPeriod.toStringAsFixed(2)}%' 
                                                        : '',
                                                      flex: 2,
                                                      width: 160,
                                                      color: (profitPercentageSelectedPeriod ?? 0) > 0 
                                                        ? Colors.green 
                                                        : (profitPercentageSelectedPeriod ?? 0) < 0 
                                                          ? Colors.red 
                                                          : null,
                                                    ),
                                                    _ContentCell(daysInPeriod?.toString() ?? '', flex: 2, width: 160),
                                                    _ContentCell(row[3].toString(), flex: 1, width: 100),
                                                    _ContentCell(currentPrice.toStringAsFixed(2), flex: 1, width: 120),
                                                    _ContentCell(row[8].toString(), flex: 1, width: 100),
                                                    _ContentCell(row[7].toString().split(' ')[0], flex: 1, width: 100),
                                                    _ContentCell(row[4].toString(), flex: 1, width: 100),
                                                    _ContentCell(entryTotal.toStringAsFixed(2), flex: 1, width: 120),
                                                    _ContentCell(portfolioTotal.toStringAsFixed(2), flex: 1, width: 120),
                                                    _ContentCell(
                                                      profitTotal.toStringAsFixed(2),
                                                      flex: 1,
                                                      width: 120,
                                                      color: profitTotal > 0 
                                                        ? Colors.green 
                                                        : profitTotal < 0 
                                                          ? Colors.red 
                                                          : null,
                                                    ),
                                                    _ContentCell(
                                                      '${profitPercentage.toStringAsFixed(2)}%',
                                                      flex: 1,
                                                      width: 120,
                                                      color: profitPercentage > 0 
                                                        ? Colors.green 
                                                        : profitPercentage < 0 
                                                          ? Colors.red 
                                                          : null,
                                                    ),
                                                    _ContentCell(daysTotal.toString(), flex: 1, width: 100),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Second Section - Items List
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              bottomLeft: Radius.circular(30),
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
                  );
                }
              },
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
              text: 'From\n${_formatMonthYear(controller.fromDate.value)}',
              backgroundColor: AppColors.primaryColor,
              fontColor: AppColors.whiteColor,
              isGradient: true,
              fontSize: 14,
              textAlign: TextAlign.center,
              onTap: () => controller.selectDate(context, true),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'To\n${_formatMonthYear(controller.toDate.value)}',
              backgroundColor: AppColors.primaryColor,
              fontColor: AppColors.whiteColor,
              isGradient: true,
              fontSize: 14,
              textAlign: TextAlign.center,
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
    // If buy date is after period end or end stock price is before period start, 
    // there's no overlap
    if (buyDate.isAfter(periodEnd) || endStockPrice.isBefore(periodStart)) {
      return null;
    }

    // Calculate effective start date (later of buy date and period start)
    DateTime effectiveStart = buyDate.isAfter(periodStart) ? buyDate : periodStart;
    
    // Calculate effective end date (earlier of end stock price and period end)
    DateTime effectiveEnd = endStockPrice.isBefore(periodEnd) ? 
        endStockPrice : periodEnd;

    // Calculate days between effective dates (including start day)
    return effectiveEnd.difference(effectiveStart).inDays + 1;
  }

  double _calculateTotalProfit(HomeController controller) {
    double totalProfit = 0.0;
    
    for (var row in controller.stockFormData) {
      if (row[0] == 'User Email') continue;
      if (row[0].toString() != controller.getUserEmail()) continue;
      
      DateTime buyDate = DateTime.tryParse(row[1].toString()) ?? DateTime.now();
      DateTime sellDate = DateTime.tryParse(row[7].toString()) ?? DateTime.now();
      DateTime endStockPrice = sellDate;
      
      DateTime periodStart = DateTime(controller.fromDate.value.year, controller.fromDate.value.month, 1);
      DateTime periodEnd = DateTime(controller.toDate.value.year, controller.toDate.value.month + 1, 0);
      
      int? daysInPeriod = calculateDaysInPeriod(
        buyDate: buyDate,
        endStockPrice: endStockPrice,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
      
      if (daysInPeriod != null) {
        double shares = double.tryParse(row[4].toString()) ?? 0;
        double buyPrice = double.tryParse(row[3].toString()) ?? 0;
        String symbol = row[2].toString();
        double currentPrice = controller.currentStockPrices[symbol] ?? 0.0;
        double entryTotal = shares * buyPrice;
        double sellPrice = double.tryParse(row[8].toString()) ?? 0.0;
        double portfolioTotal = shares * (sellPrice > 0 ? sellPrice : currentPrice);
        double profitTotal = portfolioTotal - entryTotal;
        int daysTotal = endStockPrice.difference(buyDate).inDays;
        
        if (daysTotal > 0) {
          double profitPerDay = profitTotal / daysTotal;
          totalProfit += profitPerDay * daysInPeriod;
        }
      }
    }
    
    return totalProfit;
  }

  double _calculateTotalProfitPercentage(HomeController controller) {
    double totalProfitPercentage = 0.0;
    int validRecords = 0;
    
    for (var row in controller.stockFormData) {
      if (row[0] == 'User Email') continue;
      if (row[0].toString() != controller.getUserEmail()) continue;
      
      DateTime buyDate = DateTime.tryParse(row[1].toString()) ?? DateTime.now();
      DateTime sellDate = DateTime.tryParse(row[7].toString()) ?? DateTime.now();
      DateTime endStockPrice = sellDate;
      
      DateTime periodStart = DateTime(controller.fromDate.value.year, controller.fromDate.value.month, 1);
      DateTime periodEnd = DateTime(controller.toDate.value.year, controller.toDate.value.month + 1, 0);
      
      int? daysInPeriod = calculateDaysInPeriod(
        buyDate: buyDate,
        endStockPrice: endStockPrice,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
      
      if (daysInPeriod != null) {
        double shares = double.tryParse(row[4].toString()) ?? 0;
        double buyPrice = double.tryParse(row[3].toString()) ?? 0;
        String symbol = row[2].toString();
        double currentPrice = controller.currentStockPrices[symbol] ?? 0.0;
        double entryTotal = shares * buyPrice;
        double sellPrice = double.tryParse(row[8].toString()) ?? 0.0;
        double portfolioTotal = shares * (sellPrice > 0 ? sellPrice : currentPrice);
        double profitTotal = portfolioTotal - entryTotal;
        int daysTotal = endStockPrice.difference(buyDate).inDays;
        
        if (daysTotal > 0 && entryTotal > 0) {
          double profitPerDay = profitTotal / daysTotal;
          double periodProfit = profitPerDay * daysInPeriod;
          double periodProfitPercentage = (periodProfit / entryTotal) * 100;
          totalProfitPercentage += periodProfitPercentage;
          validRecords++;
        }
      }
    }
    
    return validRecords > 0 ? totalProfitPercentage / validRecords : 0;
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final double width;

  const _HeaderCell(this.text, {required this.flex, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        softWrap: true,
      ),
    );
  }
}

class _ContentCell extends StatelessWidget {
  final String text;
  final int flex;
  final Color? color;
  final double width;

  const _ContentCell(this.text, {
    required this.flex, 
    this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
        softWrap: true,
        maxLines: 2,
      ),
    );
  }
}
