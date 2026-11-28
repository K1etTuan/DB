import { api, newProductIds } from "./api.js";

const $ = (selector) => document.querySelector(selector);
const $$ = (selector) => [...document.querySelectorAll(selector)];
const formatVnd = (amount) =>
  new Intl.NumberFormat("vi-VN", { maximumFractionDigits: 0 }).format(amount) + " ₫";
const escapeHtml = (value) =>
  String(value ?? "").replace(/[&<>"']/g, (character) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
  })[character]);
const dateInputValue = (date) => {
  const localDate = new Date(date.getTime() - date.getTimezoneOffset() * 60_000);
  return localDate.toISOString().slice(0, 10);
};
const statusLabel = (status) => status === "Active" ? "Đang bán" : "Tạm ẩn";

let products = [];
let options = { categories: [], stores: [] };
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

function filtersFromForm() {
  return {
    keyword: $("#product-search").value.trim(),
    categoryId: $("#category-filter").value,
    storeId: $("#store-filter").value,
    status: $("#status-filter").value,
    minPrice: $("#min-price-filter").value,
    maxPrice: $("#max-price-filter").value,
  };
}

function renderProducts() {
  const rows = products;
  const productIds = new Set(rows.map((row) => row.product_id));
  const activeProductIds = new Set(rows.filter((row) => row.product_status === "Active").map((row) => row.product_id));
  $("#product-nav-count").textContent = String(productIds.size).padStart(2, "0");
  $("#product-count-label").textContent = `(${rows.length} phân loại)`;
  $("#table-range").textContent = `Đang hiển thị ${rows.length} phân loại thuộc ${productIds.size} sản phẩm`;
  $("#products-empty").classList.toggle("hidden", rows.length > 0);
  $("table").classList.toggle("table-empty", rows.length === 0);

  $("#products-table-body").innerHTML = rows.map((row) => {
    const [icon, tone] = categoryVisuals[row.category_name] ?? ["📦", "blue"];
    const stockClass = row.stock === 0 ? "stock-empty" : row.stock < 10 ? "stock-low" : "";
    const variantName = [row.color, row.size].filter(Boolean).join(" / ") || "Mặc định";
    return `
      <tr>
        <td>
          <div class="product-cell">
            <div class="product-thumb ${tone}">${icon}</div>
            <div class="product-meta">
              <strong>${escapeHtml(row.product_name)}</strong>
              <span>${escapeHtml(row.product_id)} <i>·</i> ${escapeHtml(row.category_name)}</span>
            </div>
          </div>
        </td>
        <td><div class="store-meta"><strong>${escapeHtml(row.store_name)}</strong><span>${escapeHtml(row.store_id)}</span></div></td>
        <td><div class="variant-meta"><strong>${escapeHtml(row.sku_code)}</strong><span>${escapeHtml(variantName)} · ${escapeHtml(row.variant_id)}</span></div></td>
        <td class="price-cell">${formatVnd(Number(row.unit_price))}</td>
        <td><span class="stock-value ${stockClass}">${Number(row.stock)}${row.stock < 10 ? '<i>Thấp</i>' : ""}</span></td>
        <td><span class="status-pill ${row.product_status === "Active" ? "status-active" : "status-inactive"}"><i></i>${statusLabel(row.product_status)}</span><small class="variant-status-text">PL: ${statusLabel(row.variant_status)}</small></td>
        <td><div class="row-actions">
          <button class="row-action" data-edit="${escapeHtml(row.variant_id)}" aria-label="Sửa ${escapeHtml(row.sku_code)}" title="Sửa sản phẩm / phân loại">✎</button>
          <button class="row-action delete-action" data-delete="${escapeHtml(row.product_id)}" aria-label="Xóa sản phẩm ${escapeHtml(row.product_name)}" title="Xóa sản phẩm và các phân loại">⌫</button>
        </div></td>
      </tr>`;
  }).join("");

  const lowStock = rows.filter((row) => row.stock < 10).length;
  const stockValue = rows.reduce((sum, row) => sum + Number(row.unit_price) * Number(row.stock), 0);
  $("#stat-products").textContent = productIds.size;
  $("#stat-active").textContent = activeProductIds.size;
  $("#stat-low-stock").textContent = lowStock;
  $("#stat-stock-value").textContent = formatVnd(stockValue);
  $("#overview-product-count").textContent = productIds.size;
  renderRestockOptions();
}

