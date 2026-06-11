import 'package:inventrax_erp/l10n/app_localizations.dart';

import '../domain/ai_models.dart';

/// Rule-based business risks (no OpenAI cost).
abstract final class BusinessRiskDetector {
  static List<AiBusinessRisk> analyze(AppLocalizations l10n, AiBusinessSnapshot s) {
    final risks = <AiBusinessRisk>[];

    if (s.monthProfitCents < 0) {
      risks.add(
        AiBusinessRisk(
          severity: 'high',
          title: l10n.aiRiskNegativeProfit,
          message: l10n.aiRiskNegativeProfitMsg(
            s.expenseRatioPct.toStringAsFixed(0),
          ),
        ),
      );
    } else if (s.profitMarginPct < 8 && s.monthSalesCents > 0) {
      risks.add(
        AiBusinessRisk(
          severity: 'medium',
          title: l10n.aiRiskThinMargin,
          message: l10n.aiRiskThinMarginMsg(
            s.profitMarginPct.toStringAsFixed(1),
          ),
        ),
      );
    }

    final wow = s.salesWeekOverWeekPct;
    if (wow != null && wow < -15) {
      risks.add(
        AiBusinessRisk(
          severity: 'high',
          title: l10n.aiRiskSalesDeclining,
          message: l10n.aiRiskSalesDecliningMsg(wow.toStringAsFixed(0)),
        ),
      );
    }

    if (s.expenseRatioPct > 35 && s.monthSalesCents > 0) {
      risks.add(
        AiBusinessRisk(
          severity: 'medium',
          title: l10n.aiRiskHighExpense,
          message: l10n.aiRiskHighExpenseMsg(
            s.expenseRatioPct.toStringAsFixed(0),
          ),
        ),
      );
    }

    if (s.lowStockCount > 0) {
      risks.add(
        AiBusinessRisk(
          severity: 'medium',
          title: l10n.aiRiskLowStock,
          message: l10n.aiRiskLowStockMsg(s.lowStockCount),
        ),
      );
    }

    if (s.slowMovingProducts.isNotEmpty) {
      risks.add(
        AiBusinessRisk(
          severity: 'low',
          title: l10n.aiRiskSlowMoving,
          message: l10n.aiRiskSlowMovingMsg(s.slowMovingProducts.length),
        ),
      );
    }

    if (s.customerReceivablesCents > s.monthSalesCents && s.monthSalesCents > 0) {
      risks.add(
        AiBusinessRisk(
          severity: 'high',
          title: l10n.aiRiskHighDebt,
          message: l10n.aiRiskHighDebtMsg,
        ),
      );
    }

    if (s.overdueDebtCount > 0) {
      risks.add(
        AiBusinessRisk(
          severity: 'high',
          title: l10n.aiRiskOverdueDebts,
          message: l10n.aiRiskOverdueDebtsMsg(s.overdueDebtCount),
        ),
      );
    }

    if (s.outOfStockCount > 0) {
      risks.add(
        AiBusinessRisk(
          severity: 'medium',
          title: l10n.aiRiskOutOfStock,
          message: l10n.aiRiskOutOfStockMsg(s.outOfStockCount),
        ),
      );
    }

    return risks;
  }
}
