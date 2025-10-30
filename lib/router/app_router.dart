import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/main_screen.dart';

/// 앱의 라우팅을 관리하는 클래스
/// GoRouter를 사용하여 바텀 네비게이션 기반 화면 전환을 설정
class AppRouter {
  /// GoRouter 인스턴스
  static final GoRouter _router = GoRouter(
    // 초기 경로 설정 (앱 시작 시 첫 번째 화면)
    initialLocation: '/',

    // 라우트 설정
    routes: [
      // 메인 화면 (바텀 네비게이션 포함)
      GoRoute(
        path: '/',
        name: 'main',
        builder: (context, state) {
          return const MainScreen();
        },
      ),
    ],

    // 에러 발생 시 보여줄 화면
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('오류'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 100, color: Colors.red),
              SizedBox(height: 16),
              Text(
                '페이지를 찾을 수 없습니다.',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ],
          ),
        ),
      );
    },
  );

  /// GoRouter 인스턴스를 반환하는 getter
  static GoRouter get router => _router;
}
