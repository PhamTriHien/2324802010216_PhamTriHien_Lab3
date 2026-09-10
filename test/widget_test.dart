import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab3_navigation_app/main.dart';

void main() {
  testWidgets('Kiểm thử khởi chạy ứng dụng TechStore và hiển thị thông tin SV',
      (WidgetTester tester) async {
    // 1. Khởi chạy ứng dụng
    await tester.pumpWidget(const TechStoreApp());
    await tester.pumpAndSettle();

    // 2. Kiểm tra thông tin sinh viên trên AppBar
    expect(find.text('Phạm Trí Hiển - 2324802010216'), findsOneWidget);

    // 3. Kiểm tra danh sách sản phẩm mẫu đã hiển thị
    expect(find.text('iPhone 16 Pro Max 256GB'), findsOneWidget);
    expect(find.text('MacBook Pro 14" M3 Pro'), findsOneWidget);
  });

  testWidgets('Kiểm thử điều hướng MaterialPageRoute từ Danh sách sang Chi tiết',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TechStoreApp());
    await tester.pumpAndSettle();

    // Tìm và nhấn vào sản phẩm iPhone 16 Pro Max để điều hướng
    final productCard = find.text('iPhone 16 Pro Max 256GB');
    expect(productCard, findsOneWidget);
    await tester.tap(productCard);
    await tester.pumpAndSettle();

    // Xác nhận đã điều hướng sang màn hình Chi tiết sản phẩm
    expect(find.text('Thông số kỹ thuật nổi bật'), findsOneWidget);
    expect(find.text('Thêm vào giỏ'), findsOneWidget);
    expect(find.text('Mua ngay'), findsOneWidget);

    // Bấm nút quay lại (pop)
    final backButton = find.byTooltip('Quay lại danh sách');
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // Xác nhận đã quay về màn hình chính
    expect(find.text('Phạm Trí Hiển - 2324802010216'), findsOneWidget);
  });

  testWidgets('Kiểm thử điều hướng Named Route sang màn hình Giỏ hàng /cart',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TechStoreApp());
    await tester.pumpAndSettle();

    // Nhấn vào icon Giỏ hàng trên AppBar
    final cartButton = find.byIcon(Icons.shopping_cart_outlined);
    expect(cartButton, findsOneWidget);
    await tester.tap(cartButton);
    await tester.pumpAndSettle();

    // Xác nhận đã chuyển sang trang Giỏ hàng
    expect(find.text('Giỏ hàng công nghệ'), findsOneWidget);
    expect(find.text('Giỏ hàng của bạn đang trống!'), findsOneWidget);

    // Bấm nút "Tiếp tục mua sắm" để quay lại
    final continueShoppingBtn = find.text('Tiếp tục mua sắm');
    expect(continueShoppingBtn, findsOneWidget);
    await tester.tap(continueShoppingBtn);
    await tester.pumpAndSettle();

    // Xác nhận đã quay lại màn hình chính
    expect(find.text('Phạm Trí Hiển - 2324802010216'), findsOneWidget);
  });
}
