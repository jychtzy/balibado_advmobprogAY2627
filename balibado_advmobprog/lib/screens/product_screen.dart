import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// models
import '../models/product.dart';

// services
import '../services/product_service.dart'; //ENCHANEMENT 2


// widgets
import '../widgets/custom_text.dart';

// screens
import 'product_details.dart' as product_details;

// =====================================================================
// Design: search bar restyled (filled background instead of a plain
// black border, tinted icon, smaller/regular input text instead of
// 20sp bold which was oversized for a search field). Grid cards now
// use the brand indigo below for price so it matches the rest of the app.
// =====================================================================

// Colors used across this screen. cart_screen.dart, product_details.dart,
// and home_screen.dart each define the same values locally.
const Color _kPrimary = Color(0xFF313376); // brand indigo
const Color _kBackground = Color(0xFFF6F6FA);

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final Future<List<Product>> _productsFuture;

  // Holds the current search text
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService().getAllProducts();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ================= ENHANCEMENT 1 =================
  // Filters _allProducts by title as the user types, live.

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kBackground,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: ScreenUtil().screenWidth,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE7E7EE)),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search products',
                    hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: _kPrimary, size: 20.sp),
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 16.h),
              FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.r),
                        child: const CircularProgressIndicator(color: _kPrimary),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: CustomText(
                        text: 'Error: ${snapshot.error}',
                        fontSize: 14.sp,
                      ),
                    );
                  }

                  final allProducts = snapshot.data ?? [];

                  // Filter the fetched products by the search
                  final products = _searchQuery.isEmpty
                      ? allProducts
                      : allProducts.where((p) {
                          final matchesTitle = p.title.toLowerCase().contains(
                            _searchQuery,
                          );
                          final matchesTag = p.tags.any(
                            (tag) => tag.toLowerCase().contains(_searchQuery),
                          );
                          return matchesTitle || matchesTag;
                        }).toList();

                  if (products.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.r),
                        child: Column(
                          children: [
                            Icon(Icons.search_off, size: 40.sp, color: Colors.grey.shade400),
                            SizedBox(height: 10.h),
                            CustomText(
                              text: 'No products found.',
                              fontSize: 14.sp,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          // Tapping the card opens a details page of the product.
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    product_details.ProductDetailsScreen(
                                      product: product,
                                    ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.network(
                                  product.thumbnail,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image, size: 24),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text: product.title,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: _kPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}