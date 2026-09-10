import 'package:flutter/material.dart';
import 'models/product.dart';
import 'models/sample_data.dart';
import 'screens/cart_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/product_list_screen.dart';

/// BÀI TẬP LAB 3: ĐIỀU HƯỚNG VÀ TRUYỀN NHẬN DỮ LIỆU MÀN HÌNH (FLUTTER NAVIGATION)
/// Sinh viên thực hiện: Phạm Trí Hiển
/// Mã số sinh viên: 2324802010216
/// Môn học: Lập trình di động đa nền tảng
void main() {
  runApp(const TechStoreApp());
}

class TechStoreApp extends StatefulWidget {
  const TechStoreApp({super.key});

  @override
  State<TechStoreApp> createState() => _TechStoreAppState();
}

class _TechStoreAppState extends State<TechStoreApp> {
  // Quản lý trạng thái giỏ hàng tập trung cho toàn bộ ứng dụng
  final List<CartItem> _cartItems = [];
  late final List<Product> _products;

  @override
  void initState() {
    super.initState();
    _products = List.from(sampleProducts);
  }

  /// Thêm sản phẩm vào giỏ hàng
  void _addToCart(Product product, int quantity) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item.product.id == product.id);
      if (index != -1) {
        _cartItems[index].quantity += quantity;
      } else {
        _cartItems.add(CartItem(product: product, quantity: quantity));
      }
    });
  }

  /// Cập nhật số lượng của một sản phẩm trong giỏ
  void _updateQuantity(Product product, int newQuantity) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item.product.id == product.id);
      if (index != -1) {
        if (newQuantity <= 0) {
          _cartItems.removeAt(index);
        } else {
          _cartItems[index].quantity = newQuantity;
        }
      }
    });
  }

  /// Xóa sản phẩm khỏi giỏ hàng
  void _removeFromCart(Product product) {
    setState(() {
      _cartItems.removeWhere((item) => item.product.id == product.id);
    });
  }

  /// Xóa sạch giỏ hàng khi đặt hàng thành công
  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechStore - Lab 3 - Phạm Trí Hiển - 2324802010216',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo.shade700,
          secondary: Colors.amber.shade700,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),

      // Route khởi động đầu tiên
      initialRoute: '/',

      // [KỸ THUẬT QUẢN LÝ ROUTES TĨNH VÀ ĐỘNG THEO GIÁO TRÌNH CHƯƠNG 3]
      // Khai báo bảng routes tĩnh
      routes: {
        '/': (context) => ProductListScreen(
              initialProducts: _products,
              initialCart: _cartItems,
              onAddToCartGlobal: _addToCart,
              onClearCartGlobal: _clearCart,
            ),
        '/cart': (context) => CartScreen(
              cartItems: _cartItems,
              onClearCart: _clearCart,
              onRemoveItem: _removeFromCart,
              onUpdateQuantity: _updateQuantity,
            ),
      },

      // Xử lý Route động với onGenerateRoute để bóc tách tham số linh hoạt
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/detail') {
          // Lấy đối tượng Product truyền qua arguments
          final product = settings.arguments as Product?;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: product,
              onAddToCart: _addToCart,
            ),
            settings: settings,
          );
        }

        // Mặc định trả về màn hình chính nếu không khớp route
        return MaterialPageRoute(
          builder: (context) => ProductListScreen(
            initialProducts: _products,
            initialCart: _cartItems,
            onAddToCartGlobal: _addToCart,
            onClearCartGlobal: _clearCart,
          ),
        );
      },
    );
  }
}
