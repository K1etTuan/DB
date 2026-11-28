const STORAGE_KEY = "shopeedb.variants.v2";

const categoryOptions = [
  { id: "CAT-ELEC", name: "Điện tử" },
  { id: "CAT-HOME", name: "Gia dụng" },
  { id: "CAT-FASHION", name: "Thời trang" },
  { id: "CAT-ACCESSORY", name: "Phụ kiện" },
];

const storeOptions = [
  { id: "STORE-TECH", name: "Tech House", sellerType: "Business" },
  { id: "STORE-HOME", name: "Nhà Xinh", sellerType: "Individual" },
  { id: "STORE-MAY", name: "Mây Studio", sellerType: "Business" },
];

const seedVariants = [
  { product_id: "SP-1024", product_name: "Tai nghe không dây AirBeat Pro", category_id: "CAT-ELEC", category_name: "Điện tử", store_id: "STORE-TECH", store_name: "Tech House", variant_id: "VAR-1024-BK", sku_code: "ABP-BLACK", color: "Đen", size: null, unit_price: 1290000, stock: 24, product_status: "Active", variant_status: "Active" },
  { product_id: "SP-1024", product_name: "Tai nghe không dây AirBeat Pro", category_id: "CAT-ELEC", category_name: "Điện tử", store_id: "STORE-TECH", store_name: "Tech House", variant_id: "VAR-1024-WH", sku_code: "ABP-WHITE", color: "Trắng", size: null, unit_price: 1350000, stock: 18, product_status: "Active", variant_status: "Active" },
  { product_id: "SP-1023", product_name: "Bình giữ nhiệt Everyday 500ml", category_id: "CAT-HOME", category_name: "Gia dụng", store_id: "STORE-HOME", store_name: "Nhà Xinh", variant_id: "VAR-1023-GN", sku_code: "EV500-GREEN", color: "Xanh lá", size: null, unit_price: 259000, stock: 8, product_status: "Active", variant_status: "Active" },
  { product_id: "SP-1023", product_name: "Bình giữ nhiệt Everyday 500ml", category_id: "CAT-HOME", category_name: "Gia dụng", store_id: "STORE-HOME", store_name: "Nhà Xinh", variant_id: "VAR-1023-CR", sku_code: "EV500-CREAM", color: "Kem", size: null, unit_price: 259000, stock: 14, product_status: "Active", variant_status: "Active" },
  { product_id: "SP-1022", product_name: "Áo thun cotton basic unisex", category_id: "CAT-FASHION", category_name: "Thời trang", store_id: "STORE-MAY", store_name: "Mây Studio", variant_id: "VAR-1022-M-BK", sku_code: "BASIC-M-BLK", color: "Đen", size: "M", unit_price: 189000, stock: 42, product_status: "Active", variant_status: "Active" },
  { product_id: "SP-1022", product_name: "Áo thun cotton basic unisex", category_id: "CAT-FASHION", category_name: "Thời trang", store_id: "STORE-MAY", store_name: "Mây Studio", variant_id: "VAR-1022-L-WH", sku_code: "BASIC-L-WHT", color: "Trắng", size: "L", unit_price: 199000, stock: 31, product_status: "Active", variant_status: "Active" },
  { product_id: "SP-1021", product_name: "Đèn bàn LED cảm ứng Lumi", category_id: "CAT-HOME", category_name: "Gia dụng", store_id: "STORE-HOME", store_name: "Nhà Xinh", variant_id: "VAR-1021-WH", sku_code: "LUMI-WHITE", color: "Trắng", size: null, unit_price: 425000, stock: 0, product_status: "Inactive", variant_status: "Inactive" },
  { product_id: "SP-1020", product_name: "Balo laptop City Explorer", category_id: "CAT-ACCESSORY", category_name: "Phụ kiện", store_id: "STORE-MAY", store_name: "Mây Studio", variant_id: "VAR-1020-NV", sku_code: "CITY-NAVY", color: "Navy", size: null, unit_price: 599000, stock: 24, product_status: "Active", variant_status: "Active" },
  { product_id: "SP-1019", product_name: "Loa bluetooth Mini Boom", category_id: "CAT-ELEC", category_name: "Điện tử", store_id: "STORE-TECH", store_name: "Tech House", variant_id: "VAR-1019-BK", sku_code: "BOOM-BLACK", color: "Đen", size: null, unit_price: 790000, stock: 15, product_status: "Active", variant_status: "Active" },
];

