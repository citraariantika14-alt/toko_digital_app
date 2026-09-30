import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    }
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    IconData iconData = Icons.shopping_bag_outlined;
    if (imagePath.contains('notebook')) iconData = Icons.menu_book_rounded;
    if (imagePath.contains('bolpoin')) iconData = Icons.edit_outlined;
    if (imagePath.contains('tumbler')) iconData = Icons.local_drink_outlined;
    if (imagePath.contains('pouch')) iconData = Icons.account_balance_wallet_outlined;

    return Center(
      child: Icon(
        iconData,
        size: 40,
        color: const Color(0xFF154D37),
      ),
    );
  }
}