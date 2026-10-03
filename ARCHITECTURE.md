# Cashew Study Hub — kiến trúc phân lớp

Ứng dụng dùng feature `study documents` với ba lớp độc lập. Mọi thao tác đọc,
tạo, sửa và xóa từ UI đều đi qua controller rồi domain use case; chỉ lớp data
được phép truy cập SQLite.

```text
presentation (pages, controller)
            ↓
domain (entities, use cases, repository contract)
            ↑
data (SQLite datasource, repository implementation)
```

## Thư mục

- `lib/presentation/`: màn hình danh sách/form và `DocumentListController`
  quản lý loading, lỗi, tìm kiếm và cập nhật UI.
- `lib/domain/`: `StudyDocument`, hợp đồng `DocumentRepository` và các use case
  CRUD/tìm kiếm. Không phụ thuộc Flutter hoặc SQLite.
- `lib/data/`: `AppDatabase` tạo SQLite; `SqliteDocumentRepository` dùng trên
  mobile/desktop và `PreferencesDocumentRepository` lưu JSON bằng browser
  localStorage trên Flutter Web, cùng hiện thực hợp đồng domain.
- `lib/main.dart`: composition root khởi tạo DB, nối implementation với use case
  và controller.

## Lưu trữ và dữ liệu

SQLite được dùng trên Android/iOS và SQLite FFI trên Windows/Linux/macOS.
Flutter Web dùng browser localStorage do sqflite không hỗ trợ nền tảng web. Cơ
sở dữ liệu tạo bảng / khởi tạo dữ liệu mẫu khi chạy lần đầu. Trường Link/File
lưu chuỗi URL hoặc đường dẫn mà người dùng nhập; ứng dụng chưa upload hoặc mở
file.

## Luồng CRUD

`StudyHomePage` → `DocumentListController` → domain use case →
`DocumentRepository` → `SqliteDocumentRepository` → SQLite.

Tìm kiếm được xử lý trong domain theo tên, loại tài liệu, định dạng và môn học.
Repository có thể được thay bằng API hoặc Firebase mà không cần sửa UI/use case.

## Kiểm thử ranh giới phân lớp

`flutter test` bao gồm:

- `test/architecture_boundaries_test.dart`: kiểm tra domain không phụ thuộc
  framework/persistence hoặc tầng khác; presentation không import data; data
  không import presentation.
- `test/domain/document_use_cases_test.dart`: kiểm tra tìm kiếm và xác nhận các
  use case chuyển tiếp CRUD qua repository contract.
- Các test repository: kiểm tra SQLite và Web storage thực hiện hợp đồng CRUD.
- `test/widget_test.dart`: kiểm tra luồng giao diện tạo, tìm, sửa và xóa đi qua
  controller/domain tới repository giả.

Thay đổi import làm đảo chiều phụ thuộc sẽ khiến test ranh giới thất bại.
