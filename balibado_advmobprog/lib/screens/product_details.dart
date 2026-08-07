import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// models
import '../models/product.dart';

// widgets
import '../widgets/custom_text.dart';

// ============================================================
// ENHANCEMENT 2: Product Details Page
// Navigated to from ProductScreen when a product card is tapped.
// Receives the tapped Product object directly (no re-fetching
// needed since ProductScreen already has the full product data).
//
// UPDATE: main image area is now a swipeable gallery covering
// ALL of the product's pictures (thumbnail + images), and tapping
// any picture opens a full-screen viewer to browse them all.
// The price shown here is the same raw product.price used on the
// home/product grid — no separate discount math, so it always
// matches what the user saw when they tapped the card.
// ============================================================
class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late final List<String> _gallery;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Combine thumbnail + images into one deduplicated gallery list.
    // This shows every REAL picture the API actually returned for this
    // product -- no duplicates, no fake "extra angles". If a product
    // only has one photo on the backend, that's all we show; we don't
    // fabricate additional angles that don't exist.
    final combined = <String>[
      if (widget.product.thumbnail.isNotEmpty) widget.product.thumbnail,
      ...widget.product.images,
    ];
    _gallery = combined.toSet().toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Opens a full-screen, pinch-to-zoom, swipeable viewer starting
  // at whichever picture was tapped.
  void _openFullScreenGallery(int startIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenGallery(
          images: _gallery,
          initialIndex: startIndex,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final bool hasDiscount = product.discountPercentage > 0;

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        automaticallyImplyLeading: true, // back button to ProductScreen
        title: CustomText(
          text: product.title,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- Main swipeable image gallery ----------------
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 260.h,
                    child: _gallery.isEmpty
                        ? Icon(Icons.image, size: 48.sp)
                        : PageView.builder(
                            controller: _pageController,
                            itemCount: _gallery.length,
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                            },
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                // Tap the big picture to view all pictures full-screen.
                                onTap: () => _openFullScreenGallery(index),
                                child: Image.network(
                                  _gallery[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) =>
                                      Icon(Icons.image, size: 48.sp),
                                ),
                              );
                            },
                          ),
                  ),
                  // Picture counter badge, e.g. "2 / 5"
                  if (_gallery.length > 1)
                    Positioned(
                      right: 12.w,
                      bottom: 12.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: CustomText(
                          text: '${_currentPage + 1} / ${_gallery.length}',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              // ---------------- Thumbnail strip (tap = jump + view all) ----------------
              if (_gallery.length > 1)
                SizedBox(
                  height: 80.h,
                  child: ListView.separated(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    scrollDirection: Axis.horizontal,
                    itemCount: _gallery.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      final bool isSelected = index == _currentPage;
                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          );
                        },
                        onLongPress: () => _openFullScreenGallery(index),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Image.network(
                              _gallery[index],
                              width: 80.w,
                              height: 80.h,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.image, size: 24.sp),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              // Honest fallback: if the API only gave us one real photo
              // for this product, say so instead of implying there are
              // more angles to browse.
              else if (_gallery.length == 1)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: CustomText(
                    text: 'Only one photo available for this product.',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + brand
                    CustomText(
                      text: product.title,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 4.h),
                    if (product.brand.isNotEmpty)
                      CustomText(
                        text: product.brand,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                      ),

                    SizedBox(height: 12.h),

                    // ---------------- Price ----------------
                    // Shows the SAME product.price used on the home/product
                    // grid card, so the price here always matches what the
                    // user saw before tapping. Discount %, if any, is shown
                    // as a secondary badge only -- it does not change the
                    // headline price.
                    Row(
                      children: [
                        CustomText(
                          text: '\$${product.price.toStringAsFixed(2)}',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        if (hasDiscount) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(),
                            ),
                            child: CustomText(
                              text:
                                  '-${product.discountPercentage.toStringAsFixed(0)}%',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // Rating + stock + availability
                    Row(
                      children: [
                        Icon(Icons.star, size: 16.sp, color: Colors.amber),
                        SizedBox(width: 4.w),
                        CustomText(
                          text: product.rating.toStringAsFixed(1),
                          fontSize: 13.sp,
                        ),
                        SizedBox(width: 16.w),
                        CustomText(
                          text: '${product.stock} in stock',
                          fontSize: 13.sp,
                        ),
                        SizedBox(width: 16.w),
                        CustomText(
                          text: product.availabilityStatus,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),

                    Divider(height: 32.h),

                    // Description
                    CustomText(
                      text: 'Description',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      text: product.description,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                    ),

                    Divider(height: 32.h),

                    // Details table (category, sku, weight, dimensions, tags)
                    CustomText(
                      text: 'Product Details',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 8.h),
                    _detailRow('Category', product.category),
                    _detailRow('SKU', product.sku),
                    _detailRow('Weight', '${product.weight} kg'),
                    _detailRow(
                      'Dimensions',
                      '${product.dimensions.width} x '
                      '${product.dimensions.height} x '
                      '${product.dimensions.depth} cm',
                    ),
                    if (product.tags.isNotEmpty)
                      _detailRow('Tags', product.tags.join(', ')),
                    _detailRow('Min. Order Qty', '${product.minimumOrderQuantity}'),
                    _detailRow('Warranty', product.warrantyInformation),
                    _detailRow('Shipping', product.shippingInformation),
                    _detailRow('Return Policy', product.returnPolicy),
                    if (product.meta.barcode.isNotEmpty)
                      _detailRow('Barcode', product.meta.barcode),

                    Divider(height: 32.h),

                    // Reviews
                    CustomText(
                      text: 'Reviews (${product.reviews.length})',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 8.h),
                    if (product.reviews.isEmpty)
                      CustomText(
                        text: 'No reviews yet.',
                        fontSize: 13.sp,
                      )
                    else
                      Column(
                        children: product.reviews.map((review) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CustomText(
                                      text: review.reviewerName,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    SizedBox(width: 8.w),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < review.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 12.sp,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                CustomText(
                                  text: review.comment,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Small helper for the label/value detail rows.
  Widget _detailRow(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: CustomText(
              text: label,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: CustomText(
              text: value,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Full-screen picture viewer: shows ALL of the product's pictures,
// swipeable, with pinch-to-zoom on each one via InteractiveViewer.
// ============================================================
class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const _FullScreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: CustomText(
          text: '${_index + 1} / ${widget.images.length}',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: Image.network(
                widget.images[i],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image,
                  size: 48.sp,
                  color: Colors.white54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}