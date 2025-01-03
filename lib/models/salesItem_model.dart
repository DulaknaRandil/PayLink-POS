class SalesItem {
  final int? id;
  final int salesId;
  final String name;
  final int quantity;
  final double price;
  final double discount;
  final double total;
  late final bool refund;

  SalesItem({
    this.id,
    required this.salesId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.total,
    this.refund = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'salesId': salesId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'total': total,
      'refund': refund ? 1 : 0,
    };
  }

  factory SalesItem.fromMap(Map<String, dynamic> map) {
    return SalesItem(
      id: map['id'],
      salesId: map['salesId'],
      name: map['name'],
      quantity: map['quantity'],
      price: map['price'],
      discount: map['discount'],
      total: map['total'],
      refund: map['refund'] == 1,
    );
  }
}