function populateSelect(selector, items, placeholder) {
  const select = $(selector);
  const selected = select.value;
  select.innerHTML = `<option value="">${placeholder}</option>${items.map((item) =>
    `<option value="${escapeHtml(item.id)}">${escapeHtml(item.name)}</option>`
  ).join("")}`;
  if (items.some((item) => item.id === selected)) select.value = selected;
}

function populateFormOptions() {
  populateSelect("#category-filter", options.categories, "Tất cả danh mục");
  populateSelect("#store-filter", options.stores, "Tất cả cửa hàng");
  populateSelect("#product-category", options.categories, "Chọn danh mục");
  populateSelect("#product-store", options.stores, "Chọn cửa hàng");
}

function renderRestockOptions() {
  const select = $("#restock-variant");
  const selected = select.value;
  select.innerHTML = products.map((row) =>
    `<option value="${escapeHtml(row.variant_id)}">${escapeHtml(row.product_name)} — ${escapeHtml(row.sku_code)} (${Number(row.stock)} tồn)</option>`
  ).join("");
  if (products.some((row) => row.variant_id === selected)) select.value = selected;
}

function openModal(variant) {
  $("#product-form").reset();
  $("#form-error").classList.add("hidden");
  $("#product-id").value = variant?.product_id ?? "";
  $("#variant-id").value = variant?.variant_id ?? "";
  $("#modal-title").textContent = variant ? "Chỉnh sửa sản phẩm / phân loại" : "Thêm sản phẩm & phân loại";
  $("#save-product-button").textContent = variant ? "Lưu thay đổi" : "Lưu sản phẩm";
  if (variant) {
    $("#product-name").value = variant.product_name;
    $("#product-category").value = variant.category_id;
    $("#product-store").value = variant.store_id;
    $("#product-sku").value = variant.sku_code;
    $("#product-variant-name").value = [variant.color, variant.size].filter(Boolean).join(" / ");
    $("#product-price").value = variant.unit_price;
    $("#product-stock").value = variant.stock;
    $("#product-status").value = variant.product_status;
    $("#variant-status").value = variant.variant_status;
  }
  $("#product-modal-backdrop").classList.remove("hidden");
  window.setTimeout(() => $("#product-name").focus(), 0);
}

function closeModal() {
  $("#product-modal-backdrop").classList.add("hidden");
}

function reportParams() {
  return {
    fromDate: $("#report-from-date").value,
    toDate: $("#report-to-date").value,
    sellerType: $("#report-seller-type").value,
    minRevenue: $("#report-min-revenue").value,
  };
}

function renderReport(report, params) {
  $("#report-revenue").textContent = formatVnd(report.revenue);
  $("#report-orders").textContent = report.orderCount;
  $("#report-average").textContent = formatVnd(report.average);
  $("#report-date-label").textContent = `${params.fromDate} — ${params.toDate}`;
  $("#report-table-body").innerHTML = report.stores.length
    ? report.stores.map((store) => `
      <tr>
        <td><div class="store-meta"><strong>${escapeHtml(store.store_name)}</strong><span>${escapeHtml(store.store_id)}</span></div></td>
        <td>${store.seller_type === "Business" ? "Doanh nghiệp" : "Cá nhân"}</td>
        <td>${Number(store.total_orders)}</td>
        <td>${Number(store.total_items_sold)}</td>
        <td class="price-cell">${formatVnd(Number(store.total_revenue))}</td>
        <td>${formatVnd(Number(store.avg_revenue_per_order))}</td>
      </tr>`).join("")
    : '<tr><td class="no-report" colspan="6">Không có cửa hàng phù hợp với bộ lọc đã chọn.</td></tr>';
}

