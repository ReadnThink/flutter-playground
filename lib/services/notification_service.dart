import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 로컬 푸시 알림을 간단히 사용하기 위한 싱글턴 서비스
/// - 앱 시작 시 `init()`으로 초기화 및 권한 요청 수행
/// - `showAddedToCart()`로 장바구니 관련 알림 노출
class NotificationService {
  /// 외부에서 인스턴스를 공유해서 쓰기 위한 싱글턴 패턴
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  /// 플러그인 본체. 실제 알림 스케줄/표시를 담당
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Android용 알림 채널 정보 (필수)
  static const String _channelId = 'cart_channel_id';
  static const String _channelName = 'Cart Notifications';
  static const String _channelDescription = 'Notifications for cart actions';

  bool _initialized = false;

  /// 플러그인 초기화 및 권한 요청
  /// - 반드시 `runApp` 이전에 호출되어야 함 (main 함수에서 실행)
  Future<void> init() async {
    if (_initialized) return;

    // 안드로이드: 아이콘 리소스 지정 (@mipmap/ic_launcher)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS: 기본 초기화 설정
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    // 플랫폼별 초기화 설정을 합친 객체
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 플러그인 초기화
    await _plugin.initialize(settings);

    // iOS/Android 권한 요청 (iOS는 런타임, Android는 13+에서 런타임)
    await _requestPermissionsIfNeeded();

    _initialized = true;
  }

  /// 플랫폼별 알림 권한 요청
  Future<void> _requestPermissionsIfNeeded() async {
    // iOS: alert/badge/sound 권한을 개별적으로 요청
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    // Android 13+(Tiramisu) 이상: 런타임 알림 권한 요청
    // 플러그인별 메서드명이 다를 수 있으므로 최신 시그니처 사용
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// 장바구니에 상품이 추가되었을 때 표시할 간단한 즉시 알림
  /// - [productName]: 상품명
  /// - [quantity]: 담긴 수량 (현재 수량)
  Future<void> showAddedToCart({
    required String productName,
    required int quantity,
  }) async {
    // Android 채널/중요도 설정
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        );

    // iOS 기본 설정
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    // 플랫폼별 상세 설정 합치기
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final String title = '장바구니에 추가됨';
    final String body = '$productName (수량: $quantity)';

    // 간단하게 고정 ID 사용. 여러 개를 동시에 쌓고 싶다면 고유 ID 사용 필요
    await _plugin.show(1001, title, body, details);
  }
}
