import { api, newProductId } from "./api.js";

const $ = (selector) => document.querySelector(selector);
const $$ = (selector) => [...document.querySelectorAll(selector)];
const formatVnd = (amount) =>
  new Intl.NumberFormat("vi-VN", { maximumFractionDigits: 0 }).format(amount) + " ₫";
const escapeHtml = (value) =>
  String(value).replace(/[&<>"']/g, (character) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
  })[character]);

let products = [];
let toastTimer;

const categoryVisuals = {
  "Điện tử": ["🎧", "lavender"],
  "Gia dụng": ["🧋", "mint"],
  "Thời trang": ["👕", "peach"],
  "Phụ kiện": ["🎒", "blue"],
  "Khác": ["📦", "yellow"],
};

function showToast(message, type = "success") {
  const toast = $("#toast");
  toast.textContent = message;
  toast.className = `toast ${type}`;
  window.clearTimeout(toastTimer);
  toastTimer = window.setTimeout(() => toast.classList.add("hidden"), 3200);
}

function renderProducts() {
  const query = $("#product-search").value.trim().toLocaleLowerCase("vi");
  const status = $("#status-filter").value;
  const filtered = products.filter((product) => {
    const matchesText = `${product.name} ${product.id} ${product.category}`.toLocaleLowerCase("vi").includes(query);
    const matchesStatus = status === "all" || product.status === status;
    return matchesText && matchesStatus;
  });

  $("#product-nav-count").textContent = String(products.length).padStart(2, "0");
  $("#product-count-label").textContent = `(${filtered.length})`;
  $("#table-range").textContent = `Đang hiển thị ${filtered.length ? 1 : 0}–${filtered.length} trong ${filtered.length} sản phẩm`;
  $("#products-empty").classList.toggle("hidden", filtered.length > 0);
  $("table").classList.toggle("table-empty", filtered.length === 0);

  $("#products-table-body").innerHTML = filtered.map((product) => {
    const [icon, tone] = categoryVisuals[product.category] ?? ["📦", "blue"];
    const stockClass = product.stock === 0 ? "stock-empty" : product.stock < 10 ? "stock-low" : "";
    return `
      <tr>
        <td class="check-cell"><input type="checkbox" aria-label="Chọn ${escapeHtml(product.name)}" disabled /></td>
        <td>
          <div class="product-cell">
            <div class="product-thumb ${tone}">${icon}</div>
            <div class="product-meta">
              <strong>${escapeHtml(product.name)}</strong>
              <span>${escapeHtml(product.id)} <i>·</i> ${escapeHtml(product.category)}</span>
            </div>
          </div>
        </td>
        <td><span class="variant-count">${Number(product.variants)} phân loại</span></td>
        <td class="price-cell">${formatVnd(Number(product.price))}</td>
        <td><span class="stock-value ${stockClass}">${Number(product.stock)}${product.stock < 10 ? '<i>Thấp</i>' : ""}</span></td>
        <td><span class="status-pill ${product.status === "Đang bán" ? "status-active" : "status-inactive"}"><i></i>${escapeHtml(product.status)}</span></td>
        <td><div class="row-actions">
          <button class="row-action" data-edit="${escapeHtml(product.id)}" aria-label="Sửa ${escapeHtml(product.name)}" title="Chỉnh sửa">✎</button>
          <button class="row-action delete-action" data-delete="${escapeHtml(product.id)}" aria-label="Xóa ${escapeHtml(product.name)}" title="Xóa">⌫</button>
        </div></td>
      </tr>`;
  }).join("");

  const activeCount = products.filter((product) => product.status === "Đang bán").length;
  const lowStock = products.filter((product) => product.stock < 10).length;
  const stockValue = products.reduce((sum, product) => sum + Number(product.price) * Number(product.stock), 0);
  $("#stat-products").textContent = products.length;
  $("#stat-active").textContent = activeCount;
  $("#stat-low-stock").textContent = lowStock;
  $("#stat-stock-value").textContent = formatVnd(stockValue);
  $("#overview-product-count").textContent = products.length;
}

function openModal(product) {
  $("#product-form").reset();
  $("#form-error").classList.add("hidden");
  $("#product-id").value = product?.id ?? "";
  $("#modal-title").textContent = product ? "Chỉnh sửa sản phẩm" : "Thêm sản phẩm";
  $("#save-product-button").textContent = product ? "Lưu thay đổi" : "Lưu sản phẩm";
  if (product) {
    $("#product-name").value = product.name;
    $("#product-category").value = product.category;
    $("#product-store").value = product.store;
    $("#product-price").value = product.price;
    $("#product-stock").value = product.stock;
    $("#product-variants").value = product.variants;
  }
  $("#product-modal-backdrop").classList.remove("hidden");
  window.setTimeout(() => $("#product-name").focus(), 0);
}

function closeModal() {
  $("#product-modal-backdrop").classList.add("hidden");
}

function renderReport(report, period) {
  $("#report-revenue").textContent = formatVnd(report.revenue);
  $("#report-orders").textContent = report.orderCount;
  $("#report-average").textContent = formatVnd(report.average);
  $("#report-date-label").textContent = period === "all" ? "Toàn thời gian" : `${period} ngày gần nhất`;
  const total = report.categories.reduce((sum, category) => sum + category.revenue, 0);
  $("#report-table-body").innerHTML = report.categories.length
    ? report.categories.map((category) => {
      const share = total ? Math.round((category.revenue / total) * 100) : 0;
      return `<tr>
        <td><strong class="report-category">${escapeHtml(category.category)}</strong></td>
        <td>${category.orders}</td>
        <td>${category.items}</td>
        <td class="price-cell">${formatVnd(category.revenue)}</td>
        <td><div class="share-cell"><span class="share-track"><i style="width:${share}%"></i></span><b>${share}%</b></div></td>
      </tr>`;
    }).join("")
    : '<tr><td class="no-report" colspan="5">Không có đơn hoàn thành trong khoảng thời gian này.</td></tr>';
}

