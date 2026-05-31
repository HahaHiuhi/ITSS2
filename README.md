# 📚 Student Academic Planner — Lumina ITSS2
Ứng dụng **lập kế hoạch học tập sinh viên** được xây dựng bằng **Flutter** (hỗ trợ Web, Android, iOS) và tích hợp **Supabase** làm backend (xác thực, cơ sở dữ liệu thời gian thực).
---
## 🗂️ Cấu trúc dự án
```
ITSS2/
├── lib/
│   ├── main.dart                      # Entry point, cấu hình theme & routing
│   ├── models/
│   │   ├── subject.dart               # Model môn học
│   │   ├── task.dart                  # Model nhiệm vụ / deadline
│   │   └── schedule.dart              # Model thời khóa biểu
│   ├── screens/
│   │   ├── auth_screen.dart           # Màn hình đăng nhập / đăng ký
│   │   ├── home_dashboard_screen.dart # Trang chủ tổng quan
│   │   ├── task_list_screen.dart      # Danh sách nhiệm vụ
│   │   ├── task_detail_screen.dart    # Chi tiết nhiệm vụ
│   │   ├── schedule_screen.dart       # Thời khóa biểu
│   │   ├── subject_screen.dart        # Quản lý môn học
│   │   └── profile_screen.dart        # Hồ sơ người dùng
│   └── services/
│       └── supabase_service.dart      # Toàn bộ logic gọi API Supabase
├── supabase/
│   └── schema.sql                     # Schema SQL (subjects, tasks, schedules)
├── web/
│   └── index.html                     # Entry point cho Flutter Web
├── pubspec.yaml                       # Khai báo dependencies
├── DESIGN.md                          # Design system & style guide
└── README.md                          # Tài liệu này
```
---
## ✨ Tính năng chính
|
 Tính năng 
|
 Mô tả 
|
|
---
|
---
|
|
 🔐 Xác thực 
|
 Đăng ký / Đăng nhập bằng email qua Supabase Auth 
|
|
 🏠 Dashboard 
|
 Tổng quan nhiệm vụ sắp đến & lịch học hôm nay 
|
|
 ✅ Quản lý Tasks 
|
 Tạo, chỉnh sửa, xóa, đánh dấu hoàn thành; mức độ ưu tiên LOW/MEDIUM/HIGH 
|
|
 📅 Thời khóa biểu 
|
 Quản lý lịch học theo tuần 
|
|
 📖 Môn học 
|
 Tạo và quản lý các môn học với màu sắc riêng 
|
|
 👤 Hồ sơ 
|
 Chỉnh sửa thông tin cá nhân (tên, MSSV, trường, ngành) 
|
|
 🎭 Chế độ Demo 
|
 Chạy thử ứng dụng mà không cần Supabase 
