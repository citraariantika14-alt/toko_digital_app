import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import 'keranjang_page.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({Key? key}) : super(key: key);

  static const Color hijauTua = Color(0xFF164E38);
  static const Color bgWarna = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgWarna,
      appBar: AppBar(
        backgroundColor: hijauTua,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu_book, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'RuangBelajar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Perlengkapan Belajar & Stationery',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Consumer<ShopProvider>(
            builder: (context, provider, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const KeranjangPage()),
                      );
                    },
                  ),
                  if (provider.totalCartCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${provider.totalCartCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ShopProvider>(
        builder: (context, provider, child) {
          final categories = ['Semua', 'Alat Tulis', 'Buku', 'Aksesoris'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================================================
              // SEARCH BAR, FILTER CHIPS, & SUB-HEADER (LINGKARAN MERAH)
              // =========================================================
              Container(
                color: bgWarna,
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: TextField(
                          onChanged: (value) => provider.setSearchQuery(value),
                          decoration: const InputDecoration(
                            hintText: 'Cari produk...',
                            hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                            prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2. Filter Kategori Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected =
                              provider.selectedCategory.toLowerCase() == cat.toLowerCase();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight:
                                      isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: hijauTua,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? hijauTua : Colors.grey[300]!,
                                ),
                              ),
                              onSelected: (_) {
                                provider.setSelectedCategory(cat);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. Header Sub-bagian "Produk Pilihan" & "Lihat Semua >"
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Produk Pilihan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              provider.setSelectedCategory('Semua');
                              provider.setSearchQuery('');
                            },
                            child: Text(
                              'Lihat Semua >',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // =========================================================
              // KATALOG GRID PRODUK (SESUAI GAMBAR REFERENSI)
              // =========================================================
              Expanded(
                child: provider.filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.search_off, size: 60, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'Produk tidak ditemukan',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: provider.filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = provider.filteredProducts[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Gambar Produk
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF2ECE1),
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      child: Image.asset(
                                        product.image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                // Informasi Produk
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        product.subtitle.isNotEmpty
                                            ? product.subtitle
                                            : 'Perlengkapan Belajar',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        ShopProvider.formatRupiah(product.price),
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Tombol Tambah Panjang Sesuai Desain Referensi
                                      SizedBox(
                                        width: double.infinity,
                                        height: 36,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: hijauTua,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.zero,
                                          ),
                                          onPressed: () {
                                            provider.addToCart(product);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${product.name} ditambahkan ke keranjang!',
                                                ),
                                                duration: const Duration(seconds: 1),
                                                backgroundColor: hijauTua,
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.add_shopping_cart,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            'Tambah',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}