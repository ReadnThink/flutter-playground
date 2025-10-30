import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../screens/product_list_screen.dart';

/// 장바구니 화면
/// 사용자가 장바구니에 담은 상품들을 확인하고 관리할 수 있는 화면
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  /// 상품 목록 화면과 동일한 샘플 데이터
  static const List<Product> _sampleProducts = [
    Product(
      id: '1',
      name: '아이폰 15 Pro',
      price: 1500000,
      imageUrl: 'assets/images/iphone15pro.jpg',
      description: '최신 아이폰 15 Pro입니다.',
    ),
    Product(
      id: '2',
      name: '갤럭시 S24',
      price: 1200000,
      imageUrl: 'assets/images/galaxy_s24.jpg',
      description: '삼성 갤럭시 S24입니다.',
    ),
    Product(
      id: '3',
      name: '맥북 에어 M3',
      price: 2000000,
      imageUrl: 'assets/images/macbook_air_m3.jpg',
      description: '애플 맥북 에어 M3입니다.',
    ),
    Product(
      id: '4',
      name: '에어팟 프로',
      price: 350000,
      imageUrl: 'assets/images/airpods_pro.jpg',
      description: '애플 에어팟 프로입니다.',
    ),
    Product(
      id: '5',
      name: '아이패드 프로',
      price: 1200000,
      imageUrl: 'assets/images/ipad_pro.jpg',
      description: '애플 아이패드 프로입니다.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 바텀 네비게이션에서 사용하므로 앱바 제거
      // 장바구니 내용을 보여주는 바디
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          // 장바구니가 비어있는 경우
          if (cartProvider.totalItems == 0) {
            return _EmptyCartWidget();
          }

          // 장바구니에 상품이 있는 경우
          final cartDetails = cartProvider.getCartDetails(_sampleProducts);
          final totalPrice = cartProvider.getTotalPrice(_sampleProducts);

          return Column(
            children: [
              // 장바구니 상품 목록
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartDetails.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartDetails[index];
                    return _CartItemCard(
                      product: cartItem['product'] as Product,
                      quantity: cartItem['quantity'] as int,
                      totalPrice: cartItem['totalPrice'] as double,
                    );
                  },
                ),
              ),

              // 하단 총 가격 및 결제 버튼
              _CartBottomBar(totalPrice: totalPrice),
            ],
          );
        },
      ),
    );
  }
}

/// 장바구니가 비어있을 때 보여주는 위젯
class _EmptyCartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 빈 장바구니 아이콘
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),

          // 안내 메시지
          Text(
            '장바구니가 비어있습니다',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),

          Text(
            '상품을 추가해보세요!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),

          // 상품 목록으로 이동하는 버튼
          ElevatedButton.icon(
            onPressed: () {
              // 바텀 네비게이션을 통해 상품 목록 탭으로 이동
              // MainScreen에서 탭 인덱스를 변경하는 방식으로 처리
              // 실제로는 MainScreen에서 처리됨
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('상품 보러가기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// 장바구니에 담긴 개별 상품을 보여주는 카드 위젯
class _CartItemCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final double totalPrice;

  const _CartItemCard({
    required this.product,
    required this.quantity,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 상품 이미지
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, size: 30, color: Colors.grey),
            ),
            const SizedBox(width: 12),

            // 상품 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상품명
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 단가
                  Text(
                    '₩${product.price.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),

                  // 수량 조절 및 총 가격
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 수량 조절 버튼들
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 수량 감소 버튼
                          IconButton(
                            onPressed: () {
                              context.read<CartProvider>().removeFromCart(
                                product.id,
                              );
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.red,
                            iconSize: 20,
                          ),

                          // 현재 수량
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // 수량 증가 버튼
                          IconButton(
                            onPressed: () {
                              context.read<CartProvider>().addToCart(
                                product.id,
                              );
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            color: Colors.green,
                            iconSize: 20,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 총 가격
                      Text(
                        '총 가격: ₩${totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 상품 완전 삭제 버튼
            IconButton(
              onPressed: () {
                // 삭제 확인 다이얼로그
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('상품 삭제'),
                    content: Text('${product.name}을(를) 장바구니에서 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<CartProvider>().removeItemCompletely(
                            product.id,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

/// 장바구니 하단의 총 가격 및 결제 버튼을 보여주는 위젯
class _CartBottomBar extends StatelessWidget {
  final double totalPrice;

  const _CartBottomBar({required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 총 가격 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '총 가격:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₩${totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 버튼들
          Row(
            children: [
              // 장바구니 비우기 버튼
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // 장바구니 비우기 확인 다이얼로그
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('장바구니 비우기'),
                        content: const Text('장바구니의 모든 상품을 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<CartProvider>().clearCart();
                              Navigator.pop(context);
                            },
                            child: const Text('비우기'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('장바구니 비우기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 결제하기 버튼
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // 결제 완료 스낵바 표시
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('결제가 완료되었습니다!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('결제하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
