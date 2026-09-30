import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../helpers/db_helper.dart';

class ShopProvider with ChangeNotifier {
  List<Product> _products = [];
  List<CartItem> _cartItems = [];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  bool _isLoading = false;

  final DBHelper _dbHelper = DBHelper();

  // CONSTRUCTOR: Otomatis memuat data saat Provider pertama kali dijalankan
  ShopProvider() {
    loadData();
  }

  // GETTERS
  List<Product> get products => _products;
  List<CartItem> get cartItems => _cartItems;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<Product> get filteredProducts {
    return _products.where((prod) {
      bool matchesCategory = (_selectedCategory == 'Semua') ||
          (prod.category.toLowerCase() == _selectedCategory.toLowerCase());
      bool matchesSearch = prod.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get totalCartCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  // --- 1. LOAD DATA FROM DB ---
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _products = await _dbHelper.getProducts();
    _cartItems = await _dbHelper.getCartItems();

    _isLoading = false;
    notifyListeners();
  }

  // --- 2. FITUR TAMBAH PRODUK BARU (KATALOG) ---
  Future<void> addProduct(Product product) async {
    await _dbHelper.addProduct(product);
    await loadData();
  }

  // --- 3. FITUR KERANJANG (Dua Nama Fungsi Agar Tidak Error) ---
  Future<void> addToCart(Product product) async {
    await _dbHelper.addToCart(product);
    _cartItems = await _dbHelper.getCartItems();
    notifyListeners();
  }

  // Alias jika UI memanggil addItem
  Future<void> addItem(Product product) async {
    await addToCart(product);
  }

  // --- 4. UBAH KUANTITAS KERANJANG ---
  Future<void> updateQuantity(int cartId, int newQty) async {
    await _dbHelper.updateQuantity(cartId, newQty);
    _cartItems = await _dbHelper.getCartItems();
    notifyListeners();
  }

  // Alias untuk tombol Tambah (+) di UI
  Future<void> incrementQuantity(int cartId) async {
    int index = _cartItems.indexWhere((item) => item.id == cartId);
    if (index != -1) {
      await updateQuantity(cartId, _cartItems[index].quantity + 1);
    }
  }

  // Alias untuk tombol Kurang (-) di UI
  Future<void> decrementQuantity(int cartId) async {
    int index = _cartItems.indexWhere((item) => item.id == cartId);
    if (index != -1) {
      await updateQuantity(cartId, _cartItems[index].quantity - 1);
    }
  }

  // --- 5. HAPUS ITEM KERANJANG ---
  Future<void> removeFromCart(int cartId) async {
    await _dbHelper.removeFromCart(cartId);
    _cartItems = await _dbHelper.getCartItems();
    notifyListeners();
  }

  // Alias jika UI memanggil removeItem / deleteItem
  Future<void> removeItem(int cartId) async {
    await removeFromCart(cartId);
  }

  Future<void> clearCart() async {
    await _dbHelper.clearCart();
    _cartItems = await _dbHelper.getCartItems();
    notifyListeners();
  }

  // --- 6. FILTER & SEARCH ---
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // FORMAT RUPIAH
  static String formatRupiah(int amount) {
    String str = amount.toString();
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      count++;
      result = str[i] + result;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return 'Rp $result';
  }
}