import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/cart.dart';

const String _cartApiBase = 'https://dummyjson.com';

class CartService {
  // Keeps modified carts in memory because DummyJSON does not persist changes made through /carts/add.
  static final Map<int, Cart> _localCarts = {};

  // Base snippet from the activity - fetches every cart in the API.
  Future<List<Cart>> getAllCarts() async {
    final response = await http.get(Uri.parse('$_cartApiBase/carts'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List cartsJson = data['carts'] ?? [];
      return cartsJson.map((json) => Cart.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load carts');
    }
  }

  // Enhancement 3: get the cart(s) belonging to one specific user and return only the first one, so the cart screen renders just one user's cart instead of every cart in the API.

  Future<Cart?> getCartByUserId(int userId) async {
    // Return the locally modified cart if it already exists.
    if (_localCarts.containsKey(userId)) {
      return _localCarts[userId];
    }

    final response =
      await http.get(Uri.parse('$_cartApiBase/carts/user/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List cartsJson = data['carts'] ?? [];

      if (cartsJson.isEmpty) return null;

      final cart = Cart.fromJson(cartsJson.first);

      // Save the original cart locally.
      _localCarts[userId] = cart;

      return cart;
    } else {
      throw Exception('Failed to load cart for user $userId');
    }
  }

  // Enhancement 3: add product(s) to a cart for a given user.
  Future<Cart> addToCart(
    int userId,
    List<Map<String, dynamic>> products,
  ) async {
    final response = await http.post(
      Uri.parse('$_cartApiBase/carts/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'products': products}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final Cart addedCart = Cart.fromJson(data);

      Cart? currentCart = _localCarts[userId];

      // Get the existing cart if we haven't loaded it yet.
      if (currentCart == null) {
        currentCart = await getCartByUserId(userId);
      }

      // If there is no existing cart, use the cart returned by DummyJSON.
      if (currentCart == null) {
        _localCarts[userId] = addedCart;
        return addedCart;
      }

      final List<CartProduct> updatedProducts = [...currentCart.products];

      // Add the products returned by DummyJSON to our local cart.
      for (final addedProduct in addedCart.products) {
        final existingIndex = updatedProducts.indexWhere(
          (product) => product.id == addedProduct.id,
        );

        if (existingIndex != -1) {
          final existingProduct = updatedProducts[existingIndex];

          final newQuantity = existingProduct.quantity + addedProduct.quantity;

          final total = existingProduct.price * newQuantity;

          final discountedTotal =
              total * (1 - existingProduct.discountPercentage / 100);

          updatedProducts[existingIndex] = CartProduct(
            id: existingProduct.id,
            title: existingProduct.title,
            price: existingProduct.price,
            quantity: newQuantity,
            total: total,
            discountPercentage: existingProduct.discountPercentage,
            discountedTotal: discountedTotal,
            thumbnail: existingProduct.thumbnail,
          );
        } else {
          updatedProducts.add(addedProduct);
        }
      }

      return _saveUpdatedCart(currentCart, updatedProducts, userId);
    } else {
      throw Exception('Failed to add products to cart');
    }
  }

  // Updates the quantity of an existing product locally.
  Future<Cart?> updateQuantity(
    int userId,
    int productId,
    int newQuantity,
  ) async {
    final currentCart = _localCarts[userId];

    if (currentCart == null) {
      return null;
    }

    // Remove the product when its quantity reaches 0.
    final updatedProducts = currentCart.products
        .where((product) => product.id != productId || newQuantity > 0)
        .map((product) {
          if (product.id == productId) {
            final total = product.price * newQuantity;

            final discountedTotal =
                total * (1 - product.discountPercentage / 100);

            return CartProduct(
              id: product.id,
              title: product.title,
              price: product.price,
              quantity: newQuantity,
              total: total,
              discountPercentage: product.discountPercentage,
              discountedTotal: discountedTotal,
              thumbnail: product.thumbnail,
            );
          }

          return product;
        })
        .toList();

    return _saveUpdatedCart(currentCart, updatedProducts, userId);
  }

  Cart _saveUpdatedCart(
    Cart currentCart,
    List<CartProduct> updatedProducts,
    int userId,
  ) {
    double total = 0;
    double discountedTotal = 0;
    int totalQuantity = 0;

    for (final product in updatedProducts) {
      total += product.total;
      discountedTotal += product.discountedTotal;
      totalQuantity += product.quantity;
    }

    final updatedCart = Cart(
      id: currentCart.id,
      products: updatedProducts,
      total: total,
      discountedTotal: discountedTotal,
      userId: userId,
      totalProducts: updatedProducts.length,
      totalQuantity: totalQuantity,
    );

    _localCarts[userId] = updatedCart;

    return updatedCart;
  }
}