async function loadReport() {
  try {
    const period = $("#report-period").value;
    const report = await api.getSalesReport({ days: period, store: $("#report-store").value });
    renderReport(report, period);
  } catch (error) {
    showToast(error.message || "Không thể tải báo cáo.", "error");
  }
}

function showPage(name) {
  $$(".page").forEach((page) => page.classList.toggle("active", page.id === `page-${name}`));
  $$(".nav-item").forEach((item) => item.classList.toggle("active", item.dataset.page === name));
  $("#page-breadcrumb").textContent = { overview: "Tổng quan", products: "Sản phẩm", reports: "Báo cáo" }[name];
  if (name === "reports") loadReport();
}

async function refreshProducts() {
  try {
    products = await api.listProducts();
    renderProducts();
  } catch (error) {
    showToast(error.message || "Không thể tải sản phẩm.", "error");
  }
}

$("#product-search").addEventListener("input", renderProducts);
$("#status-filter").addEventListener("change", renderProducts);
$("#refresh-products").addEventListener("click", refreshProducts);
$("#add-product-button").addEventListener("click", () => openModal());
$("#quick-add-product").addEventListener("click", () => openModal());
$("#close-product-modal").addEventListener("click", closeModal);
$("#cancel-product-modal").addEventListener("click", closeModal);
$("#apply-report").addEventListener("click", loadReport);

$$(".nav-item").forEach((item) => item.addEventListener("click", () => showPage(item.dataset.page)));
$$("[data-go]").forEach((item) => item.addEventListener("click", () => showPage(item.dataset.go)));

$("#product-modal-backdrop").addEventListener("click", (event) => {
  if (event.target === $("#product-modal-backdrop")) closeModal();
});

$("#products-table-body").addEventListener("click", async (event) => {
  const editButton = event.target.closest("[data-edit]");
  const deleteButton = event.target.closest("[data-delete]");
  if (editButton) {
    const product = products.find((item) => item.id === editButton.dataset.edit);
    if (product) openModal(product);
  }
  if (deleteButton) {
    const product = products.find((item) => item.id === deleteButton.dataset.delete);
    if (!product) return;
    const confirmed = window.confirm(`Xóa “${product.name}” khỏi danh sách bản mẫu?`);
    if (!confirmed) return;
    try {
      await api.deleteProduct(product.id);
      await refreshProducts();
      showToast("Đã xóa sản phẩm khỏi dữ liệu bản mẫu.");
    } catch (error) {
      showToast(error.message || "Không thể xóa sản phẩm.", "error");
    }
  }
});

$("#product-form").addEventListener("submit", async (event) => {
  event.preventDefault();
  const errorBox = $("#form-error");
  const name = $("#product-name").value.trim();
  const category = $("#product-category").value;
  const store = $("#product-store").value;
  const price = Number($("#product-price").value);
  const stock = Number($("#product-stock").value);
  const variants = Number($("#product-variants").value);

  if (!name || !category || !store) {
    errorBox.textContent = "Vui lòng nhập tên sản phẩm, danh mục và cửa hàng.";
    errorBox.classList.remove("hidden");
    return;
  }
  if (!Number.isFinite(price) || price < 0 || !Number.isInteger(stock) || stock < 0 || !Number.isInteger(variants) || variants < 1) {
    errorBox.textContent = "Giá phải từ 0 trở lên, tồn kho là số nguyên không âm và số phân loại ít nhất là 1.";
    errorBox.classList.remove("hidden");
    return;
  }

  const currentId = $("#product-id").value;
  const existing = products.find((product) => product.id === currentId);
  const [icon, tone] = categoryVisuals[category] ?? ["📦", "blue"];
  const product = {
    id: currentId || newProductId(products),
    name,
    category,
    store,
    price,
    stock,
    variants,
    status: stock > 0 ? "Đang bán" : "Tạm ẩn",
    icon: existing?.icon ?? icon,
    tone: existing?.tone ?? tone,
  };

  try {
    await api.saveProduct(product);
    await refreshProducts();
    closeModal();
    showToast(currentId ? "Đã cập nhật sản phẩm trong dữ liệu bản mẫu." : "Đã thêm sản phẩm vào dữ liệu bản mẫu.");
  } catch (error) {
    errorBox.textContent = error.message || "Không thể lưu sản phẩm.";
    errorBox.classList.remove("hidden");
  }
});

$("#export-report").addEventListener("click", async () => {
  try {
    const report = await api.getSalesReport({ days: $("#report-period").value, store: $("#report-store").value });
    const rows = [["Danh mục", "Số đơn", "Sản phẩm đã bán", "Doanh thu"], ...report.categories.map((item) => [item.category, item.orders, item.items, item.revenue])];
    const csv = rows.map((row) => row.map((cell) => `"${String(cell).replaceAll('"', '""')}"`).join(",")).join("\r\n");
    const link = document.createElement("a");
    link.href = URL.createObjectURL(new Blob(["\ufeff", csv], { type: "text/csv;charset=utf-8" }));
    link.download = "shopeedb-bao-cao.csv";
    link.click();
    URL.revokeObjectURL(link.href);
    showToast("Đã tải báo cáo bản mẫu.");
  } catch (error) {
    showToast(error.message || "Không thể xuất báo cáo.", "error");
  }
});

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") closeModal();
  if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k") {
    event.preventDefault();
    showPage("products");
    $("#product-search").focus();
  }
});

await refreshProducts();
await loadReport();
