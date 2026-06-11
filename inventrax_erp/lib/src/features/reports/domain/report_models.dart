class ProfitSnapshot {
  const ProfitSnapshot({
    required this.salesCents,
    required this.cogsCents,
    required this.expensesCents,
  });

  final int salesCents;
  final int cogsCents;
  final int expensesCents;

  int get profitCents => salesCents - cogsCents - expensesCents;
}

