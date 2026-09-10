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

---

## IV. KỊCH BẢN QUAY VIDEO DEMO NỘP BÀI (ĐẠT ĐIỂM 10 TỐI ĐA)

Thời lượng video đề xuất: **1 phút 30 giây đến 2 phút**.

### 🎬 Phân cảnh 1: Giới thiệu bản thân & Ứng dụng (00:00 - 00:20)
- **Thao tác:** Mở app đã chạy lên toàn màn hình.
- **Chỉ rõ:** AppBar hiển thị rõ **"SV: Phạm Trí Hiển - MSSV: 2324802010216"**.
- **Lời thoại:**
  > *"Xin chào thầy/cô, em tên là Phạm Trí Hiển, MSSV 2324802010216. Sau đây em xin demo bài tập Lab 3 môn Lập trình di động đa nền tảng về đề tài Xây dựng màn hình và triển khai điều hướng (Navigation), truyền nhận dữ liệu trong Flutter."*

### 🎬 Phân cảnh 2: Demo điều hướng `MaterialPageRoute` & Truyền dữ liệu đi (00:20 - 00:45)
- **Thao tác:**
  - Nhấp chuột vào thẻ sản phẩm **iPhone 16 Pro Max 256GB**.
  - Quan sát hiệu ứng `Hero Animation` mượt mà khi biểu tượng điện thoại chuyển từ danh sách sang chi tiết.
- **Lời thoại:**
  > *"Ở màn hình chính, khi em nhấn vào sản phẩm iPhone 16 Pro Max, ứng dụng sử dụng MaterialPageRoute để điều hướng sang ProductDetailScreen. Đồng thời đối tượng sản phẩm được truyền sang để hiển thị đầy đủ thông số kỹ thuật, giá bán và đánh giá."*

### 🎬 Phân cảnh 3: Demo nhận dữ liệu trả về khi `pop` (Backward Data Passing) (00:45 - 01:05)
- **Thao tác:**
  - Tại màn hình chi tiết, nhấn vào nút biểu tượng **Trái tim (Yêu thích)** trên AppBar -> Icon chuyển sang màu đỏ rực.
  - Tăng số lượng lên 2.
  - Bấm nút **Quay lại (Back)** ở góc trên bên trái.
  - Quan sát tại màn hình chính: Trái tim của iPhone 16 Pro Max đã được tự động đồng bộ sang màu đỏ.
- **Lời thoại:**
  > *"Khi em bấm nút yêu thích và nhấn Back quay lại, màn hình chi tiết đã dùng Navigator.pop(context, result) để trả dữ liệu về. Màn hình danh sách dùng await để nhận kết quả và setState cập nhật trạng thái yêu thích ngay tức thì."*

### 🎬 Phân cảnh 4: Demo điều hướng `Named Route` (`/cart`) & Đặt hàng (01:05 - 01:35)
- **Thao tác:**
  - Bấm nút icon **ℹ (Info)** của sản phẩm Sony WH-1000XM5 -> demo gọi qua `Navigator.pushNamed('/detail', arguments: ...)`.
  - Nhấn nút **"Thêm vào giỏ"** -> SnackBar hiện lên với nút "Xem giỏ hàng".
  - Quay lại màn hình chính, nhấn icon Giỏ hàng trên AppBar (có badge hiển thị số 2) -> App chuyển sang màn hình `/cart` bằng `Navigator.pushNamed('/cart')`.
  - Nhấn nút **"Xác nhận đặt hàng"** -> Hộp thoại `AlertDialog` hiển thị thông tin khách hàng: **Phạm Trí Hiển - 2324802010216**.
  - Nhấn **Xác nhận thanh toán** -> Màn hình pop quay lại trang chủ và hiển thị SnackBar chúc mừng đặt hàng thành công màu xanh lá.
- **Lời thoại:**
  > *"Tiếp theo là kỹ thuật Named Routes: Route /cart được khai báo trong MaterialApp. Màn hình Giỏ hàng quản lý số lượng và tính toán tổng tiền VND. Khi nhấn Xác nhận thanh toán, hộp thoại hiển thị tên và MSSV của em, sau đó pop quay về trang chủ với SnackBar xác nhận."*

### 🎬 Phân cảnh 5: Kết luận (01:35 - 01:45)
- **Lời thoại:**
  > *"Ứng dụng đáp ứng đầy đủ các tiêu chí của Lab 3: Navigator, MaterialPageRoute, Named Routes, truyền nhận dữ liệu 2 chiều và giao diện responsive mượt mà. Em xin chân thành cảm ơn thầy/cô đã theo dõi."*

---

## V. CÁC BƯỚC ĐẨY CODE LÊN GITHUB & NỘP BÀI

### Bước 1: Đẩy mã nguồn lên GitHub
Mở Terminal tại thư mục này và chạy các lệnh sau:
```bash
git init
git add .
git commit -m "Hoàn thành Lab 3: Flutter Navigation, MaterialPageRoute, Named Routes - Phạm Trí Hiển - 2324802010216"
git branch -M main
git remote add origin https://github.com/PhamTriHien/2324802010216_PhamTriHien_Lab3.git
git push -u origin main
```

### Bước 2: Tải video lên YouTube
1. Quay video theo kịch bản ở Mục IV (dùng phím tắt `Windows + Alt + R` hoặc OBS).
2. Vào [YouTube Studio](https://studio.youtube.com) -> Nhấn **Tải video lên**.
3. Tiêu đề: `[LTDDĐNT] Lab 3 - Flutter Navigation - Phạm Trí Hiển - 2324802010216`.
4. Chế độ hiển thị: Chọn **Không công khai (Unlisted)** hoặc **Công khai (Public)**.
5. Sao chép đường link YouTube.

### Bước 3: Nộp bài lên Elearning
1. Mở file `nop_bai_lab3.txt` trong thư mục này.
2. Dán link video YouTube vào dòng tương ứng.
3. Nộp file `nop_bai_lab3.txt` lên hệ thống Elearning của trường.
