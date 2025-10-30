/// 상품 정보를 담는 모델 클래스
/// 장바구니 앱에서 사용할 상품의 기본 정보를 정의
class Product {
  final String id; // 상품 고유 ID
  final String name; // 상품명
  final double price; // 상품 가격
  final String imageUrl; // 상품 이미지 URL (실제로는 에셋 경로 사용)
  final String description; // 상품 설명

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  /// 상품을 복사하여 새로운 인스턴스를 생성하는 메서드
  /// (현재는 사용하지 않지만 확장성을 위해 포함)
  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }

  /// 상품 정보를 문자열로 변환하는 메서드 (디버깅용)
  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price)';
  }

  /// 두 상품이 같은지 비교하는 메서드
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  /// 해시코드를 생성하는 메서드 (Set, Map에서 사용)
  @override
  int get hashCode => id.hashCode;
}