|
---
## 🛠️ Yêu cầu cài đặt
### 1. Flutter SDK *(bắt buộc)*
> **Phiên bản yêu cầu:** Flutter `>=3.16.0` · Dart `>=3.2.0 <4.0.0`
**Tải Flutter:**
- Truy cập: https://docs.flutter.dev/get-started/install/windows
- Giải nén vào thư mục (ví dụ `C:\flutter` hoặc `C:\Users\<tên>\AppData\Local\flutter`)
**Thêm Flutter vào PATH** *(quan trọng)*:
Mở PowerShell với quyền Administrator và chạy:
```powershell
# Thêm vào PATH cho user hiện tại (thay đường dẫn thực tế):
[Environment]::SetEnvironmentVariable(
  "PATH",
  "$env:PATH;C:\Users\macth\.Flutter_SDK\flutter\bin",
  "User"
)
```
Hoặc thêm thủ công:
1. Nhấn `Win + S` → tìm **"Edit environment variables"**
2. Chọn **Path** → **Edit** → **New**
3. Thêm đường dẫn tới `<flutter-sdk>\bin`
**Kiểm tra:**
```powershell
# Mở terminal MỚI sau khi thêm PATH
flutter --version
flutter doctor
```
> **⚠️ Lưu ý máy này:** Flutter SDK đã cài tại `C:\Users\macth\.Flutter_SDK\flutter\bin` nhưng chưa được thêm vào PATH. Cần thực hiện bước trên trước khi dùng lệnh `flutter`.
---
### 2. Trình duyệt để chạy Flutter Web *(bắt buộc)*
Flutter Web yêu cầu Chrome hoặc Edge. Máy này đã có **Microsoft Edge**.
**Nếu dùng Edge (không cần cài thêm):**
```powershell
# Thêm vào biến môi trường CHROME_EXECUTABLE
[Environment]::SetEnvironmentVariable(
  "CHROME_EXECUTABLE",
  "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
  "User"
)
```
**Nếu muốn cài Chrome:**
- Tải tại: https://www.google.com/chrome/
---
### 3. IDE — VS Code *(khuyến nghị)*
- Tải: https://code.visualstudio.com/
- Sau khi cài VS Code, mở Extensions (`Ctrl+Shift+X`) và cài:
  - **Flutter** (ID: `Dart-Code.flutter`) — tự động cài kèm Dart
  - **Dart** (ID: `Dart-Code.dart-code`)
---
### 4. Android Emulator *(tùy chọn — chỉ cần nếu muốn test Android)*
- Cài **Android Studio**: https://developer.android.com/studio
- Trong Android Studio: **Tools → AVD Manager → Create Virtual Device**
- Chọn thiết bị (ví dụ Pixel 8) với Android API 34+
---
## 🚀 Hướng dẫn chạy dự án
### Bước 1 — Mở terminal và vào thư mục dự án
```powershell
cd e:\Lumina_ITSS2\ITSS2
```
### Bước 2 — Thiết lập PATH cho phiên terminal hiện tại
> Bước này chỉ cần thực hiện cho đến khi bạn thêm Flutter vào PATH vĩnh viễn.
```powershell
$env:PATH = "C:\Users\macth\.Flutter_SDK\flutter\bin;" + $env:PATH
$env:CHROME_EXECUTABLE = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
```
### Bước 3 — Cài dependencies
```powershell
flutter pub get
```
### Bước 4 — Cấu hình Supabase *(tùy chọn)*
> ⚠️ **Nếu bỏ qua bước này**, ứng dụng vẫn chạy được ở **Chế độ Demo** (dữ liệu chỉ lưu trong RAM, mất khi tắt app).
**4a. Tạo project Supabase:**
1. Truy cập https://supabase.com → Tạo tài khoản miễn phí
2. Tạo **New Project**, đặt tên và mật khẩu database
3. Vào **Project Settings → API**, sao chép:
   - **Project URL** (dạng `https://xxxxx.supabase.co`)
   - **anon/public key**
**4b. Chạy schema SQL:**
1. Trong Supabase dashboard → **SQL Editor**
2. Copy toàn bộ nội dung file `supabase/schema.sql`
3. Dán vào SQL Editor và nhấn **Run**
### Bước 5 — Chạy ứng dụng
#### 🎭 Chế độ Demo (không cần Supabase)
```powershell
flutter run -d edge
```
> Tại màn hình đăng nhập, nhấn **"Continue as Demo"** để vào app ngay mà không cần tài khoản.
#### 🌐 Chế độ đầy đủ (có Supabase)
```powershell
flutter run -d edge `
  --dart-define=SUPABASE_URL=https://your-project-id.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
