import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class KPICards extends StatelessWidget {
  final double profit;
  final double profitPercentage;
  final double fee;

  const KPICards({
    super.key,
    required this.profit,
    required this.profitPercentage,
    required this.fee,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildKPICard(
            title: 'Fee',
            value: fee.toStringAsFixed(2),
            color: fee < 0 ? Colors.red.withOpacity(0.1) : AppColors.primaryColor.withOpacity(0.1),
            textColor: fee < 0 ? Colors.red : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKPICard(
            title: 'Profit',
            value: profit.toStringAsFixed(2),
            color: profit >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            textColor: profit >= 0 ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKPICard(
            title: '% Profit',
            value: '${profitPercentage.toStringAsFixed(2)}%',
            color: profitPercentage >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            textColor: profitPercentage >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required Color color,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
} 