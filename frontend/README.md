# ShopeeDB frontend

Giao diện quản trị bản mẫu gồm quản lý sản phẩm và báo cáo. Chạy bằng static server từ thư mục này, ví dụ:

```powershell
python -m http.server 5173
```

Sau đó mở `http://localhost:5173`. Dữ liệu sản phẩm mẫu được lưu trong `localStorage`; dữ liệu báo cáo là giả lập. Giao diện chưa kết nối backend hoặc MySQL.

## Luồng sử dụng

```text
Sản phẩm: tìm/lọc → thêm/sửa/xóa → kiểm tra dữ liệu → cập nhật danh sách
Báo cáo: chọn kỳ/cửa hàng → truy vấn tổng hợp → xem kết quả → tải CSV
```

## Hợp đồng để nối backend sau này

Thay phần triển khai trong `api.js`, giữ nguyên các hàm frontend đang dùng:

- `listProducts()` — `GET /api/products?search=&status=`
- `saveProduct(product)` — `POST /api/products` khi tạo, `PUT /api/products/:id` khi sửa
- `deleteProduct(id)` — `DELETE /api/products/:id`
- `getSalesReport({ days, store })` — `GET /api/reports/sales?days=&store=`

API nên trả sản phẩm có các trường `id`, `name`, `category`, `store`, `price`, `stock`, `variants`, `status`; báo cáo có `revenue`, `orderCount`, `average`, `categories` (mỗi dòng gồm `category`, `orders`, `items`, `revenue`). Backend có thể ánh xạ tên cột từ MySQL sang cấu trúc này. Các thao tác ghi và truy vấn báo cáo cần gọi stored procedure/function theo phần SQL của nhóm.
