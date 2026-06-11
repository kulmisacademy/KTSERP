import 'pos_models.dart';
import 'pos_tax.dart';

class PosState {
  const PosState({
    required this.cart,
    required this.orderDiscountCents,
    required this.taxCents,
    required this.customerId,
    required this.customerName,
    required this.notes,
  });

  final List<PosCartItem> cart;
  final int orderDiscountCents;
  final int taxCents;
  final String? customerId;
  final String? customerName;
  final String? notes;

  int get subtotalCents =>
      cart.fold(0, (sum, i) => sum + i.lineTotalCents);

  int totalCents([PosTaxCalculator? tax]) {
    if (tax != null && tax.hasTax) {
      return tax.grandTotalCents(subtotalCents, orderDiscountCents);
    }
    final afterDiscount = subtotalCents - orderDiscountCents;
    return (afterDiscount < 0 ? 0 : afterDiscount) + taxCents;
  }

  PosState copyWith({
    List<PosCartItem>? cart,
    int? orderDiscountCents,
    int? taxCents,
    String? customerId,
    String? customerName,
    String? notes,
    bool clearCustomer = false,
  }) {
    return PosState(
      cart: cart ?? this.cart,
      orderDiscountCents: orderDiscountCents ?? this.orderDiscountCents,
      taxCents: taxCents ?? this.taxCents,
      customerId: clearCustomer ? null : (customerId ?? this.customerId),
      customerName: clearCustomer ? null : (customerName ?? this.customerName),
      notes: notes ?? this.notes,
    );
  }
}