async function loadReport() {
  const params = reportParams();
  if (!params.fromDate || !params.toDate) {
    showToast("Vui lòng nhập đầy đủ ngày bắt đầu và ngày kết thúc.", "error");
    return;
  }
  if (params.fromDate > params.toDate) {
    showToast("Ngày bắt đầu không được sau ngày kết thúc.", "error");
    return;
  }
  if (Number(params.minRevenue) < 0) {
    showToast("Doanh thu tối thiểu không được là số âm.", "error");
    return;
  }

  try {
    const report = await api.getSalesReport(params);
    renderReport(report, params);
  } catch (error) {
    showToast(error.message || "Không thể tải báo cáo.", "error");
  }
}

async function refreshProducts() {
  const { minPrice, maxPrice } = filtersFromForm();
  if ((minPrice !== "" && Number(minPrice) < 0) || (maxPrice !== "" && Number(maxPrice) < 0)) {
    showToast("Giá lọc không được là số âm.", "error");
    return;
  }
  if (minPrice !== "" && maxPrice !== "" && Number(minPrice) > Number(maxPrice)) {
    showToast("Giá tối thiểu không được lớn hơn giá tối đa.", "error");
    return;
  }
  try {
    products = await api.listProducts(filtersFromForm());
    renderProducts();
  } catch (error) {
    showToast(error.message || "Không thể tải danh sách phân loại.", "error");
  }
}

async function loadProductOptions() {
  try {
    options = await api.getProductOptions();
    populateFormOptions();
  } catch (error) {
    showToast(error.message || "Không thể tải danh mục và cửa hàng.", "error");
  }
}

function showPage(name) {
  $$(".page").forEach((page) => page.classList.toggle("active", page.id === `page-${name}`));
  $$(".nav-item").forEach((item) => item.classList.toggle("active", item.dataset.page === name));
  $("#page-breadcrumb").textContent = { overview: "Tổng quan", products: "Sản phẩm", reports: "Báo cáo" }[name];
  if (name === "reports") loadReport();
}

$("#product-search").addEventListener("input", refreshProducts);
["#category-filter", "#store-filter", "#status-filter", "#min-price-filter", "#max-price-filter"].forEach((selector) => {
  $(selector).addEventListener("change", refreshProducts);
});
$("#min-price-filter").addEventListener("input", refreshProducts);
$("#max-price-filter").addEventListener("input", refreshProducts);
$("#clear-product-filters").addEventListener("click", () => {
  $("#product-search").value = "";
  $("#category-filter").value = "";
  $("#store-filter").value = "";
  $("#status-filter").value = "";
  $("#min-price-filter").value = "";
  $("#max-price-filter").value = "";
  refreshProducts();
});
$("#refresh-products").addEventListener("click", refreshProducts);
$("#add-product-button").addEventListener("click", () => openModal());
$("#quick-add-product").addEventListener("click", () => openModal());
$("#close-product-modal").addEventListener("click", closeModal);
$("#cancel-product-modal").addEventListener("click", closeModal);
$("#apply-report").addEventListener("click", loadReport);
$("#calculate-restock").addEventListener("click", async () => {
  const variantId = $("#restock-variant").value;
  const days = Number($("#restock-days").value);
  const result = $("#restock-result");
  if (!variantId || !Number.isInteger(days) || days <= 0) {
    showToast("Chọn phân loại và nhập số ngày dự trữ là số nguyên dương.", "error");
    return;
  }
  try {
    const quantity = await api.getRestockSuggestion(variantId, days);
    if (quantity < 0) throw new Error("Không tìm thấy phân loại hoặc tham số không hợp lệ.");
    result.textContent = `Nên nhập thêm ${quantity} sản phẩm`;
    result.classList.remove("hidden");
  } catch (error) {
    showToast(error.message || "Không thể tính số lượng nhập thêm.", "error");
  }
});

$$(".nav-item").forEach((item) => item.addEventListener("click", () => showPage(item.dataset.page)));
$$("[data-go]").forEach((item) => item.addEventListener("click", () => showPage(item.dataset.go)));

$("#product-modal-backdrop").addEventListener("click", (event) => {
  if (event.target === $("#product-modal-backdrop")) closeModal();
});

