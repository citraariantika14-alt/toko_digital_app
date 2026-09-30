import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../models/product.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _priceController = TextEditingController();
  String _category = 'Alat Tulis';

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF154D37);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Tambah Produk Baru'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (val) => val == null || val.isEmpty ? 'Isi nama produk' : null,
              ),
              TextFormField(
                controller: _subtitleController,
                decoration: const InputDecoration(labelText: 'Deskripsi / Subtitle'),
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                validator: (val) => val == null || val.isEmpty ? 'Isi harga' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                items: ['Alat Tulis', 'Buku', 'Aksesoris']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _category = val!),
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newProduct = Product(
                id: 0,
                name: _nameController.text,
                subtitle: _subtitleController.text,
                price: int.parse(_priceController.text),
                category: _category,
                image: 'assets/images/notebook.png',
              );
              Provider.of<ShopProvider>(context, listen: false).addProduct(newProduct);
              Navigator.pop(context);
            }
          },
          child: const Text('Simpan', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}