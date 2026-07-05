import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/app_colors.dart';
import 'product_history_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  final List<List<Color>> _gradients = const [
    [Color(0xFF4F6BF5), Color(0xFF2B3FBE)],
    [Color(0xFF00C6A9), Color(0xFF00897B)],
    [Color(0xFFFF7A59), Color(0xFFE64A19)],
    [Color(0xFF9B6DFF), Color(0xFF6A3DE8)],
    [Color(0xFFFF5C8A), Color(0xFFD81B60)],
  ];

  void _showEditDialog(BuildContext context, ProductProvider provider, Product product) {
    final controller = TextEditingController(text: product.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('ویرایش نام محصول', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
        content: TextField(controller: controller, style: TextStyle(color: AppColors.text(context)), decoration: InputDecoration(labelText: 'نام محصول', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await provider.updateProductName(product, controller.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3FBE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('ذخیره', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: buildCustomAppBar(title: 'انبار محصولات', context: context),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.card(context), shape: BoxShape.circle), child: Icon(Icons.inventory_2_outlined, size: 55, color: AppColors.textMuted(context))),
                  const SizedBox(height: 20),
                  Text('هنوز محصولی ثبت نشده', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('از صفحه‌ی «خرید/فروش» محصول اضافه کن', style: TextStyle(color: AppColors.textMuted(context), fontSize: 12)),
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
              final gradient = _gradients[index % _gradients.length];
              final available = stock > 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(18),
                  elevation: 2,
                  shadowColor: Colors.black12,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductHistoryScreen(product: product))),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), gradient: LinearGradient(colors: available ? gradient : [Colors.grey.shade400, Colors.grey.shade500], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                            child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Text(product.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.text(context)))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: available ? const Color(0xFF11998E).withOpacity(0.12) : const Color(0xFFE64A19).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                            child: Text(available ? '${stock.toStringAsFixed(0)} عدد' : 'موجود نیست', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: available ? const Color(0xFF11998E) : const Color(0xFFE64A19))),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: AppColors.textMuted(context)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            onSelected: (value) {
                              if (value == 'edit') _showEditDialog(context, provider, product);
                              if (value == 'history') Navigator.push(context, MaterialPageRoute(builder: (_) => ProductHistoryScreen(product: product)));
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'history', child: Row(children: [Icon(Icons.history, size: 18, color: Colors.indigo), SizedBox(width: 8), Text('مشاهده تاریخچه')])),
                              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18, color: Colors.blue), SizedBox(width: 8), Text('ویرایش نام')])),
                            ],
                          ),
                        ],
                      ),
                    ),
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
