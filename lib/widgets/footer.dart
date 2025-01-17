import 'package:digisala_pos/database/product_db_helper.dart';
import 'package:digisala_pos/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:digisala_pos/widgets/end_of_day_dialog.dart';
import 'dart:async';

import 'package:digisala_pos/widgets/stock_dialog.dart';

class Footer extends StatefulWidget {
  final String userRole;
  final String? avatarUrl;
  final VoidCallback onVoidOrder;
  final Function onPayment;
  final FocusNode requestFocusNode;
  final double total; // Add this line

  const Footer({
    Key? key,
    this.userRole = 'Admin',
    this.avatarUrl = 'assets/user.png',
    required this.onVoidOrder,
    required this.onPayment,
    required this.requestFocusNode,
    required this.total,
  }) : super(key: key);

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  late String _timeString;
  late Timer _timer;
  List<Product> products = [];
  int lowStockCount = 0;
  int mediumStockCount = 0;
  int highStockCount = 0; // Add this line if needed

  Future<void> _loadProducts() async {
    final _products = await DatabaseHelper.instance.getAllProducts();
    setState(() {
      products = _products;
    });
    // _fetchStockCounts(); // Call this after products are loaded
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _timeString = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      if (mounted) {
        setState(() {
          _timeString = _formatDateTime(DateTime.now());
          _loadProducts();
          _fetchStockCounts(); // Update stock counts every second
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    final String hour = dateTime.hour > 12
        ? (dateTime.hour - 12).toString().padLeft(2, '0')
        : dateTime.hour.toString().padLeft(2, '0');
    final String period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')} $period';
  }

  void _fetchStockCounts() {
    final allFilteredProducts = products.where((product) {
      return true;
    }).toList();
    print('Filtered products: ${allFilteredProducts.length}');
    print(
        'Low stock count: ${allFilteredProducts.where((p) => p.quantity < 5).length}');
    print(
        'Medium stock count: ${allFilteredProducts.where((p) => p.quantity >= 5 && p.quantity < 15).length}');
    print(
        'High stock count: ${allFilteredProducts.where((p) => p.quantity >= 15).length}');

    setState(() {
      _loadProducts();
      lowStockCount = allFilteredProducts.where((p) => p.quantity < 5).length;
      mediumStockCount = allFilteredProducts
          .where((p) => p.quantity >= 5 && p.quantity < 15)
          .length;
      highStockCount =
          allFilteredProducts.where((p) => p.quantity >= 15).length;
    });
  }

  void _showStockDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StockDialog(
          searchBarFocusNode: widget.requestFocusNode,
        );
      },
    );
  }

  void _showEndOfDayDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EndOfDayDialog(
          searchBarFocusNode: widget.requestFocusNode,
        ); // Use the EndOfDayDialog
      },
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(2, 10, 27, 1),
          title: const Text(
            'Confirm Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 75,
      decoration: BoxDecoration(
        color: const Color(0xFF313131),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFDBDBDB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(HugeIcons.strokeRoundedLogin02,
                  color: Colors.black),
              onPressed: _showLogoutConfirmationDialog,
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 32,
            backgroundImage: AssetImage(widget.avatarUrl ?? ''),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _timeString,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                widget.userRole,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildActionButton('Void Order', Colors.red, widget.onVoidOrder),
          _buildActionButton(
              'End of Day', Colors.lightBlue, _showEndOfDayDialog),
          Stack(
            children: [
              _buildActionButton('Stock ', Colors.teal, _showStockDialog),
              Positioned(
                right: 1,
                top: -5,
                child: _buildStockBubble(lowStockCount, Colors.red),
              ),
              Positioned(
                right: 0, // Adjust this value to position the second bubble
                bottom: 6,
                child: _buildStockBubble(mediumStockCount, Colors.yellow),
              ),
            ],
          ),
          _buildActionButton('Payment', Colors.green,
              widget.total > 0 ? widget.onPayment : null),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, onPressed) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockBubble(int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
