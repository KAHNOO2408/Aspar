import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../widgets/custom_app_bar.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(title: 'انبار محصولات', context: context),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey[200]),
                  const SizedBox(height: 20),
                  const Text('هنوز محصولی ثبت نشده', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('از صفحه‌ی «خرید/فروش» محصول اضافه کن', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
              final stock = provider.getStock(product.id!);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: stock > 0 ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.inventory_2, color: stock > 0 ? Colors.green : Colors.red),
                  ),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  trailing: Text(
                    stock > 0 ? '${stock.toStringAsFixed(0)} عدد' : 'موجود نیست',
                    style: TextStyle(fontWeight: FontWeight.w800, color: stock > 0 ? Colors.green : Colors.red),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
