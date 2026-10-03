# Cashew Study Hub

Ứng dụng quản lý tài liệu học tập theo kiến trúc Cashew, xây dựng trên Flutter với ba lớp `presentation`, `domain` và `data`.

## Tính năng
- CRUD tài liệu học tập: tạo, xem, chỉnh sửa và xóa có xác nhận
- Tìm kiếm theo tên, loại, định dạng và môn học
- Chuyển đổi giữa Bài giảng, Bài tập và Tài liệu tham khảo
- Gắn/bỏ dấu sao tài liệu yêu thích
- Lưu dữ liệu cục bộ bằng SQLite (SQLite FFI trên desktop)
- Trường Link/File lưu URL hoặc đường dẫn tệp do người dùng nhập

## Kiến trúc
Xem chi tiết trong [ARCHITECTURE.md](ARCHITECTURE.md).

## Chạy ứng dụng
```bash
flutter pub get
flutter test
flutter run
```
