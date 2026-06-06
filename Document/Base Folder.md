lib/
├── core/                       # Lõi của app: Những thứ dùng chung và RẤT ÍT KHI THAY ĐỔI
│   ├── constants/              # Hằng số: colors.dart, styles.dart, api_endpoints.dart
│   ├── errors/                 # Xử lý lỗi: exceptions.dart, failure.dart
│   ├── network/                # Cấu hình gọi API chung: dio_client.dart hoặc http_client.dart
│   └── utils/                  # Hàm tiện ích: formatters.dart (format ngày tháng, tiền tệ), validators.dart
│
├── shared/                     # Những phần dùng chung cho nhiều tính năng
│   ├── models/                 # Model dùng chung (vd: user_model.dart, pagination_model.dart)
│   └── widgets/                # UI Component dùng chung: custom_button.dart, custom_text_field.dart, loading_overlay.dart
│
├── features/                   # CHIA THEO TÍNH NĂNG (Nơi 2 bạn sẽ code chính)
│   │
│   ├── auth/                   # --- Tính năng Đăng nhập --- (Ví dụ: Bạn A làm)
│   │   ├── models/             # Chứa model riêng: login_request_model.dart, auth_response.dart
│   │   ├── services/           # Gọi API: auth_api_service.dart, auth_local_service.dart (lưu token)
│   │   ├── providers/          # State Management: auth_provider.dart (hoặc auth_bloc/auth_controller)
│   │   └── screens/            # Màn hình: login_screen.dart, splash_screen.dart
│   │
│   ├── inventory/              # --- Tính năng Kiểm kê kho --- (Ví dụ: Bạn B làm)
│   │   ├── models/             # inventory_session_model.dart, product_item_model.dart
│   │   ├── services/           # Gọi API và Local Db (Offline): inventory_api_service.dart, sqlite_service.dart
│   │   ├── providers/          # State logic: inventory_provider.dart (Xử lý logic so sánh lệch tồn)
│   │   ├── widgets/            # Widget chỉ dùng trong kiểm kê: inventory_item_card.dart
│   │   └── screens/            # Màn hình: inventory_list_screen.dart, inventory_detail_screen.dart
│   │
│   ├── scanner/                # --- Tính năng Quét mã --- (Bạn A làm)
│   │   ├── services/           # Xử lý logic giải mã Barcode/QR
│   │   └── screens/            # scanner_screen.dart
│   │
│   ├── products/               # --- Tính năng Tra cứu sản phẩm --- (Bạn B làm)
│   │   ├── models/             # product_detail_model.dart
│   │   ├── services/           # product_api_service.dart
│   │   └── screens/            # product_list_screen.dart, product_detail_screen.dart
│   │
│   └── profile/                # --- Tính năng Cá nhân & Cài đặt --- (Bạn A làm)
│       ├── services/           # Xử lý đổi mật khẩu, đăng xuất...
│       └── screens/            # profile_screen.dart, settings_screen.dart
│
└── main.dart                   # Nơi khởi tạo app, khai báo Providers, setup Navigation/Routes



Cách phối hợp công việc hiệu quả trên cấu trúc này:
Phân chia thư mục trong features/:

Bạn A nhận: auth, scanner, profile. Bạn A sẽ chỉ thao tác trong các folder này, tự định nghĩa models, services, và screens của mình.
Bạn B nhận: inventory, products. Bạn B sẽ lo toàn bộ API, Logic và giao diện nằm gọn trong folder đó.
Lợi ích: Khi gộp code (merge Git), file của ai người nấy sửa, tỷ lệ bị lỗi đụng code (conflict) gần như bằng 0.
Cách làm việc với thư mục shared/ và core/:

Đây là vùng dùng chung. Trước khi một người tạo một UI Component mới (ví dụ một cái nút bấm đặc biệt) hoặc sửa cấu hình gọi API, hãy báo với người kia để gộp vào thư mục shared/widgets/ hoặc core/network/ cho cả 2 cùng dùng lại.
Luồng làm việc cho 1 tính năng (ví dụ tính năng Kiểm kê - inventory):

Bước 1 (Models): Nhìn vào JSON API Backend trả về, tạo các file .dart trong inventory/models/.
Bước 2 (Services): Tạo inventory_api_service.dart trong inventory/services/ để viết các hàm get, post gọi Backend, truyền tham số và trả về Models.
Bước 3 (Providers/State): Tạo logic trong inventory/providers/ để gọi hàm từ Services, xử lý dữ liệu, báo trạng thái Loading/Success/Error.
Bước 4 (Screens): Vẽ UI trong inventory/screens/ và liên kết với dữ liệu từ Providers.