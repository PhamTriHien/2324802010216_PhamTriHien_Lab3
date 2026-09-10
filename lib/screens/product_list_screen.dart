import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/sample_data.dart';
import 'product_detail_screen.dart';

/// Màn hình Danh sách Sản phẩm (ProductListScreen)
/// Màn hình gốc (Home Route: '/')
/// Minh họa:
/// - Điều hướng bằng MaterialPageRoute (truyền object Product và đón kết quả await pop)
/// - Điều hướng bằng Named Route ('/detail', '/cart')
/// - Truyền dữ liệu đi (Forward) và tiếp nhận dữ liệu trả về (Backward pop)
/// - Hero animation chuyển tiếp mượt mà sang trang chi tiết
class ProductListScreen extends StatefulWidget {
  final List<Product>? initialProducts;
  final List<CartItem>? initialCart;
  final Function(Product, int)? onAddToCartGlobal;
  final VoidCallback? onClearCartGlobal;

  const ProductListScreen({
    super.key,
    this.initialProducts,
    this.initialCart,
    this.onAddToCartGlobal,
    this.onClearCartGlobal,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late List<Product> _products;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  String _searchKeyword = '';

  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  final List<String> _categories = [
    'Tất cả',
    'Điện thoại',
    'Laptop',
    'Âm thanh',
    'Đồng hồ',
    'Máy tính bảng',
    'Phụ kiện',
  ];

  @override
  void initState() {
    super.initState();
    _products = widget.initialProducts ?? List.from(sampleProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Lọc sản phẩm theo danh mục và từ khóa tìm kiếm
  List<Product> get _filteredProducts {
    return _products.where((item) {
      final matchCategory =
          _selectedCategory == 'Tất cả' || item.category == _selectedCategory;
      final matchSearch = item.name
              .toLowerCase()
              .contains(_searchKeyword.toLowerCase()) ||
          item.brand.toLowerCase().contains(_searchKeyword.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  /// Tổng số lượng món hàng trong giỏ
  int get _totalCartCount {
    final cart = widget.initialCart ?? [];
    return cart.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Đổi trạng thái yêu thích của sản phẩm theo id
  void _toggleFavorite(String productId) {
    setState(() {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = _products[index].copyWith(
          isFavorite: !_products[index].isFavorite,
        );
      }
    });
  }

  /// Cập nhật kết quả trả về từ màn hình chi tiết (Pop Result)
  void _handleDetailReturn(dynamic result) {
    if (result != null && result is Map) {
      final productId = result['productId'] as String?;
      final isFav = result['isFavorite'] as bool?;
      if (productId != null && isFav != null) {
        setState(() {
          final index = _products.indexWhere((p) => p.id == productId);
          if (index != -1 && _products[index].isFavorite != isFav) {
            _products[index] = _products[index].copyWith(isFavorite: isFav);
          }
        });
      }
    }
  }

  /// [KỸ THUẬT 1]: Điều hướng bằng MaterialPageRoute & Nhận kết quả trả về
  Future<void> _navigateToDetailWithPageRoute(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: product,
          onAddToCart: widget.onAddToCartGlobal,
        ),
      ),
    );

    // Xử lý kết quả trả về từ màn hình chi tiết
    _handleDetailReturn(result);
  }

  /// [KỸ THUẬT 2]: Điều hướng bằng Named Route ('/detail') & Truyền arguments
  Future<void> _navigateToDetailWithNamedRoute(Product product) async {
    final result = await Navigator.pushNamed(
      context,
      '/detail',
      arguments: product,
    );

    // Xử lý kết quả trả về từ màn hình chi tiết
    _handleDetailReturn(result);
  }

  /// [KỸ THUẬT 3]: Điều hướng sang màn hình Giỏ hàng qua Named Route ('/cart')
  Future<void> _navigateToCart() async {
    final result = await Navigator.pushNamed(context, '/cart');
    if (result == 'CHECKOUT_SUCCESS') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đặt hàng thành công! Cảm ơn bạn đã mua sắm tại TechStore.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TechStore - Lab 3 Navigation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'SV: Phạm Trí Hiển - MSSV: 2324802010216',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          // Nút xem giỏ hàng kèm Badge số lượng
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Badge(
              label: Text('$_totalCartCount'),
              isLabelVisible: _totalCartCount > 0,
              backgroundColor: Colors.redAccent,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: 'Giỏ hàng ($_totalCartCount sản phẩm)',
                onPressed: _navigateToCart,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm và ghi chú minh họa kỹ thuật
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm, thương hiệu...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchKeyword.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchKeyword = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchKeyword = val;
                    });
                  },
                ),
                const SizedBox(height: 8),
                // Thanh thông báo hướng dẫn trải nghiệm 2 phương thức điều hướng
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo.shade100),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.indigo),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Chạm thẻ: MaterialPageRoute | Bấm icon ℹ: Named Route',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.indigo,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bộ lọc danh mục (Horizontal ListView)
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: Colors.indigo.shade600,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  showCheckmark: false,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Lưới hiển thị danh sách sản phẩm
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'Không tìm thấy sản phẩm phù hợp!',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vui lòng thử từ khóa hoặc chọn danh mục khác.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive: 2 cột trên điện thoại, 3 cột trên tablet/desktop rộng
                      final crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;

                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              // Chạm vào thẻ sản phẩm -> Mở qua MaterialPageRoute
                              onTap: () =>
                                  _navigateToDetailWithPageRoute(product),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Khung hình ảnh/icon kèm nút Favorite & Tag giảm giá
                                  Stack(
                                    children: [
                                      Container(
                                        height: 130,
                                        width: double.infinity,
                                        color: product.themeColor.withAlpha(25),
                                        child: Center(
                                          child: Hero(
                                            tag:
                                                'product_hero_${product.id}',
                                            child: Icon(
                                              product.icon,
                                              size: 64,
                                              color: product.themeColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Nút yêu thích
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.white70,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: Icon(
                                              product.isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: product.isFavorite
                                                  ? Colors.redAccent
                                                  : Colors.grey.shade600,
                                              size: 18,
                                            ),
                                            tooltip: 'Yêu thích',
                                            onPressed: () =>
                                                _toggleFavorite(product.id),
                                          ),
                                        ),
                                      ),
                                      // Tag giảm giá
                                      if (product.discountPercent > 0)
                                        Positioned(
                                          top: 6,
                                          left: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.redAccent,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '-${product.discountPercent}%',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  // Nội dung thông tin sản phẩm
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${product.brand} • ${product.category}',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                product.name,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  height: 1.2,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star,
                                                      size: 14,
                                                      color: Colors.amber),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    '${product.rating}',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '(${product.reviewCount})',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          // Giá bán và nút điều hướng Named Route
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _currencyFormat
                                                          .format(product.price),
                                                      style: const TextStyle(
                                                        color: Colors.redAccent,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    if (product.discountPercent >
                                                        0)
                                                      Text(
                                                        _currencyFormat.format(
                                                            product
                                                                .originalPrice),
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade400,
                                                          fontSize: 10,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              // Nút icon Info -> minh họa Named Route
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.info_outline,
                                                    size: 20),
                                                tooltip:
                                                    'Xem chi tiết (Named Route)',
                                                color: Colors.indigo.shade700,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed: () =>
                                                    _navigateToDetailWithNamedRoute(
                                                        product),
                                              ),
                                              const SizedBox(width: 4),
                                              // Nút thêm nhanh vào giỏ
                                              InkWell(
                                                onTap: () {
                                                  if (widget
                                                          .onAddToCartGlobal !=
                                                      null) {
                                                    widget.onAddToCartGlobal!(
                                                        product, 1);
                                                  }
                                                  ScaffoldMessenger.of(context)
                                                      .hideCurrentSnackBar();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Đã thêm 1 x ${product.name} vào giỏ!'),
                                                      duration: const Duration(
                                                          seconds: 2),
                                                      action: SnackBarAction(
                                                        label: 'GIỎ HÀNG',
                                                        textColor:
                                                            Colors.amberAccent,
                                                        onPressed:
                                                            _navigateToCart,
                                                      ),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.indigo.shade600,
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                  ),
                                                  child: const Icon(
                                                    Icons.add_shopping_cart,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
