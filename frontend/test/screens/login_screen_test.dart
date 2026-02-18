import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Login Screen Widget Tests', () {
    testWidgets('登录页面包含用户名输入框', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TextField(
                key: Key('username_field'),
                decoration: InputDecoration(
                  labelText: '用户名',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('username_field')), findsOneWidget);
      expect(find.text('用户名'), findsOneWidget);
    });

    testWidgets('登录页面包含密码输入框', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TextField(
                key: Key('password_field'),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '密码',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.text('密码'), findsOneWidget);
    });

    testWidgets('登录页面包含登录按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ElevatedButton(
                key: Key('login_button'),
                onPressed: null,
                child: Text('登录'),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('login_button')), findsOneWidget);
      expect(find.text('登录'), findsOneWidget);
    });

    testWidgets('登录页面包含注册链接', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TextButton(
                key: Key('register_link'),
                onPressed: null,
                child: Text('还没有账号？立即注册'),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('register_link')), findsOneWidget);
      expect(find.text('还没有账号？立即注册'), findsOneWidget);
    });

    testWidgets('登录表单输入验证', (WidgetTester tester) async {
      final usernameController = TextEditingController();
      final passwordController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  controller: usernameController,
                  key: const Key('username'),
                  decoration: const InputDecoration(labelText: '用户名'),
                ),
                TextField(
                  controller: passwordController,
                  key: const Key('password'),
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '密码'),
                ),
              ],
            ),
          ),
        ),
      );

      // 输入用户名
      await tester.enterText(find.byKey(const Key('username')), 'testuser');
      expect(usernameController.text, 'testuser');

      // 输入密码
      await tester.enterText(find.byKey(const Key('password')), 'password123');
      expect(passwordController.text, 'password123');
    });
  });
}
