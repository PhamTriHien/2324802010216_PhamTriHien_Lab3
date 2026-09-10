import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';

/// Màn hình Giỏ hàng (CartScreen)
/// Minh họa:
/// - Điều hướng đến bằng Named Route ('/cart')
/// - Tiếp nhận danh sách CartItem
/// - Quản lý số lượng, xóa sản phẩm, tính toán giá trị đơn hàng
/// - Hiển thị hộp thoại xác nhận thanh toán (AlertDialog)
/// - Trả về kết quả điều hướng qua Navigator.pop(context, result)
class CartScreen extends StatefulWidget {
  final List<CartItem>? cartItems;
  final VoidCallback? onClearCart;
  final Function(Product)? onRemoveItem;
  final Function(Product, int)? onUpdateQuantity;

  const CartScreen({
    super.key,
    this.cartItems,
    this.onClearCart,
    this.onRemoveItem,
    this.onUpdateQuantity,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  /// Tính tổng tiền tạm tính của giỏ hàng
  double get _subtotal {
    final items = widget.cartItems ?? [];
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  /// Ưu đãi giảm giá 5% cho thành viên sinh viên
  double get _discount => _subtotal * 0.05;

  /// Tổng tiền thanh toán cuối cùng
  double get _totalPayment => _subtotal - _discount;

  /// Hiển thị hộp thoại xác nhận thanh toán đơn hàng
  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Xác nhận đặt hàng', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin khách hàng:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              const Text('Họ tên: Phạm Trí Hiển'),
              const Text('MSSV: 2324802010216'),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng số lượng:'),
                  Text(
                    '${widget.cartItems?.fold<int>(0, (prev, e) => prev + e.quantity) ?? 0} món',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng thanh toán:'),
                  Text(
                    _currencyFormat.format(_totalPayment),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Đơn hàng sẽ được xử lý và giao đến bạn trong 24h!',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade600,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext); // Đóng Dialog
                if (widget.onClearCart != null) {
                  widget.onClearCart!();
                }
                // Quay về màn hình trước với thông điệp đặt hàng thành công
                Navigator.pop(context, 'CHECKOUT_SUCCESS');
              },
              child: const Text('Xác nhận thanh toán'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.cartItems ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Giỏ hàng công nghệ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Xóa toàn bộ giỏ hàng',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xóa toàn bộ giỏ hàng?'),
                    content: const Text(
                      'Bạn có chắc muốn xóa tất cả sản phẩm trong giỏ hàng không?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Không'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          if (widget.onClearCart != null) {
                            widget.onClearCart!();
                          }
                          setState(() {});
                        },
                        child: const Text('Xóa hết'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 100,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Giỏ hàng của bạn đang trống!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy khám phá và chọn cho mình các sản phẩm công nghệ ưng ý.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Tiếp tục mua sắm'),
                      onPressed: () {
                        Navigator.pop(context); // Quay lại màn hình chính
                      },
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // 1. Danh sách các sản phẩm trong giỏ
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Icon sản phẩm
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: item.product.themeColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item.product.icon,
                                color: item.product.themeColor,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Thông tin tên và đơn giá
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currencyFormat.format(item.product.price),
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // Bộ tăng giảm số lượng
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (item.quantity > 1) {
                                            if (widget.onUpdateQuantity !=
                                                null) {
                                              widget.onUpdateQuantity!(
                                                  item.product,
                                                  item.quantity - 1);
                                            }
                                            setState(() {});
                                          } else {
                                            // Nếu số lượng = 1 thì xóa
                                            if (widget.onRemoveItem != null) {
                                              widget
                                                  .onRemoveItem!(item.product);
                                            }
                                            setState(() {});
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Icon(Icons.remove,
                                              size: 16),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (item.quantity <
                                              item.product.stock) {
                                            if (widget.onUpdateQuantity !=
                                                null) {
                                              widget.onUpdateQuantity!(
                                                  item.product,
                                                  item.quantity + 1);
                                            }
                                            setState(() {});
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child:
                                              const Icon(Icons.add, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Nút xóa món
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.grey),
                              tooltip: 'Xóa khỏi giỏ',
                              onPressed: () {
                                if (widget.onRemoveItem != null) {
                                  widget.onRemoveItem!(item.product);
                                }
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 2. Bảng tính tiền & Nút xác nhận đặt hàng
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tạm tính:',
                                style: TextStyle(color: Colors.grey)),
                            Text(_currencyFormat.format(_subtotal)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Giảm giá SV (5%):',
                                style: TextStyle(color: Colors.green)),
                            Text('-${_currencyFormat.format(_discount)}',
                                style: const TextStyle(color: Colors.green)),
                          ],
                        ),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng thanh toán:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _currencyFormat.format(_totalPayment),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.payment),
                            label: const Text(
                              'Xác nhận đặt hàng',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            onPressed: _showCheckoutDialog,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
