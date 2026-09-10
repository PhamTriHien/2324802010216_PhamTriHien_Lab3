# BÀI TẬP LAB 3: ĐIỀU HƯỚNG MÀN HÌNH & TRUYỀN DỮ LIỆU (FLUTTER NAVIGATION)

- **Môn học:** Lập trình di động đa nền tảng (LING190)
- **Sinh viên:** Phạm Trí Hiển
- **Mã số sinh viên (MSSV):** 2324802010216
- **Đề tài ứng dụng:** Ứng dụng Cửa hàng thiết bị công nghệ **TechStore**
- **Github Repository:** [https://github.com/PhamTriHien/2324802010216_PhamTriHien_Lab3.git](https://github.com/PhamTriHien/2324802010216_PhamTriHien_Lab3.git)

---

## I. MỤC TIÊU & CÁC KỸ THUẬT NAVIGATION ĐÃ TRIỂN KHAI

Ứng dụng đáp ứng và vượt trên yêu cầu đề bài (tối thiểu 2 màn hình), xây dựng hoàn chỉnh **3 màn hình tương tác thực tế** với kiến trúc phân tách rõ ràng theo chuẩn Flutter:

```
[ProductListScreen ('/')] ──(MaterialPageRoute / pushNamed)──► [ProductDetailScreen]
         │                ◄──(pop với dữ liệu kết quả)─────────┤
         │                                                     │
         └─────────────(Named Route '/cart')───────────────────┴──► [CartScreen ('/cart')]
```

### 1. `MaterialPageRoute` (Điều hướng trực tiếp)
- **Áp dụng:** Khi người dùng chạm vào một thẻ sản phẩm bất kỳ trên `ProductListScreen`.
- **Cách thức:** Khởi tạo trang mục tiêu bằng `MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))`.
- **Dẫn chứng code:**
  ```dart
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductDetailScreen(
        product: product,
        onAddToCart: widget.onAddToCartGlobal,
      ),
    ),
  );
  ```

### 2. `Named Routes` (Định tuyến theo tên)
- **Áp dụng:** Định nghĩa các đường dẫn cố định trong `MaterialApp` thông qua thuộc tính `routes` và xử lý động qua `onGenerateRoute`.
  - `'/'`: Màn hình danh sách sản phẩm (`ProductListScreen`).
  - `'/cart'`: Màn hình giỏ hàng và thanh toán (`CartScreen`).
  - `'/detail'`: Màn hình chi tiết sản phẩm nhận đối tượng `Product` qua `RouteSettings.arguments`.
- **Dẫn chứng code đăng ký routes trong `lib/main.dart`:**
  ```dart
  MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => ProductListScreen(...),
      '/cart': (context) => CartScreen(...),
    },
    onGenerateRoute: (RouteSettings settings) {
      if (settings.name == '/detail') {
        final product = settings.arguments as Product?;
        return MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
          settings: settings,
        );
      }
      return null;
    },
  );
  ```
- **Dẫn chứng code gọi điều hướng theo tên:**
  ```dart
  // Điều hướng đến chi tiết sản phẩm kèm arguments
  Navigator.pushNamed(context, '/detail', arguments: product);

  // Điều hướng đến giỏ hàng
  Navigator.pushNamed(context, '/cart');
  ```

### 3. Truyền dữ liệu 2 chiều (Forward Passing & Returning Data)
- **Truyền dữ liệu đi (Forward):** Truyền đối tượng `Product` đầy đủ (tên, giá, thông số, trạng thái yêu thích) từ màn hình danh sách sang màn hình chi tiết.
- **Tiếp nhận dữ liệu trả về (Backward Pop):** Khi người dùng thay đổi trạng thái yêu thích ở `ProductDetailScreen` rồi bấm Quay lại (Back), màn hình chi tiết trả về kết quả qua `Navigator.pop(context, {'productId': ..., 'isFavorite': ...})`. Màn hình danh sách dùng từ khóa `await` để đón kết quả và cập nhật giao diện bằng `setState()` ngay tức thì mà không cần tải lại toàn trang.

### 4. Hiệu ứng chuyển cảnh mượt mà (`Hero Animation`)
- Sử dụng cặp widget `Hero(tag: 'product_hero_${product.id}')` cho biểu tượng sản phẩm giữa `ProductListScreen` và `ProductDetailScreen`. Khi chuyển trang, hình ảnh sản phẩm phóng to/thu nhỏ lướt bay mượt mà, tạo cảm giác chuyên nghiệp cao cấp.

---

## II. DANH SÁCH CÁC MÀN HÌNH TRONG ỨNG DỤNG

### 1. Màn hình 1: Danh sách sản phẩm (`ProductListScreen`)
- **Header:** Hiển thị tên app, tên sinh viên và MSSV: **`SV: Phạm Trí Hiển - MSSV: 2324802010216`**.
- **Badge Giỏ hàng:** Hiển thị số lượng món hàng trong giỏ thời gian thực.
- **Thanh tìm kiếm:** Tìm kiếm sản phẩm theo tên hoặc hãng sản xuất.
- **Thanh phân loại:** Các chip danh mục ngang (Tất cả, Điện thoại, Laptop, Âm thanh, Đồng hồ, Máy tính bảng, Phụ kiện).
- **Lưới sản phẩm responsive:** Card thông tin sản phẩm, giá bán VND định dạng chuẩn, mức giảm giá, đánh giá sao, nút yêu thích trực tiếp và nút thêm nhanh vào giỏ.

### 2. Màn hình 2: Chi tiết sản phẩm (`ProductDetailScreen`)
- **Hiệu ứng Hero:** Phóng to biểu tượng sản phẩm mượt mà.
- **Thông tin chi tiết:** Thương hiệu, số lượng tồn kho, giá bán chính hãng, giá gốc gạch ngang, phần trăm giảm giá.
- **Bộ tăng giảm số lượng mua:** Nút `+` và `-` kiểm soát tồn kho.
- **Bảng thông số kỹ thuật:** Bảng hiển thị CPU, RAM, Màn hình, Dung lượng pin, v.v.
- **Nút Yêu thích:** Bấm để đổi trạng thái và gửi kết quả về trang trước.
- **Thanh tác vụ đáy (Bottom Bar):** Nút *Thêm vào giỏ* và nút *Mua ngay* (chuyển thẳng sang Giỏ hàng).

### 3. Màn hình 3: Giỏ hàng & Thanh toán (`CartScreen`)
- Quản lý danh sách sản phẩm trong giỏ: tăng/giảm số lượng hoặc xóa từng món.
- Nút xóa toàn bộ giỏ hàng với hộp thoại xác nhận.
- Trạng thái giỏ hàng rỗng (Empty State) thân thiện, có nút quay về mua sắm.
- Bảng tính tiền tự động: Tạm tính, Ưu đãi thành viên SV (5%), Tổng thanh toán VND.
- Hộp thoại xác nhận đặt hàng (`AlertDialog`) hiển thị tên người nhận **Phạm Trí Hiển - 2324802010216**.

---

## III. HƯỚNG DẪN CÀI ĐẶT & CHẠY ỨNG DỤNG

### Cách 1: Chạy trực tiếp từ Visual Studio Code
1. Mở thư mục `2324802010216_PhamTriHien_Lab3` trong VS Code.
2. Mở file `lib/main.dart`.
3. Nhìn góc dưới bên phải thanh trạng thái để chọn thiết bị mục tiêu (chọn **Windows (desktop)** hoặc **Edge (web)**).
4. Nhấn phím `F5` (hoặc vào menu **Run -> Start Debugging**) để khởi chạy.

### Cách 2: Chạy bằng dòng lệnh (Terminal / PowerShell)
```powershell
# Di chuyển vào thư mục dự án
cd C:\baiTap_LTDiDongDaNenTang\2324802010216_PhamTriHien_Lab3

# Tải dependencies
flutter pub get

# Kiểm tra cú pháp (đạt 0 lỗi, 0 cảnh báo)
flutter analyze

# Chạy bộ test tự động (3/3 test passed)
flutter test

# Khởi chạy trên Edge (web)
flutter run -d edge

# Hoặc khởi chạy trên Windows desktop
flutter run -d windows
```
