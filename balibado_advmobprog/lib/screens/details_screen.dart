import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//models
import '../models/product.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';

// =====================================================================
// FIX: "Add to Cart" used to call CartService().addToCart(0, ...) with
// a hard-coded userId of 0, while CartScreen always displays user 1's
// cart (see _kCurrentUserId below). That meant items added here
// silently vanished into a cart nobody could see. Now both screens use
// the same value — if you change one, change the other too.
//
// Design: colors that used to be scattered Colors.amber / theme.colorScheme.primary
// literals now route through the constants below, matching the brand
// indigo + accent used in cart_screen.dart and product_screen.dart.
// =====================================================================

// Colors used across this screen. cart_screen.dart, product_screen.dart,
// and home_screen.dart each define the same values locally.
const Color _kPrimary = Color(0xFF313376); // brand indigo
const Color _kAccent = Color(0xFFF5A623); // CTA amber
const Color _kAccentDark = Color(0xFFC97F00);
const Color _kDanger = Color(0xFFE5484D);

// Must match CartScreen.currentUserId in cart_screen.dart.
const int _kCurrentUserId = 1;

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _imageController = PageController();
  int _currentImageIndex = 0;

  // Combine thumbnail + images into one list so everything is swipeable
  late final List<String> _allImages = [
    widget.product.thumbnail,
    ...widget.product.images.where((img) => img != widget.product.thumbnail),
  ];

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: product.title,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel - edge to edge
            ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28.r),
                bottomRight: Radius.circular(28.r),
              ),
              child: SizedBox(
                height: 260.h,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      controller: _imageController,
                      itemCount: _allImages.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          _allImages[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.image, size: 48),
                          ),
                        );
                      },
                    ),
                    // Soft gradient scrim at the bottom so dot indicators stay visible on any image
                    if (_allImages.length > 1)
                      Container(
                        height: 60.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.35),
                            ],
                          ),
                        ),
                      ),
                    if (_allImages.length > 1)
                      Padding(
                        padding: EdgeInsets.only(bottom: 14.h),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            _allImages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.symmetric(horizontal: 3.w),
                              width: _currentImageIndex == index ? 20.w : 6.w,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: _currentImageIndex == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Floating price + rating card that overlaps the image bottom
            Transform.translate(
              offset: Offset(0, -22.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _card(
                  context,
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CustomText(
                              text: '\$${product.price.toStringAsFixed(2)}',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                            ),
                            if (product.discountPercentage > 0) ...[
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 7.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _kDanger.withValues(
                                    alpha: isDark ? 0.28 : 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: CustomText(
                                  text:
                                      '-${product.discountPercentage.toStringAsFixed(0)}%',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: _kAccent.withOpacity(isDark ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: _kAccentDark,
                            ),
                            SizedBox(width: 3.w),
                            CustomText(
                              text: '${product.rating}',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Negative margin above compensates for the overlap
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
              child: Transform.translate(
                offset: Offset(0, -10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail strip
                    if (_allImages.length > 1) ...[
                      SizedBox(
                        height: 64.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _allImages.length,
                          separatorBuilder: (_, __) => SizedBox(width: 8.w),
                          itemBuilder: (context, index) {
                            final isSelected = _currentImageIndex == index;
                            return GestureDetector(
                              onTap: () {
                                _imageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? _kPrimary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Image.network(
                                    _allImages[index],
                                    width: 60.w,
                                    height: 60.h,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image, size: 24),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // Title + description card
                    _card(
                      context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: product.title,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(height: 8.h),
                          CustomText(
                            text: product.description,
                            fontSize: 14.sp,
                            letterSpacing: 0.1,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Add to Cart button
                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: _kAccent,
                        borderRadius: BorderRadius.circular(12.r),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () async {
                          try {
                            // FIX: was hard-coded to userId 0 — now uses
                            // _kCurrentUserId, matching cart_screen.dart.
                            await CartService().addToCart(_kCurrentUserId, [
                              {'id': product.id, 'quantity': 1},
                            ]);

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${product.title} added to cart!',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to add item to cart'),
                              ),
                            );
                          }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_shopping_cart,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Add to Cart',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Details card
                    _card(
                      context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader(
                            context,
                            Icons.info_outline,
                            'Details',
                          ),
                          SizedBox(height: 12.h),
                          _infoRow(
                            context,
                            Icons.storefront_outlined,
                            'Brand',
                            product.brand,
                          ),
                          _divider(theme),
                          _infoRow(
                            context,
                            Icons.category_outlined,
                            'Category',
                            product.category,
                          ),
                          _divider(theme),
                          _infoRow(
                            context,
                            Icons.qr_code_2_outlined,
                            'SKU',
                            product.sku,
                          ),
                          _divider(theme),
                          _infoRow(
                            context,
                            Icons.inventory_2_outlined,
                            'Stock',
                            '${product.stock}',
                          ),
                          _divider(theme),
                          _infoRow(
                            context,
                            Icons.scale_outlined,
                            'Weight',
                            '${product.weight} g',
                          ),
                          _divider(theme),
                          _infoRow(
                            context,
                            Icons.straighten_outlined,
                            'Dimensions',
                            '${product.dimensions.width} x ${product.dimensions.height} x ${product.dimensions.depth} cm',
                          ),
                          _divider(theme),
                          _infoRow(
                            context,
                            Icons.shopping_bag_outlined,
                            'Min. Order Qty',
                            '${product.minimumOrderQuantity}',
                          ),
                          _divider(theme),
                          _infoRow(
                            context,
                            Icons.check_circle_outline,
                            'Availability',
                            product.availabilityStatus,
                          ),
                        ],
                      ),
                    ),

                    // Tags card
                    if (product.tags.isNotEmpty) ...[
                      SizedBox(height: 14.h),
                      _card(
                        context,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                              context,
                              Icons.sell_outlined,
                              'Tags',
                            ),
                            SizedBox(height: 12.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: product.tags
                                  .map(
                                    (tag) => Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 7.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _kPrimary
                                            .withOpacity(isDark ? 0.25 : 0.1),
                                        borderRadius: BorderRadius.circular(
                                          30.r,
                                        ),
                                      ),
                                      child: CustomText(
                                        text: tag,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 14.h),

                    // Warranty & shipping card
                    _card(
                      context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader(
                            context,
                            Icons.local_shipping_outlined,
                            'Warranty & Shipping',
                          ),
                          SizedBox(height: 12.h),
                          _infoRow(
                            context,
                            Icons.verified_user_outlined,
                            'Warranty',
                            product.warrantyInformation,
                          ),
                          _divider(theme),
                          _infoRow(
                            context,
                            Icons.local_shipping_outlined,
                            'Shipping',
                            product.shippingInformation,
                          ),
                          _divider(theme),
                          _infoRow(
                            context,
                            Icons.replay_outlined,
                            'Return Policy',
                            product.returnPolicy,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Reviews card
                    _card(
                      context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader(
                            context,
                            Icons.reviews_outlined,
                            'Reviews (${product.reviews.length})',
                          ),
                          SizedBox(height: 12.h),
                          if (product.reviews.isEmpty)
                            CustomText(text: 'No reviews yet.', fontSize: 13.sp)
                          else
                            ...product.reviews.map(
                              (review) => Container(
                                margin: EdgeInsets.only(bottom: 10.h),
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest
                                      .withOpacity(isDark ? 0.35 : 0.55),
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 14.r,
                                              backgroundColor:
                                                  _kPrimary.withOpacity(0.15),
                                              child: CustomText(
                                                text:
                                                    review
                                                        .reviewerName
                                                        .isNotEmpty
                                                    ? review.reviewerName[0]
                                                          .toUpperCase()
                                                    : '?',
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            CustomText(
                                              text: review.reviewerName,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: List.generate(
                                            5,
                                            (i) => Icon(
                                              i < review.rating
                                                  ? Icons.star_rounded
                                                  : Icons.star_outline_rounded,
                                              size: 15,
                                              color: _kAccentDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    CustomText(
                                      text: review.comment,
                                      fontSize: 13.sp,
                                    ),
                                    SizedBox(height: 6.h),
                                    CustomText(
                                      text: review.date.split('T').first,
                                      fontSize: 11.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Theme's card style
  Widget _card(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.08))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // Section header with the icon
  Widget _sectionHeader(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: _kPrimary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16.sp, color: _kPrimary),
        ),
        SizedBox(width: 8.w),
        CustomText(text: title, fontSize: 15.sp, fontWeight: FontWeight.bold),
      ],
    );
  }

  // Info row with a small leading icon for quicker visual scanning
  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: theme.iconTheme.color?.withOpacity(0.6),
          ),
          SizedBox(width: 10.w),
          SizedBox(
            width: 100.w,
            child: CustomText(
              text: label,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: CustomText(text: value, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _divider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.dividerColor.withOpacity(0.15),
    );
  }
}