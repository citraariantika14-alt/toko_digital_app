import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;
  
  // Storage sementara untuk Chrome / Web Browser
  final List<CartItem> _webCart = [];

  // Data default produk dengan Gambar Assets
  final List<Product> _defaultProducts = [
    Product(
      id: 1,
      name: 'Notebook Linen',
      subtitle: 'A5 • 100 lembar',
      price: 25000,
      category: 'Buku',
      image: 'assets/images/notebook.png',
    ),
    Product(
      id: 2,
      name: 'Pulpen Gel 0.5',
      subtitle: 'Hitam/Blue',
      price: 8000,
      category: 'Alat Tulis',
      image: 'assets/images/bolpoin.png',
    ),
    Product(
      id: 3,
      name: 'Tumbler Daily',
      subtitle: '500 ml • Stainless',
      price: 65000,
      category: 'Aksesoris',
      image: 'assets/images/tumbler.png',
    ),
    Product(
      id: 4,
      name: 'Pouch Canvas',
      subtitle: '20 x 14 cm',
      price: 35000,
      category: 'Aksesoris',
      image: 'assets/images/pouch.png',
    ),
  ];

  Future<Database?> get database async {
    if (kIsWeb) return null; // Jika di Chrome Web, gunakan memori _webCart
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'toko_digital.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel 1: master_products (Sesuai LKPD 4)
    await db.execute('''
      CREATE TABLE master_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        subtitle TEXT,
        price INTEGER,
        category TEXT,
        image TEXT
      )
    ''');

    // Tabel 2: local_cart (Sesuai LKPD 4)
    await db.execute('''
      CREATE TABLE local_cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        name TEXT,
        subtitle TEXT,
        price INTEGER,
        quantity INTEGER,
        image TEXT
      )
    ''');

    for (var prod in _defaultProducts) {
      await db.insert('master_products', prod.toMap());
    }
  }

  // --- QUERY PRODUK ---
  Future<List<Product>> getProducts() async {
    if (kIsWeb) {
      return _defaultProducts;
    }
    try {
      final db = await database;
      if (db == null) return _defaultProducts;
      final List<Map<String, dynamic>> maps = await db.query('master_products');
      if (maps.isEmpty) return _defaultProducts;
      return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
    } catch (e) {
      return _defaultProducts;
    }
  }

  Future<void> addProduct(Product product) async {
    _defaultProducts.add(product);
    if (!kIsWeb) {
      final db = await database;
      if (db != null) await db.insert('master_products', product.toMap());
    }
  }

  // --- QUERY KERANJANG ---
  Future<List<CartItem>> getCartItems() async {
    if (kIsWeb) {
      return List.from(_webCart);
    }
    try {
      final db = await database;
      if (db == null) return _webCart;
      final List<Map<String, dynamic>> maps = await db.query('local_cart');
      return List.generate(maps.length, (i) => CartItem.fromMap(maps[i]));
    } catch (e) {
      return _webCart;
    }
  }

  Future<void> addToCart(Product product) async {
    if (kIsWeb) {
      int index = _webCart.indexWhere((element) => element.productId == product.id);
      if (index != -1) {
        var old = _webCart[index];
        _webCart[index] = CartItem(
          id: old.id,
          productId: old.productId,
          name: old.name,
          subtitle: old.subtitle,
          price: old.price,
          quantity: old.quantity + 1,
          image: old.image,
        );
      } else {
        _webCart.add(CartItem(
          id: DateTime.now().millisecondsSinceEpoch,
          productId: product.id,
          name: product.name,
          subtitle: product.subtitle,
          price: product.price,
          quantity: 1,
          image: product.image,
        ));
      }
      return;
    }

    final db = await database;
    if (db == null) return;
    List<Map<String, dynamic>> existing = await db.query(
      'local_cart',
      where: 'product_id = ?',
      whereArgs: [product.id],
    );

    if (existing.isNotEmpty) {
      int currentQty = existing.first['quantity'] as int;
      await db.update(
        'local_cart',
        {'quantity': currentQty + 1},
        where: 'product_id = ?',
        whereArgs: [product.id],
      );
    } else {
      await db.insert('local_cart', {
        'product_id': product.id,
        'name': product.name,
        'subtitle': product.subtitle,
        'price': product.price,
        'quantity': 1,
        'image': product.image,
      });
    }
  }

  Future<void> updateQuantity(int cartId, int newQuantity) async {
    if (kIsWeb) {
      if (newQuantity <= 0) {
        _webCart.removeWhere((item) => item.id == cartId);
      } else {
        int index = _webCart.indexWhere((item) => item.id == cartId);
        if (index != -1) {
          var old = _webCart[index];
          _webCart[index] = CartItem(
            id: old.id,
            productId: old.productId,
            name: old.name,
            subtitle: old.subtitle,
            price: old.price,
            quantity: newQuantity,
            image: old.image,
          );
        }
      }
      return;
    }

    final db = await database;
    if (db == null) return;
    if (newQuantity <= 0) {
      await db.delete('local_cart', where: 'id = ?', whereArgs: [cartId]);
    } else {
      await db.update(
        'local_cart',
        {'quantity': newQuantity},
        where: 'id = ?',
        whereArgs: [cartId],
      );
    }
  }

  Future<void> removeFromCart(int cartId) async {
    if (kIsWeb) {
      _webCart.removeWhere((item) => item.id == cartId);
      return;
    }

    final db = await database;
    if (db == null) return;
    await db.delete('local_cart', where: 'id = ?', whereArgs: [cartId]);
  }

  Future<void> clearCart() async {
    if (kIsWeb) {
      _webCart.clear();
      return;
    }

    final db = await database;
    if (db == null) return;
    await db.delete('local_cart');
  }
}