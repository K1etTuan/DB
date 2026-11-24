const STORAGE_KEY = "shopeedb.products.v1";

const seedProducts = [
  { id: "SP-1024", name: "Tai nghe không dây AirBeat Pro", category: "Điện tử", store: "Tech House", price: 1290000, stock: 42, variants: 3, status: "Đang bán", icon: "🎧", tone: "lavender" },
  { id: "SP-1023", name: "Bình giữ nhiệt Everyday 500ml", category: "Gia dụng", store: "Nhà Xinh", price: 259000, stock: 8, variants: 4, status: "Đang bán", icon: "🧋", tone: "mint" },
  { id: "SP-1022", name: "Áo thun cotton basic unisex", category: "Thời trang", store: "Mây Studio", price: 189000, stock: 126, variants: 8, status: "Đang bán", icon: "👕", tone: "peach" },
  { id: "SP-1021", name: "Đèn bàn LED cảm ứng Lumi", category: "Gia dụng", store: "Nhà Xinh", price: 425000, stock: 0, variants: 2, status: "Tạm ẩn", icon: "💡", tone: "yellow" },
  { id: "SP-1020", name: "Balo laptop City Explorer", category: "Phụ kiện", store: "Mây Studio", price: 599000, stock: 24, variants: 3, status: "Đang bán", icon: "🎒", tone: "blue" },
  { id: "SP-1019", name: "Loa bluetooth Mini Boom", category: "Điện tử", store: "Tech House", price: 790000, stock: 15, variants: 2, status: "Đang bán", icon: "🔊", tone: "pink" },
];

const seedOrders = [
  { id: "DH-2409188", date: "2026-11-17", store: "Tech House", category: "Điện tử", total: 1580000, items: 2, status: "Hoàn thành" },
  { id: "DH-2409187", date: "2026-11-17", store: "Nhà Xinh", category: "Gia dụng", total: 425000, items: 1, status: "Đang giao" },
  { id: "DH-2409186", date: "2026-11-16", store: "Mây Studio", category: "Thời trang", total: 987000, items: 3, status: "Hoàn thành" },
  { id: "DH-2409185", date: "2026-11-15", store: "Tech House", category: "Điện tử", total: 790000, items: 1, status: "Đã hủy" },
  { id: "DH-2409184", date: "2026-11-14", store: "Nhà Xinh", category: "Gia dụng", total: 518000, items: 2, status: "Hoàn thành" },
  { id: "DH-2409183", date: "2026-11-13", store: "Mây Studio", category: "Phụ kiện", total: 599000, items: 1, status: "Hoàn thành" },
  { id: "DH-2409182", date: "2026-11-12", store: "Tech House", category: "Điện tử", total: 1290000, items: 1, status: "Hoàn thành" },
  { id: "DH-2409181", date: "2026-11-10", store: "Nhà Xinh", category: "Gia dụng", total: 780000, items: 2, status: "Hoàn thành" },
  { id: "DH-2409180", date: "2026-11-08", store: "Mây Studio", category: "Thời trang", total: 378000, items: 2, status: "Hoàn thành" },
  { id: "DH-2409179", date: "2026-11-05", store: "Tech House", category: "Điện tử", total: 2190000, items: 2, status: "Hoàn thành" },
];

function readProducts() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (!saved) return [...seedProducts];
    const parsed = JSON.parse(saved);
    if (!Array.isArray(parsed)) throw new Error("Dữ liệu sản phẩm trong trình duyệt không hợp lệ.");
    return parsed;
  } catch (error) {
    console.error("Không thể đọc dữ liệu sản phẩm:", error);
    throw new Error("Không thể tải dữ liệu sản phẩm trên trình duyệt.");
  }
}

function saveProducts(products) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(products));
  } catch (error) {
    console.error("Không thể lưu dữ liệu sản phẩm:", error);
    throw new Error("Không thể lưu dữ liệu. Kiểm tra dung lượng trình duyệt rồi thử lại.");
  }
}

export const api = {
  async listProducts() {
    return readProducts();
  },

  async saveProduct(product) {
    const products = readProducts();
    const existingIndex = products.findIndex((item) => item.id === product.id);
    if (existingIndex >= 0) {
      products[existingIndex] = { ...products[existingIndex], ...product };
    } else {
      products.unshift(product);
    }
    saveProducts(products);
    return product;
  },

  async deleteProduct(id) {
    saveProducts(readProducts().filter((product) => product.id !== id));
  },

  async getSalesReport({ days, store }) {
    const from = new Date("2026-11-17T23:59:59");
    if (days !== "all") from.setDate(from.getDate() - Number(days) + 1);
    const filtered = seedOrders.filter((order) => {
      const inPeriod = days === "all" || new Date(`${order.date}T00:00:00`) >= from;
      const inStore = store === "all" || order.store === store;
      return inPeriod && inStore && order.status === "Hoàn thành";
    });

    const categories = new Map();
    for (const order of filtered) {
      const current = categories.get(order.category) ?? { category: order.category, orders: 0, items: 0, revenue: 0 };
      current.orders += 1;
      current.items += order.items;
      current.revenue += order.total;
      categories.set(order.category, current);
    }

    const revenue = filtered.reduce((sum, order) => sum + order.total, 0);
    return {
      revenue,
      orderCount: filtered.length,
      average: filtered.length ? Math.round(revenue / filtered.length) : 0,
      categories: [...categories.values()].sort((a, b) => b.revenue - a.revenue),
      source: "mock",
    };
  },
};

export function newProductId(products) {
  const maxId = products.reduce((max, product) => {
    const number = Number(product.id.replace(/\D/g, ""));
    return Number.isFinite(number) ? Math.max(max, number) : max;
  }, 1018);
  return `SP-${maxId + 1}`;
}
