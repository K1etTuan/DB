# DB

## Chạy cơ sở dữ liệu

**Yêu cầu:** MySQL Server **8.0.16 trở lên**, server đang chạy và tài khoản có quyền tạo/xóa CSDL (ví dụ `root`).

Mở **PowerShell** (có thể dùng Terminal PowerShell trong VS Code).

1. Dùng `cd` vào thư mục `database` của dự án:

   ```powershell
   cd "DUONG_DAN_THU_MUC_DU_AN\database"
   ```

   Thay `DUONG_DAN_THU_MUC_DU_AN` bằng đường dẫn thư mục dự án trên máy của bạn (thư mục chứa `README.md` và `database`).

2. Đăng nhập MySQL. Ví dụ máy cài MySQL 9.6 ở đường dẫn mặc định:

   ```powershell
   & "C:\Program Files\MySQL\MySQL Server 9.6\bin\mysql.exe" --commands -u root -p
   ```

   Thay đường dẫn và tài khoản theo máy của bạn. Nhập **mật khẩu MySQL của bạn** khi được hỏi.

3. Khi xuất hiện **`mysql>`**, chạy:

   ```sql
   SOURCE main.sql;
   ```
**Lưu ý:** Mỗi lần chạy sẽ **xóa và tạo lại `ShopeeDB`**, mất dữ liệu cũ.
