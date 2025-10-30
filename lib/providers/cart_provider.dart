import 'package:flutter/foundation.dart';
import '../models/product.dart';

/// 장바구니 상태를 관리하는 Provider 클래스
/// ChangeNotifier를 상속받아 상태 변경 시 UI에 알림을 보냄
class CartProvider extends ChangeNotifier {
  // 장바구니에 담긴 상품들의 리스트
  // Map<상품ID, 수량> 형태로 저장
  final Map<String, int> _cartItems = {};

  /// 장바구니에 담긴 상품들의 Map을 반환
  /// 외부에서 직접 수정할 수 없도록 읽기 전용으로 제공
  Map<String, int> get cartItems => Map.unmodifiable(_cartItems);

  /// 장바구니에 담긴 총 상품 개수
  int get totalItems {
    return _cartItems.values.fold(0, (sum, quantity) => sum + quantity);
  }

  /// 장바구니에 담긴 상품의 총 가격
  /// 상품 리스트를 받아서 계산 (실제 앱에서는 상품 정보를 별도로 관리)
  double getTotalPrice(List<Product> products) {
    double total = 0.0;
    for (String productId in _cartItems.keys) {
      final product = products.firstWhere((p) => p.id == productId);
      total += product.price * _cartItems[productId]!;
    }
    return total;
  }

  /// 특정 상품이 장바구니에 있는지 확인
  bool isInCart(String productId) {
    return _cartItems.containsKey(productId);
  }

  /// 특정 상품의 장바구니 수량 반환
  int getQuantity(String productId) {
    return _cartItems[productId] ?? 0;
  }

  /// 장바구니에 상품 추가
  /// 이미 있는 상품이면 수량 증가, 없으면 새로 추가
  void addToCart(String productId) {
    if (_cartItems.containsKey(productId)) {
      // 이미 장바구니에 있는 상품이면 수량 증가
      _cartItems[productId] = _cartItems[productId]! + 1;
    } else {
      // 새로운 상품이면 수량 1로 추가
      _cartItems[productId] = 1;
    }

    // UI에 상태 변경 알림
    notifyListeners();
  }

  /// 장바구니에서 상품 제거
  /// 수량이 1이면 완전 제거, 1보다 크면 수량 감소
  void removeFromCart(String productId) {
    if (_cartItems.containsKey(productId)) {
      if (_cartItems[productId]! > 1) {
        // 수량이 1보다 크면 1 감소
        _cartItems[productId] = _cartItems[productId]! - 1;
      } else {
        // 수량이 1이면 완전 제거
        _cartItems.remove(productId);
      }

      // UI에 상태 변경 알림
      notifyListeners();
    }
  }

  /// 특정 상품을 장바구니에서 완전히 제거
  void removeItemCompletely(String productId) {
    if (_cartItems.containsKey(productId)) {
      _cartItems.remove(productId);
      notifyListeners();
    }
  }

  /// 장바구니 비우기
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  /// 장바구니에 담긴 상품들의 상세 정보 반환
  /// 실제 앱에서는 이 정보를 사용해 장바구니 화면을 구성
  List<Map<String, dynamic>> getCartDetails(List<Product> products) {
    List<Map<String, dynamic>> cartDetails = [];

    for (String productId in _cartItems.keys) {
      final product = products.firstWhere((p) => p.id == productId);
      cartDetails.add({
        'product': product,
        'quantity': _cartItems[productId]!,
        'totalPrice': product.price * _cartItems[productId]!,
      });
    }

    return cartDetails;
  }
}
