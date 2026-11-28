# ShopeeDB frontend

Giao diện bản mẫu cho quản lý sản phẩm/phân loại, báo cáo doanh thu theo cửa hàng và gợi ý nhập thêm hàng. Chạy từ thư mục này bằng:

```powershell
python -m http.server 5173
```

Mở `http://localhost:5173`. Dữ liệu hiện dùng `localStorage` và dữ liệu bán hàng mô phỏng; ứng dụng chưa kết nối API, backend hoặc MySQL.

## Đối chiếu với SQL hiện có

- Bộ lọc sản phẩm tương ứng tham số `p_keyword`, `p_category_id`, `p_store_id`, `p_status`, `p_min_price`, `p_max_price` của `sp_TimKiemSanPham`.
- Mỗi dòng kết quả là một phân loại; dùng các trường `product_id`, `product_name`, `category_id`, `category_name`, `store_id`, `store_name`, `variant_id`, `sku_code`, `color`, `size`, `unit_price`, `stock`, `product_status`, `variant_status`, `created_at`.
- Bộ lọc báo cáo tương ứng `p_from_date`, `p_to_date`, `p_seller_type`, `p_min_revenue` của `sp_ThongKeDoanhThuCuaHang`. Bảng hiển thị `store_id`, `store_name`, `seller_type`, `total_orders`, `total_items_sold`, `total_revenue`, `avg_revenue_per_order`.
- Khung gợi ý nhập hàng mô phỏng `fn_suggest_restock(p_variant_id, p_days)`.

## API contract dự kiến

Thư mục `backend/` hiện chưa có API. Khi nhóm bổ sung backend, thay implementation trong `api.js`; các endpoint dưới đây là hợp đồng gợi ý, cần thống nhất với người làm backend:

- `GET /api/products?keyword=&category_id=&store_id=&status=&min_price=&max_price=` — gọi `sp_TimKiemSanPham` theo các tham số tương ứng.
- `GET /api/reference-data` — trả danh sách danh mục/cửa hàng để điền bộ lọc và form, nếu nhóm bổ sung route này.
- `POST /api/products`, `PUT /api/products/:productId`, `DELETE /api/products/:productId` — CRUD đang chỉ chạy ở mock; cần procedure CRUD và API tương ứng trước khi tích hợp.
- `GET /api/reports/store-revenue?from_date=&to_date=&seller_type=&min_revenue=` — gọi `sp_ThongKeDoanhThuCuaHang`.
- `GET /api/variants/:variantId/restock-suggestion?days=` — gọi `fn_suggest_restock`.

Mock dùng mã danh mục/cửa hàng minh họa; thay bằng mã thật được trả từ CSDL khi tích hợp. Không kết nối MySQL trực tiếp từ trình duyệt.