```
#### 📱 Chạy trên Android Emulator
```powershell
# Xem danh sách thiết bị:
flutter devices
# Chạy (thay <device-id>):
flutter run -d <device-id> `
  --dart-define=SUPABASE_URL=https://your-project-id.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
```
---
## ⚙️ Cấu hình VS Code (khuyến nghị)
Tạo file `.vscode/launch.json` để chạy nhanh bằng **F5**:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "🎭 Demo Mode (Edge)",
      "request": "launch",
      "type": "dart",
      "deviceId": "edge",
      "program": "lib/main.dart"
    },
    {
      "name": "🌐 Supabase Mode (Edge)",
      "request": "launch",
      "type": "dart",
      "deviceId": "edge",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=SUPABASE_URL=https://your-project-id.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=your-anon-key-here"
      ]
    }
  ]
}
```
---
## 🗄️ Cơ sở dữ liệu (Supabase Schema)
File `supabase/schema.sql` tạo ra các bảng:
|
 Bảng 
|
 Mô tả 
|
|
---
|
---
|
|
`subjects`
|
 Môn học (tên, màu sắc, user_id) 
|
|
`tasks`
|
 Nhiệm vụ / deadline (tiêu đề, mô tả, hạn chót, độ ưu tiên LOW/MEDIUM/HIGH, trạng thái) 
|
|
`schedules`
|
 Thời khóa biểu (tên lớp, ngày trong tuần, giờ bắt đầu/kết thúc, địa điểm) 
|
**Row Level Security (RLS):** Bật trên tất cả bảng — mỗi user chỉ thấy dữ liệu của mình.
**Stored Procedure:** `get_dashboard_summary(p_user_id)` — trả về tổng quan dashboard trong một lần gọi API.
---
## 📦 Dependencies
|
 Package 
|
 Phiên bản 
|
 Mục đích 
|
|
---
|
---
|
---
|
|
`supabase_flutter`
|
`^2.5.0`
|
 Kết nối Supabase (auth + database) 
|
|
`provider`
|
`^6.1.2`
|
 State management (ChangeNotifier) 
|
|
`google_fonts`
|
`^6.2.0`
|
 Font Inter cho toàn bộ UI 
|
|
`intl`
|
`^0.19.0`
|
 Định dạng ngày giờ 
|
|
`cupertino_icons`
|
`^1.0.8`
|
 Icon set iOS style 
|
---
## 🐛 Xử lý lỗi thường gặp
|
 Lỗi 
|
 Nguyên nhân 
|
 Giải pháp 
|
|
---
|
---
|
---
|
|
`flutter: command not found`
|
 Flutter chưa vào PATH 
|
 Thêm 
`<flutter-sdk>\bin`
 vào PATH; mở terminal mới 
|
|
`Cannot find Chrome/Edge`
|
 CHROME_EXECUTABLE chưa set 
|
 Chạy: 
`$env:CHROME_EXECUTABLE = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"`
|
|
`No supported devices found`
|
 Không có thiết bị nào 
|
 Chạy 
`flutter devices`
 để kiểm tra; bật Edge hoặc Emulator 
|
|
`Supabase initialization failed`
|
 Sai URL / Anon Key 
|
 Kiểm tra lại trong 
**
Supabase → Project Settings → API
**
|
|
`RPC error: function not found`
|
 Chưa chạy schema SQL 
|
 Vào 
**
SQL Editor
**
 của Supabase, chạy lại toàn bộ 
`supabase/schema.sql`
|
|
`pub get failed`
|
 Lỗi mạng / phiên bản 
|
 Chạy 
`flutter clean`
 rồi 
`flutter pub get`
 lại 
|
|
 Hot reload không hoạt động 
|
 Chạy production mode 
|
 Thêm flag 
`--debug`
 hoặc dùng 
`flutter run`
 thay vì build 
|
---
## 💡 Ghi chú quan trọng
- **Không commit** API key hoặc thông tin Supabase lên Git
- **Chế độ Demo** hoạt động hoàn toàn cục bộ — dữ liệu mất khi tắt app, chỉ dùng để test UI
- Để thêm màn hình mới: tạo file trong `lib/screens/`, đăng ký route trong `lib/main.dart`
- Khi deploy production, nhớ truyền `--dart-define` đúng với key thật
---
## 🔗 Tài liệu tham khảo
- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter Package](https://pub.dev/packages/supabase_flutter)
- [Provider Package](https://pub.dev/packages/provider)