$("#products-table-body").addEventListener("click", async (event) => {
  const editButton = event.target.closest("[data-edit]");
  const deleteButton = event.target.closest("[data-delete]");
  if (editButton) {
    const variant = products.find((item) => item.variant_id === editButton.dataset.edit);
    if (variant) openModal(variant);
  }
  if (deleteButton) {
    const product = products.find((item) => item.product_id === deleteButton.dataset.delete);
    if (!product) return;
    const confirmed = window.confirm(`Xóa “${product.product_name}” và toàn bộ phân loại khỏi dữ liệu bản mẫu?`);
    if (!confirmed) return;
    try {
      await api.deleteProduct(product.product_id);
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
  const categoryId = $("#product-category").value;
  const storeId = $("#product-store").value;
  const sku = $("#product-sku").value.trim();
  const variantName = $("#product-variant-name").value.trim();
  const price = Number($("#product-price").value);
  const stock = Number($("#product-stock").value);
  const category = options.categories.find((item) => item.id === categoryId);
  const store = options.stores.find((item) => item.id === storeId);

  if (!name || !category || !store || !sku) {
    errorBox.textContent = "Nhập tên sản phẩm, SKU, danh mục và cửa hàng.";
    errorBox.classList.remove("hidden");
    return;
  }
  if (!Number.isFinite(price) || price < 0 || !Number.isInteger(stock) || stock < 0) {
    errorBox.textContent = "Giá phải không âm và tồn kho phải là số nguyên không âm.";
    errorBox.classList.remove("hidden");
    return;
  }
  if (products.some((item) => item.sku_code.toLocaleLowerCase("vi") === sku.toLocaleLowerCase("vi")
    && item.variant_id !== $("#variant-id").value)) {
    errorBox.textContent = "Mã SKU đã được sử dụng cho một phân loại khác.";
    errorBox.classList.remove("hidden");
    return;
  }

  const currentVariantId = $("#variant-id").value;
  const existing = products.find((item) => item.variant_id === currentVariantId);
  const generated = currentVariantId ? null : newProductIds();
  const [color = null, size = null] = variantName.split("/").map((part) => part.trim());
  const product = {
    product_id: $("#product-id").value || generated.productId,
    product_name: name,
    category_id: category.id,
    category_name: category.name,
    store_id: store.id,
    store_name: store.name,
    variant_id: currentVariantId || generated.variantId,
    sku_code: sku,
    color: color || null,
    size: size || null,
    unit_price: price,
    stock,
    product_status: $("#product-status").value,
    variant_status: $("#variant-status").value,
    created_at: existing?.created_at ?? new Date().toISOString(),
  };

  try {
    await api.saveProduct(product);
    await refreshProducts();
    closeModal();
    showToast(currentVariantId ? "Đã cập nhật sản phẩm trong dữ liệu bản mẫu." : "Đã thêm sản phẩm và phân loại vào dữ liệu bản mẫu.");
  } catch (error) {
    errorBox.textContent = error.message || "Không thể lưu sản phẩm.";
    errorBox.classList.remove("hidden");
  }
});

$("#export-report").addEventListener("click", async () => {
  const params = reportParams();
  try {
    const report = await api.getSalesReport(params);
    const rows = [
      ["Mã cửa hàng", "Tên cửa hàng", "Loại người bán", "Số đơn", "Số sản phẩm", "Doanh thu", "Doanh thu trung bình / đơn"],
      ...report.stores.map((store) => [
        store.store_id,
        store.store_name,
        store.seller_type,
        store.total_orders,
        store.total_items_sold,
        store.total_revenue,
        store.avg_revenue_per_order,
      ]),
    ];
    const csv = rows.map((row) => row.map((cell) => `"${String(cell).replaceAll('"', '""')}"`).join(",")).join("\r\n");
    const link = document.createElement("a");
    link.href = URL.createObjectURL(new Blob(["\ufeff", csv], { type: "text/csv;charset=utf-8" }));
    link.download = "shopeedb-doanh-thu-cua-hang.csv";
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

const today = new Date();
const sevenDaysAgo = new Date(today);
sevenDaysAgo.setDate(today.getDate() - 6);
$("#report-from-date").value = dateInputValue(sevenDaysAgo);
$("#report-to-date").value = dateInputValue(today);

await loadProductOptions();
await refreshProducts();
await loadReport();
