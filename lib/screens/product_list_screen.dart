import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
// '상품 목록' 화면에서 장바구니 추가 시 로컬 알림을 띄우기 위해 서비스 사용
import '../services/notification_service.dart';

/// 상품 목록을 보여주는 화면
/// 사용자가 상품을 보고 장바구니에 추가할 수 있는 메인 화면
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  /// 연습용 샘플 상품 데이터
  /// 실제 앱에서는 API나 데이터베이스에서 가져옴
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
      // 상품 목록을 보여주는 리스트뷰
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sampleProducts.length,
        itemBuilder: (context, index) {
          final product = _sampleProducts[index];
          return _ProductCard(product: product);
        },
      ),
    );
  }
}

/// 개별 상품을 보여주는 카드 위젯
/// 상품 정보와 장바구니 추가 버튼을 포함
class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 이미지 (실제로는 이미지 위젯 사용)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // 상품명
            Text(
              product.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 상품 설명
            Text(
              product.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),

            // 가격과 장바구니 추가 버튼을 한 줄에 배치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 가격 표시
                Expanded(
                  child: Text(
                    '₩${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),

                // 장바구니 추가 버튼
                Flexible(
                  child: Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      final isInCart = cartProvider.isInCart(product.id);
                      final quantity = cartProvider.getQuantity(product.id);

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 수량 조절 버튼들 (장바구니에 있는 경우)
                          if (isInCart) ...[
                            // 수량 감소 버튼
                            IconButton(
                              onPressed: () {
                                cartProvider.removeFromCart(product.id);
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                              color: Colors.red,
                            ),
                            // 현재 수량 표시
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // 수량 증가 버튼
                            IconButton(
                              onPressed: () async {
                                cartProvider.addToCart(product.id);
                                await NotificationService.instance
                                    .showAddedToCart(
                                      productName: product.name,
                                      quantity: cartProvider.getQuantity(
                                        product.id,
                                      ),
                                    );
                                // 백그라운드/앱종료 동작 확인용: 10초 뒤 예약 알림
                                await NotificationService.instance
                                    .scheduleAddedToCartIn10Seconds(
                                      productName: product.name,
                                      quantity: cartProvider.getQuantity(
                                        product.id,
                                      ),
                                    );
                              },
                              icon: const Icon(Icons.add_circle_outline),
                              color: Colors.green,
                            ),
                          ] else
                            // 장바구니 추가 버튼 (처음 추가할 때)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  cartProvider.addToCart(product.id);
                                  await NotificationService.instance
                                      .showAddedToCart(
                                        productName: product.name,
                                        quantity: cartProvider.getQuantity(
                                          product.id,
                                        ),
                                      );
                                  // 백그라운드/앱종료 동작 확인용: 10초 뒤 예약 알림
                                  await NotificationService.instance
                                      .scheduleAddedToCartIn10Seconds(
                                        productName: product.name,
                                        quantity: cartProvider.getQuantity(
                                          product.id,
                                        ),
                                      );
                                  // 사용자에게 피드백 제공
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${product.name}이(가) 장바구니에 추가되었습니다.',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('장바구니에 추가'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
