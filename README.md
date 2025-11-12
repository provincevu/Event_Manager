# Event Manager

Ứng dụng quản lý sự kiện đa nền tảng (Android, iOS, Web, Desktop) xây dựng bằng Flutter. Hỗ trợ xem lịch với Syncfusion Calendar, tạo/chỉnh sửa/xoá sự kiện, tìm kiếm nhanh, đổi ngôn ngữ, và lọc theo nhóm sự kiện.

---

## Tóm tắt tính năng

- Cốt lõi
  - Xem lịch theo Day/Week/Month/Schedule.
  - Tạo sự kiện mới (nhấn giữ vào ô trống), chỉnh sửa/xoá sự kiện (nhấn vào sự kiện).
  - Lưu trữ cục bộ bằng Localstore.
- Tính năng nâng cao
  - Lọc theo nhóm sự kiện: lọc các sự kiện theo tag/nhóm (ví dụ: Công việc, Cá nhân, Học tập).
  - Thay đổi ngôn ngữ trong ứng dụng: chuyển nhanh giữa Tiếng Việt và English.
  - Tìm kiếm: tìm theo tiêu đề

---


## Kiến trúc và thư viện

- Flutter + Dart
- Lịch: `syncfusion_flutter_calendar`
- Lưu cục bộ: `localstore`
- Định dạng ngày giờ: `intl`
- Đa ngôn ngữ: lớp `AppLocalizations` tùy biến + chuyển đổi runtime
---

## Cách chạy

Yêu cầu:
- Flutter SDK (3.x trở lên)
- Android Studio / Xcode (tùy nền tảng)
- Dart SDK đi kèm Flutter

Bước chạy nhanh:
1. Clone
   ```bash
   git clone https://github.com/provincevu/Event_Manager.git
   cd Event_Manager
   ```
2. Cài phụ thuộc
   ```bash
   flutter pub get
   ```
3. Chạy thiết bị/simulator
   ```bash
   flutter run
   ```

---

## Hướng dẫn sử dụng

- Tạo sự kiện: nhấn giữ vào một ô trống trong lịch → mở màn “Sự kiện mới”.
- Chỉnh sửa/xoá sự kiện: nhấn vào sự kiện → mở chi tiết → Lưu/Xoá.
- Tìm kiếm: nhấn icon kính lúp → nhập từ khoá (theo tiêu đề hoặc ghi chú) → chọn kết quả để mở.
- Lọc theo nhóm:
  - Mở bộ lọc và chọn nhóm (ví dụ: Công việc, Cá nhân, Học tập).
  - Lịch sẽ chỉ hiển thị các sự kiện thuộc nhóm đã chọn.
- Đổi ngôn ngữ:
  - Nhấn icon Ngôn ngữ trên AppBar → chọn `Tiếng Việt` hoặc `English`.
  - Giao diện sẽ cập nhật tức thời.
