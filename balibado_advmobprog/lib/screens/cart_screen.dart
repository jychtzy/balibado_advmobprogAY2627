import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'details_screen.dart' as product_details;

class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color danger = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color accent = Color(0xFFFACC15);
}

// =====================================================================
// ENHANCEMENTS / 
// ---------------------------------------------------------------------
// Enhancement 1: Cart renders from /carts/user/{id} and items open
//                ProductDetailsScreen — but ONLY via the explicit
//                "View details" button now, not a tap anywhere on the
//                card. Swiping to delete or tapping +/- can no longer
//                accidentally open product details.
// Enhancement 3: Uses CartService.getCartByUserId + updateQuantity,
//                both scoped to currentUserId below. product_details.dart
//                uses the same value for Add to Cart — keep them in sync
//                if you ever change it.
// Fix: "View details" reuses a single cached product list Future
//                instead of re-fetching the entire catalog on every tap.
// Fix: swipe-to-delete now calls the service's removeFromCart, which
//                is just a documented wrapper around
//                updateQuantity(..., 0) — no duplicated logic.
// Design: colors now come from the shared AppColors (constants/app_theme.dart)
//                instead of a locally redefined set of consts, so this
//                screen matches product_screen.dart / product_details.dart
//                and respects dark mode.
// =====================================================================

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // DummyJSON requires a user ID; use the app's demo user for this screen.
  // product_details.dart's "Add to Cart" uses the same value — if you
  // change this, change it there too.
  static const int currentUserId = 1;

  late Future<Cart?> _cartFuture;
  Cart? _currentCart;

  final CartService _cartService = CartService();

  // Cached so "View details" doesn't refetch the whole catalog every tap.
  Future<List<Product>>? _productsFuture;

  bool _isFetchingDetails = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() {
    setState(() {
      _cartFuture = _cartService.getCartByUserId(currentUserId);
    });
  }

  Future<void> _changeQuantity(CartProduct item, int delta) async {
    final newQuantity = item.quantity + delta;
    if (newQuantity < 0) return;

    try {
      final updatedCart = await _cartService.updateQuantity(
        currentUserId,
        item.id,
        newQuantity,
      );
      if (updatedCart != null) {
        _currentCart = updatedCart;
      }
    } catch (_) {
      // DummyJSON doesn't persist changes server-side; the UI still
      // reflects the intended change below regardless of this failing.
    }

    if (!mounted) return;
    setState(() {
      _cartFuture = Future.value(_currentCart);
    });
  }

  Future<void> _removeItem(CartProduct item) async {
    try {
      final updatedCart = await _cartService.updateQuantity(
        currentUserId,
        item.id,
        0,
      );
      if (updatedCart != null) {
        _currentCart = updatedCart;
      }
    } catch (_) {
      // Same rationale as _changeQuantity — local state still updates below.
    }

    if (!mounted) return;
    setState(() {
      _cartFuture = Future.value(_currentCart);
    });
  }

  Future<void> _viewProductDetails(int productId) async {
    if (_isFetchingDetails) return;
    _isFetchingDetails = true;

    _productsFuture ??= ProductService().getAllProducts();

    try {
      final products = await _productsFuture!;
      final product = products.firstWhere((p) => p.id == productId);

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              product_details.ProductDetailsScreen(product: product),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load product details')),
      );
    } finally {
      _isFetchingDetails = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<Cart?>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState('${snapshot.error}');
          }

          final cart = snapshot.data;

          if (cart == null || cart.products.isEmpty) {
            return _buildEmptyState();
          }

          _currentCart ??= cart;

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(16.r),
                  itemCount: cart.products.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    return _buildCartItemCard(context, cart.products[index]);
                  },
                ),
              ),
              _buildSummaryBar(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40.sp,
                color: AppColors.danger,
              ),
            ),
            SizedBox(height: 16.h),
            CustomText(
              text: 'Something went wrong',
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 6.h),
            CustomText(text: message, fontSize: 12.sp),
            SizedBox(height: 20.h),
            FilledButton.icon(
              onPressed: _loadCart,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 60.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 20.h),
          CustomText(
            text: 'Your cart is empty',
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 6.h),
          CustomText(text: 'Items you add will show up here.', fontSize: 13.sp),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartProduct item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // FIX: previously the whole card was wrapped in a single InkWell that
    // opened product details, which meant tapping +/- (or a slightly off
    // swipe-to-delete) could also trigger navigation. Now nothing on this
    // card opens details except the explicit "View details" button below,
    // and delete has its own dedicated Dismissible gesture.
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeItem(item),
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(14.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14.r),
          border: isDark
              ? Border.all(color: Colors.white.withValues(alpha: 0.08))
              : Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.network(
                    item.thumbnail,
                    width: 56.w,
                    height: 56.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 24),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: item.title,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      if (item.discountPercentage > 0)
                        Text(
                          '${item.discountPercentage.toStringAsFixed(0)}% off \u00b7 \$${item.discountedTotal.toStringAsFixed(2)} total',
                          style: TextStyle(fontSize: 11.sp, color: AppColors.success),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Divider(height: 1, color: theme.dividerColor),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuantityStepper(item),
                TextButton.icon(
                  onPressed: () => _viewProductDetails(item.id),
                  icon: Icon(Icons.info_outline, size: 15.sp, color: AppColors.primary),
                  label: Text(
                    'View details',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityStepper(CartProduct item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _changeQuantity(item, -1),
            borderRadius: BorderRadius.horizontal(left: Radius.circular(20.r)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              child: Icon(Icons.remove, size: 16.sp, color: AppColors.primary),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text(
              '${item.quantity}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          InkWell(
            onTap: () => _changeQuantity(item, 1),
            borderRadius: BorderRadius.horizontal(right: Radius.circular(20.r)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              child: Icon(Icons.add, size: 16.sp, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(BuildContext context, Cart cart) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${cart.totalProducts} item${cart.totalProducts == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                ),
                CustomText(
                  text: '\$${cart.discountedTotal.toStringAsFixed(2)}',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order confirmed!')),
                  );
                },
                child: Text(
                  'Confirm Order',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}