const today = new Date();
const localDate = (date) => {
  const adjusted = new Date(date.getTime() - date.getTimezoneOffset() * 60_000);
  return adjusted.toISOString().slice(0, 10);
};
const dateOffset = (daysAgo) => {
  const date = new Date(today);
  date.setDate(date.getDate() - daysAgo);
  return localDate(date);
};

const seedSales = [
  { date: dateOffset(0), store_id: "STORE-TECH", order_id: "ORD-1001", variant_id: "VAR-1024-BK", quantity: 2, price: 1290000, status: "Delivered" },
  { date: dateOffset(1), store_id: "STORE-TECH", order_id: "ORD-1002", variant_id: "VAR-1019-BK", quantity: 1, price: 790000, status: "Delivered" },
  { date: dateOffset(2), store_id: "STORE-HOME", order_id: "ORD-1003", variant_id: "VAR-1023-GN", quantity: 3, price: 259000, status: "Delivered" },
  { date: dateOffset(3), store_id: "STORE-MAY", order_id: "ORD-1004", variant_id: "VAR-1022-M-BK", quantity: 4, price: 189000, status: "Delivered" },
  { date: dateOffset(5), store_id: "STORE-TECH", order_id: "ORD-1005", variant_id: "VAR-1024-WH", quantity: 1, price: 1350000, status: "Delivered" },
  { date: dateOffset(8), store_id: "STORE-HOME", order_id: "ORD-1006", variant_id: "VAR-1023-CR", quantity: 2, price: 259000, status: "Delivered" },
  { date: dateOffset(10), store_id: "STORE-MAY", order_id: "ORD-1007", variant_id: "VAR-1020-NV", quantity: 1, price: 599000, status: "Delivered" },
  { date: dateOffset(12), store_id: "STORE-TECH", order_id: "ORD-1008", variant_id: "VAR-1019-BK", quantity: 2, price: 790000, status: "Delivered" },
  { date: dateOffset(15), store_id: "STORE-HOME", order_id: "ORD-1009", variant_id: "VAR-1023-GN", quantity: 1, price: 259000, status: "Delivered" },
];

function readVariants() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (!saved) return [...seedVariants];
    const parsed = JSON.parse(saved);
    if (!Array.isArray(parsed)) throw new Error("Dữ liệu phân loại trong trình duyệt không hợp lệ.");
    return parsed;
  } catch (error) {
    console.error("Không thể đọc dữ liệu phân loại:", error);
    throw new Error("Không thể tải dữ liệu sản phẩm bản mẫu.");
  }
}

function saveVariants(variants) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(variants));
  } catch (error) {
    console.error("Không thể lưu dữ liệu phân loại:", error);
    throw new Error("Không thể lưu dữ liệu. Kiểm tra dung lượng trình duyệt rồi thử lại.");
  }
}

function filterVariants(rows, filters) {
  const keyword = (filters.keyword ?? "").trim().toLocaleLowerCase("vi");
  return rows.filter((row) => {
    const matchesKeyword = !keyword
      || `${row.product_name} ${row.sku_code}`.toLocaleLowerCase("vi").includes(keyword);
    const matchesCategory = !filters.categoryId || row.category_id === filters.categoryId;
    const matchesStore = !filters.storeId || row.store_id === filters.storeId;
    const matchesStatus = !filters.status || row.product_status === filters.status;
    const matchesMin = filters.minPrice === "" || filters.minPrice == null || row.unit_price >= Number(filters.minPrice);
    const matchesMax = filters.maxPrice === "" || filters.maxPrice == null || row.unit_price <= Number(filters.maxPrice);
    return matchesKeyword && matchesCategory && matchesStore && matchesStatus && matchesMin && matchesMax;
  });
}

