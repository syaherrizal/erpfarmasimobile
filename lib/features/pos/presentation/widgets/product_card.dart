import 'package:flutter/material.dart';
import '../../data/models/hive/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAdd;

  const ProductCard({super.key, required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onAdd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name & SKU
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.sku,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // price and Action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                border: Border(top: BorderSide(color: Colors.teal.shade100)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rp ${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Stok: ${product.stock}',
                        style: TextStyle(
                          fontSize: 10,
                          color: product.stock < 10
                              ? Colors.red
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.add_circle,
                    color: Color(0xFF0F766E),
                    size: 28,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
