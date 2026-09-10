import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';

/// Màn hình Chi tiết Sản phẩm (ProductDetailScreen)
/// Minh họa:
/// - Tiếp nhận dữ liệu truyền sang (hỗ trợ cả Constructor và ModalRoute arguments)
/// - Hiệu ứng chuyển động mượt mà bằng Widget Hero
/// - Trả dữ liệu kết quả ngược lại cho màn hình trước qua Navigator.pop(context, result)
/// - Điều hướng tiếp sang màn hình Giỏ hàng qua Named Route '/cart'
class ProductDetailScreen extends StatefulWidget {
  final Product? product;
  final Function(Product, int)? onAddToCart;

  const ProductDetailScreen({
    super.key,
    this.product,
    this.onAddToCart,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _currentProduct;
  int _quantity = 1;
  late bool _isFavorite;
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // Khởi tạo ban đầu nếu dữ liệu được truyền qua Constructor
    if (widget.product != null) {
      _currentProduct = widget.product!;
      _isFavorite = _currentProduct.isFavorite;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nếu widget.product null, lấy dữ liệu từ Named Route arguments
    if (widget.product == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Product) {
        _currentProduct = args;
        _isFavorite = _currentProduct.isFavorite;
      }
    }
  }

  /// Trả dữ liệu cập nhật về màn hình danh sách khi nhấn nút Quay lại
  void _handleBack() {
    Navigator.pop(context, {
      'productId': _currentProduct.id,
      'isFavorite': _isFavorite,
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            _currentProduct.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            tooltip: 'Quay lại danh sách',
            onPressed: _handleBack,
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.redAccent : null,
              ),
              tooltip: _isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
              onPressed: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isFavorite
                          ? 'Đã thêm vào danh sách yêu thích!'
                          : 'Đã xóa khỏi danh sách yêu thích!',
                    ),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: 'Xem giỏ hàng',
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Ảnh/Biểu tượng sản phẩm với Hero Animation
              Center(
                child: Hero(
                  tag: 'product_hero_${_currentProduct.id}',
                  child: Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _currentProduct.themeColor.withAlpha(60),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _currentProduct.imageUrl != null &&
                            _currentProduct.imageUrl!.isNotEmpty
                        ? Image.network(
                            _currentProduct.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: _currentProduct.themeColor.withAlpha(25),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: _currentProduct.themeColor.withAlpha(25),
                                child: Center(
                                  child: Icon(
                                    _currentProduct.icon,
                                    size: 130,
                                    color: _currentProduct.themeColor,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: _currentProduct.themeColor.withAlpha(25),
                            child: Center(
                              child: Icon(
                                _currentProduct.icon,
                                size: 130,
                                color: _currentProduct.themeColor,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 2. Phân loại & Tình trạng kho
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_currentProduct.brand} • ${_currentProduct.category}',
                      style: TextStyle(
                        color: Colors.indigo.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 16, color: Colors.green.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Còn ${_currentProduct.stock} sản phẩm',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Tên sản phẩm
              Text(
                _currentProduct.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),

              // 4. Đánh giá sao
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${_currentProduct.rating}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${_currentProduct.reviewCount} đánh giá từ khách hàng)',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 5. Giá bán & Giảm giá
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Giá bán chính hãng:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _currencyFormat.format(_currentProduct.price),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (_currentProduct.discountPercent > 0) ...[
                      Text(
                        _currencyFormat.format(_currentProduct.originalPrice),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${_currentProduct.discountPercent}%',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 6. Chọn số lượng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Số lượng mua:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: _quantity < _currentProduct.stock
                              ? () => setState(() => _quantity++)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 7. Thông số kỹ thuật
              const Text(
                'Thông số kỹ thuật nổi bật',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _currentProduct.specifications.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final key =
                        _currentProduct.specifications.keys.elementAt(index);
                    final value = _currentProduct.specifications[key]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              key,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 8. Mô tả chi tiết
              const Text(
                'Mô tả sản phẩm',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  _currentProduct.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 80), // Chừa khoảng cách cho thanh đáy
            ],
          ),
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: Row(
              children: [
                // Nút Thêm vào giỏ
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.indigo.shade600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add_shopping_cart, size: 20),
                    label: const Text(
                      'Thêm vào giỏ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (widget.onAddToCart != null) {
                        widget.onAddToCart!(_currentProduct, _quantity);
                      }
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã thêm $_quantity x ${_currentProduct.name} vào giỏ hàng!',
                          ),
                          action: SnackBarAction(
                            label: 'XEM GIỎ HÀNG',
                            textColor: Colors.amberAccent,
                            onPressed: () {
                              Navigator.pushNamed(context, '/cart');
                            },
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Nút Mua ngay
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.indigo.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (widget.onAddToCart != null) {
                        widget.onAddToCart!(_currentProduct, _quantity);
                      }
                      // Chuyển ngay đến màn hình Giỏ hàng qua Named Route
                      Navigator.pushNamed(context, '/cart');
                    },
                    child: const Text(
                      'Mua ngay',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
