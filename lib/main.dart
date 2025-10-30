import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'router/app_router.dart';
import 'services/notification_service.dart';

/// Flutter 전역 상태 관리 연습 앱의 진입점
/// Provider와 GoRouter를 사용한 장바구니 앱
void main() async {
  // Flutter 엔진과 플러그인 채널 초기화 (비동기 초기화 전에 필수)
  WidgetsFlutterBinding.ensureInitialized();
  // 로컬 알림 서비스 초기화 및 권한 요청
  await NotificationService.instance.init();
  // 실제 앱 구동 시작
  runApp(const MyApp());
}

/// 앱의 루트 위젯
/// Provider와 GoRouter를 설정하여 전역 상태 관리와 라우팅을 구성
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // 전역 상태 관리를 위한 Provider들 설정
      providers: [
        // 장바구니 상태를 관리하는 CartProvider 등록
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MaterialApp.router(
        // 앱 제목
        title: 'Flutter 상태 관리 연습',

        // GoRouter를 사용한 라우팅 설정
        routerConfig: AppRouter.router,

        // 앱 테마 설정
        theme: ThemeData(
          // 기본 색상 스키마 설정
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),

          // 앱바 테마 설정
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 2,
          ),

          // 카드 테마 설정
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),

          // 버튼 테마 설정
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        // 디버그 모드에서 라우트 정보 표시
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