export const api = {
  async listProducts(filters = {}) {
    return filterVariants(readVariants(), filters);
  },

  async saveProduct(product) {
    const variants = readVariants();
    const duplicateSku = variants.some((item) =>
      item.sku_code.toLocaleLowerCase("vi") === product.sku_code.toLocaleLowerCase("vi")
      && item.variant_id !== product.variant_id
    );
    if (duplicateSku) throw new Error("Mã SKU đã được sử dụng cho một phân loại khác.");
    const existingIndex = variants.findIndex((item) => item.variant_id === product.variant_id);
    if (existingIndex >= 0) {
      const current = variants[existingIndex];
      for (let index = 0; index < variants.length; index += 1) {
        if (variants[index].product_id === current.product_id) {
          variants[index] = {
            ...variants[index],
            product_name: product.product_name,
            category_id: product.category_id,
            category_name: product.category_name,
            store_id: product.store_id,
            store_name: product.store_name,
            product_status: product.product_status,
          };
        }
      }
      const updatedIndex = variants.findIndex((item) => item.variant_id === product.variant_id);
      variants[updatedIndex] = { ...variants[updatedIndex], ...product };
    } else {
      variants.unshift(product);
    }
    saveVariants(variants);
    return product;
  },

  async deleteProduct(productId) {
    saveVariants(readVariants().filter((variant) => variant.product_id !== productId));
  },

  async getProductOptions() {
    return { categories: categoryOptions, stores: storeOptions };
  },

  async getSalesReport({ fromDate, toDate, sellerType, minRevenue }) {
    const from = new Date(`${fromDate}T00:00:00`);
    const to = new Date(`${toDate}T23:59:59.999`);
    const filtered = seedSales.filter((sale) => {
      const store = storeOptions.find((item) => item.id === sale.store_id);
      return sale.status === "Delivered"
        && new Date(`${sale.date}T12:00:00`) >= from
        && new Date(`${sale.date}T12:00:00`) <= to
        && (!sellerType || store?.sellerType === sellerType);
    });

    const aggregates = new Map();
    for (const sale of filtered) {
      const storeInfo = storeOptions.find((item) => item.id === sale.store_id);
      if (!storeInfo) continue;
      const current = aggregates.get(sale.store_id) ?? {
        store_id: sale.store_id,
        store_name: storeInfo.name,
        seller_type: storeInfo.sellerType,
        total_orders: 0,
        total_items_sold: 0,
        total_revenue: 0,
        orderIds: new Set(),
      };
      current.orderIds.add(sale.order_id);
      current.total_items_sold += sale.quantity;
      current.total_revenue += sale.quantity * sale.price;
      aggregates.set(sale.store_id, current);
    }

    const stores = [...aggregates.values()]
      .map(({ orderIds, ...store }) => ({
        ...store,
        total_orders: orderIds.size,
        avg_revenue_per_order: orderIds.size ? store.total_revenue / orderIds.size : 0,
      }))
      .filter((store) => store.total_revenue >= Number(minRevenue || 0))
      .sort((left, right) => right.total_revenue - left.total_revenue || left.store_name.localeCompare(right.store_name, "vi"));
    const revenue = stores.reduce((sum, store) => sum + store.total_revenue, 0);
    const orderCount = stores.reduce((sum, store) => sum + store.total_orders, 0);

    return {
      revenue,
      orderCount,
      average: orderCount ? revenue / orderCount : 0,
      stores,
      source: "mock",
    };
  },

  async getRestockSuggestion(variantId, days) {
    const variants = readVariants();
    const variant = variants.find((item) => item.variant_id === variantId);
    if (!variant || !Number.isInteger(Number(days)) || Number(days) <= 0) return -1;

    const now = new Date();
    const recentStart = new Date(now);
    recentStart.setDate(now.getDate() - 7);
    const previousStart = new Date(now);
    previousStart.setDate(now.getDate() - 14);
    let recentQuantity = 0;
    let previousQuantity = 0;

    for (const sale of seedSales) {
      if (sale.variant_id !== variantId || sale.status !== "Delivered") continue;
      const saleDate = new Date(`${sale.date}T12:00:00`);
      if (saleDate >= recentStart && saleDate <= now) recentQuantity += sale.quantity;
      else if (saleDate >= previousStart && saleDate < recentStart) previousQuantity += sale.quantity;
    }

    return Math.max(
      0,
      Math.ceil(((recentQuantity * 0.7 + previousQuantity * 0.3) / 7) * Number(days)) - variant.stock,
    );
  },
};

export function newProductIds() {
  const nextNumber = readVariants().reduce((max, variant) => {
    const match = variant.product_id.match(/^SP-(\d+)$/);
    return match ? Math.max(max, Number(match[1])) : max;
  }, 1018) + 1;
  return {
    productId: `SP-${nextNumber}`,
    variantId: `VAR-${nextNumber}-01`,
    sku: `SKU-${nextNumber}-01`,
  };
}
