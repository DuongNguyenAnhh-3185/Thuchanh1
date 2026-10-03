# Checklist chất lượng yêu cầu

## Bao phủ mã yêu cầu

- [x] Tất cả yêu cầu chức năng có ID dạng `REQ-XXX`.
- [x] ID duy nhất, liên tục từ `REQ-001` đến `REQ-009`.

## Khả năng kiểm thử

- [x] Các yêu cầu có hành vi quan sát được.
- [x] Mỗi user story có kịch bản Given–When–Then.
- [x] Có luồng thành công, dữ liệu không hợp lệ, hủy xóa và lỗi lưu trữ.

## Đầy đủ

- [x] Phạm vi, nhóm chức năng và ngoài phạm vi được ghi rõ.
- [x] User story được ưu tiên P1/P2.
- [x] Bao phủ tạo, đọc, tìm kiếm, sửa, xóa và yêu thích.
- [x] Có tiêu chí thành công định lượng, kiểm chứng được.
- [x] Có DFD mức 0 và mức 1 cùng đối chiếu với thành phần hiện tại.

## Nhất quán kiến trúc

- [x] DFD phân biệt tác nhân, tiến trình, kho dữ liệu và dòng dữ liệu.
- [x] Không đưa chi tiết lưu trữ vật lý vào luồng nghiệp vụ cốt lõi.
- [x] Giới hạn hiện tại của link/file được nêu rõ, không coi là upload file.
