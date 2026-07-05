import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../models/product_model.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';

class ProductHistoryScreen extends StatelessWidget {
  final Product product;
  const ProductHistoryScreen({Key? key, required this.product}) : super(key: key);

  String _formatJalali(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: Text('تاریخچه‌ی ${product.name}')),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final stock = provider.getStock(product.id!);
          final history = provider.getHistoryForProduct(product.id!);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)]), boxShadow: [BoxShadow(color: const Color(0xFF2B3FBE).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('موجودی فعلی', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 6),
                          Text('${stock.toStringAsFixed(0)} عدد', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 28)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.card(context), shape: BoxShape.circle), child: Icon(Icons.receipt_long, size: 50, color: AppColors.textMuted(context))),
                            const SizedBox(height: 18),
                            Text('هیچ خرید یا فروشی ثبت نشده', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 15)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final tx = history[index];
                          final isPurchase = tx.type == ProductTxType.purchase;
                          final gradient = isPurchase ? const [Color(0xFFFF7A59), Color(0xFFE64A19)] : const [Color(0xFF11998E), Color(0xFF38EF7D)];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), borderRadius: BorderRadius.circular(8)), child: Icon(isPurchase ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: Colors.white, size: 14)),
                                          const SizedBox(width: 8),
                                          Text(isPurchase ? 'خرید' : 'فروش', style: TextStyle(fontWeight: FontWeight.w700, color: gradient[1])),
                                        ],
                                      ),
                                      Text(_formatJalali(tx.date), style: TextStyle(fontSize: 11, color: AppColors.textMuted(context))),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if (tx.contactName != null && tx.contactName!.isNotEmpty) ...[
                                    Text('مخاطب: ${tx.contactName}', style: TextStyle(fontSize: 13, color: AppColors.text(context), fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                  ],
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('تعداد: ${tx.quantity.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
                                      Text('قیمت واحد: ${formatAmount(tx.pricePerUnit)}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
                                      Text('مبلغ کل: ${formatAmount(tx.totalAmount)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text(context))),
                                    ],
                                  ),
                                  if (!isPurchase) ...[
                                    const SizedBox(height: 6),
                                    Text('سود: ${formatAmount(tx.profit)} تومان', style: const TextStyle(fontSize: 12, color: Color(0xFF2B3FBE), fontWeight: FontWeight.w700)),
                                  ],
                                ],
                              ),
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
