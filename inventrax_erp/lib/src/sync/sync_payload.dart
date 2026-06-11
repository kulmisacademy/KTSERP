import '../data/local/app_database.dart';

/// JSON payloads pushed to Supabase (tables must match cloud schema).
class SyncPayload {
  static Map<String, dynamic> product(Product p) => {
        'id': p.id,
        'tenant_id': p.tenantId,
        'store_id': p.storeId,
        'name': p.name,
        'barcode': p.barcode,
        'sku': p.sku,
        'quantity': p.quantity,
        'purchase_price_cents': p.purchasePriceCents,
        'selling_price_cents': p.sellingPriceCents,
        'updated_at': p.updatedAt.toIso8601String(),
        'image_url': p.imageUrl,
        'thumbnail_url': p.thumbnailUrl,
        'category_icon': p.categoryIcon,
        'has_image': p.hasImage,
      };

  static Map<String, dynamic> sale(
    Sale sale,
    List<SaleItem> items,
  ) =>
      {
        'id': sale.id,
        'tenant_id': sale.tenantId,
        'store_id': sale.storeId,
        'subtotal_cents': sale.subtotalCents,
        'discount_cents': sale.discountCents,
        'tax_cents': sale.taxCents,
        'total_cents': sale.totalCents,
        'refunded_total_cents': sale.refundedTotalCents,
        'status': sale.status,
        'payment_json': sale.paymentJson,
        'customer_id': sale.customerId,
        'created_at': sale.createdAt.toIso8601String(),
        'items': items
            .map(
              (i) => {
                'id': i.id,
                'product_id': i.productId,
                'name': i.name,
                'quantity': i.quantity,
                'unit_price_cents': i.unitPriceCents,
                'line_total_cents': i.lineTotalCents,
                'refunded_quantity': i.refundedQuantity,
              },
            )
            .toList(),
      };

  static Map<String, dynamic> purchase(
    Purchase purchase,
    List<PurchaseItem> items,
  ) =>
      {
        'id': purchase.id,
        'tenant_id': purchase.tenantId,
        'store_id': purchase.storeId,
        'supplier_id': purchase.supplierId,
        'total_cents': purchase.totalCents,
        'paid_cents': purchase.paidCents,
        'purchase_date': purchase.purchaseDate.toIso8601String(),
        'items': items
            .map(
              (i) => {
                'id': i.id,
                'product_id': i.productId,
                'quantity': i.quantity,
                'purchase_price_cents': i.purchasePriceCents,
                'line_total_cents': i.lineTotalCents,
              },
            )
            .toList(),
      };

  static Map<String, dynamic> supplier(Supplier s) => {
        'id': s.id,
        'tenant_id': s.tenantId,
        'store_id': s.storeId,
        'name': s.name,
        'phone': s.phone,
        'email': s.email,
        'updated_at': s.updatedAt.toIso8601String(),
      };

  static Map<String, dynamic> customer(Customer c) => {
        'id': c.id,
        'tenant_id': c.tenantId,
        'store_id': c.storeId,
        'name': c.name,
        'phone': c.phone,
        'email': c.email,
        'updated_at': c.updatedAt.toIso8601String(),
      };

  static Map<String, dynamic> category(Category c) => {
        'id': c.id,
        'tenant_id': c.tenantId,
        'store_id': c.storeId,
        'name': c.name,
        'parent_id': c.parentId,
        'created_at': c.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> brand(Brand b) => {
        'id': b.id,
        'tenant_id': b.tenantId,
        'store_id': b.storeId,
        'name': b.name,
        'created_at': b.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> expense(Expense e) => {
        'id': e.id,
        'tenant_id': e.tenantId,
        'store_id': e.storeId,
        'name': e.name,
        'category': e.category,
        'amount_cents': e.amountCents,
        'expense_date': e.expenseDate.toIso8601String(),
        'paid_by': e.paidBy,
        'notes': e.notes,
        'created_at': e.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> debt(Debt d) => {
        'id': d.id,
        'tenant_id': d.tenantId,
        'store_id': d.storeId,
        'debt_type': d.debtType,
        'supplier_id': d.supplierId,
        'customer_id': d.customerId,
        'original_cents': d.originalCents,
        'paid_cents': d.paidCents,
        'remaining_cents': d.remainingCents,
        'due_date': d.dueDate?.toIso8601String(),
        'status': d.status,
        'notes': d.notes,
        'sale_id': d.saleId,
        'purchase_id': d.purchaseId,
        'invoice_number': d.invoiceNumber,
        'created_at': d.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> debtPayment(DebtPayment p) => {
        'id': p.id,
        'tenant_id': p.tenantId,
        'store_id': p.storeId,
        'debt_id': p.debtId,
        'amount_cents': p.amountCents,
        'paid_at': p.paidAt.toIso8601String(),
        'method': p.method,
        'payment_account_id': p.paymentAccountId,
        'notes': p.notes,
        'user_id': p.userId,
        'created_at': p.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> chartOfAccount(ChartOfAccount a) => {
        'id': a.id,
        'tenant_id': a.tenantId,
        'store_id': a.storeId,
        'code': a.code,
        'name': a.name,
        'type': a.type,
        'parent_id': a.parentId,
        'opening_balance_cents': a.openingBalanceCents,
        'is_system': a.isSystem,
        'is_active': a.isActive,
        'created_at': a.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> paymentAccount(PaymentAccount p) => {
        'id': p.id,
        'tenant_id': p.tenantId,
        'store_id': p.storeId,
        'name': p.name,
        'account_type': p.accountType,
        'chart_account_id': p.chartAccountId,
        'is_default': p.isDefault,
        'is_active': p.isActive,
        'created_at': p.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> journalEntry(JournalEntry e) => {
        'id': e.id,
        'tenant_id': e.tenantId,
        'store_id': e.storeId,
        'entry_date': e.entryDate.toIso8601String(),
        'description': e.description,
        'source_module': e.sourceModule,
        'source_id': e.sourceId,
        'status': e.status,
        'created_by': e.createdBy,
        'notes': e.notes,
        'created_at': e.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> journalLine(JournalLine l) => {
        'id': l.id,
        'tenant_id': l.tenantId,
        'store_id': l.storeId,
        'journal_entry_id': l.journalEntryId,
        'account_id': l.accountId,
        'debit_cents': l.debitCents,
        'credit_cents': l.creditCents,
        'line_description': l.lineDescription,
        'updated_at': l.updatedAt.toIso8601String(),
      };
}
