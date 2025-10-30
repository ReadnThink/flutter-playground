import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

    // 타임존 데이터 초기화 (예약 알림에 필요)
    // 기기의 현지 타임존을 사용하도록 설정
    tz.initializeTimeZones();
    // tz.local은 플랫폼의 기본 타임존을 참조하므로 별도 설정 없이 사용 가능

    // iOS/Android 권한 요청 (iOS는 런타임, Android는 13+에서 런타임)
    await _requestPermissionsIfNeeded();

    // Android: 정확한 알람 권한 (Android 12L/13+에서 필요할 수 있음)
    if (Platform.isAndroid) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImpl?.requestExactAlarmsPermission();
    }

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
          importance: Importance.max,
          priority: Priority.max,
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

    // 매 호출마다 고유 ID로 표시하여 이전 알림을 덮어쓰지 않도록 함
    final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _plugin.show(notificationId, title, body, details);
  }

  /// 10초 뒤 예약 알림 (앱이 백그라운드/종료 상태여도 시스템이 표시)
  /// - [productName]: 상품명
  /// - [quantity]: 담긴 수량 (예: 현재 수량)
  Future<void> scheduleAddedToCartIn10Seconds({
    required String productName,
    required int quantity,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.max,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final String title = '장바구니 예약 알림';
    final String body = '$productName (수량: $quantity) - 10초 뒤 알림';

    final tz.TZDateTime scheduledTime = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(seconds: 5));

    // 예약 알림도 매번 고유 ID로 등록 (동일 ID 사용 시 이전 예약이 교체됨)
    final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _plugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'cart_scheduled',
    );
  }
}
