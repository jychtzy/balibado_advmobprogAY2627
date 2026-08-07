import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// models
import '../models/product.dart';

// services
import '../services/product_service.dart';

// screens
import 'product_details.dart'; // ENHANCEMENT 2

// widgets
import '../widgets/custom_text.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final Future<List<Product>> _productsFuture;

  // ENHANCEMENT 1: controller that drives the search bar, plus the
  // filtered list that the grid actually renders from.
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService().getAllProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ================= ENHANCEMENT 1 =================
  // Filters _allProducts by title as the user types, live.
  // Also matches against each product's tags (e.g. searching "summer"
  // or "electronics" surfaces products tagged that way even if the
  // word never appears in the title itself).
  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredProducts = query.isEmpty
          ? _allProducts
          : _allProducts.where((p) {
              final matchesTitle = p.title.toLowerCase().contains(query);
              final matchesTag =
                  p.tags.any((tag) => tag.toLowerCase().contains(query));
              return matchesTitle || matchesTag;
            }).toList();
    });
  }
  // ================= END ENHANCEMENT 1 =================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ================= KEYBOARD FIX =================
      // Tapping anywhere outside the search field dismisses the keyboard,
      // instead of leaving it open and pinning the search bar up top.
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= ENHANCEMENT 1 =================
            // Search bar above the product list. Replaces the old
            // static "Search" label with a real, functional TextField
            // that filters the grid live as the user types.
            Container(
              width: ScreenUtil().screenWidth,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search',
                  hintStyle: TextStyle(fontSize: 20.sp),
                  prefixIcon: Icon(Icons.search, size: 20.sp),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: 20.sp),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
                style: TextStyle(fontSize: 20.sp),
              ),
            ),
            // ================= END ENHANCEMENT 1 =================
            SizedBox(height: 16.h),
            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.r),
                      child: const CircularProgressIndicator(),
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

                // Populate _allProducts / _filteredProducts once, the first
                // time data arrives, so the search filter has something to
                // work with without re-fetching on every rebuild.
                if (_allProducts.isEmpty) {
                  _allProducts = snapshot.data ?? [];
                  _filteredProducts = _allProducts;
                }

                if (_filteredProducts.isEmpty) {
                  return Center(
                    child: CustomText(
                      text: 'No products found.',
                      fontSize: 14.sp,
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredProducts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return GestureDetector(
                      // ================= ENHANCEMENT 2 =================
                      // Tapping a card pushes ProductDetailsScreen,
                      // passing the tapped product straight in.
                      //
                      // KEYBOARD FIX: unfocus with `scope` disposition
                      // BEFORE leaving (so the field doesn't stay "primed"
                      // to reclaim focus), AND unfocus again the moment
                      // Navigator.push's Future completes -- i.e. exactly
                      // when the user comes back from the details page.
                      // That second call is what guarantees the keyboard
                      // never reappears on return, no matter what Flutter
                      // tries to restore internally.
                      onTap: () async {
                        FocusScope.of(context)
                            .unfocus(disposition: UnfocusDisposition.scope);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailsScreen(product: product),
                          ),
                        );
                        // We're back from the details page now.
                        if (context.mounted) {
                          FocusScope.of(context).unfocus(
                              disposition: UnfocusDisposition.scope);
                        }
                      },
                      // ================= END ENHANCEMENT 2 =================
                      child: Card(
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Image.network(
                                product.thumbnail,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) =>
                                    Icon(Icons.image, size: 24.sp),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.r),
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
                                  CustomText(
                                    text: '\$${product.price.toStringAsFixed(2)}',
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
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