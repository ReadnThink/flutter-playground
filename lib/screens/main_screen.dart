import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'product_list_screen.dart';
import 'cart_screen.dart';

/// 바텀 네비게이션 바를 포함한 메인 화면
/// 상품 목록과 장바구니 화면을 탭으로 전환할 수 있음
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 현재 선택된 탭 인덱스 (0: 상품 목록, 1: 장바구니)
  int _currentIndex = 0;

  // 탭별 화면 리스트
  final List<Widget> _screens = [const ProductListScreen(), const CartScreen()];

  // 탭별 제목
  final List<String> _titles = ['상품 목록', '장바구니'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 현재 선택된 탭에 따른 앱바
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        // 장바구니 탭에서는 뒤로가기 버튼 숨기기
        automaticallyImplyLeading: false,
        // 상품 목록 탭에서만 장바구니 아이콘 표시
        actions: _currentIndex == 0 ? [_buildCartIcon()] : null,
      ),

      // 현재 선택된 탭의 화면
      body: _screens[_currentIndex],

      // 바텀 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        // 현재 선택된 탭 인덱스
        currentIndex: _currentIndex,

        // 탭 선택 시 호출되는 콜백
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        // 탭 타입 설정 (고정된 2개 탭)
        type: BottomNavigationBarType.fixed,

        // 선택된 탭의 색상
        selectedItemColor: Colors.blue,

        // 선택되지 않은 탭의 색상
        unselectedItemColor: Colors.grey,

        // 탭 아이템들
        items: [
          // 상품 목록 탭
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag_outlined),
            activeIcon: const Icon(Icons.shopping_bag),
            label: '상품 목록',
          ),

          // 장바구니 탭
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return Stack(
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    // 장바구니에 상품이 있으면 빨간 원으로 개수 표시
                    if (cartProvider.totalItems > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cartProvider.totalItems}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            activeIcon: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return Stack(
                  children: [
                    const Icon(Icons.shopping_cart),
                    // 장바구니에 상품이 있으면 빨간 원으로 개수 표시
                    if (cartProvider.totalItems > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cartProvider.totalItems}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: '장바구니',
          ),
        ],
      ),
    );
  }

  /// 상품 목록 화면의 앱바에 표시할 장바구니 아이콘 위젯
  Widget _buildCartIcon() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Stack(
          children: [
            // 장바구니 아이콘 버튼
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                // 장바구니 탭으로 이동
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            // 장바구니 아이템 개수 표시 (빨간 원)
            if (cartProvider.totalItems > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${cartProvider.totalItems}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
