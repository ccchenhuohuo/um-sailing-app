import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Home Screen Widget Tests', () {
    testWidgets('首页包含应用标题', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('UM 帆船协会'),
              ),
              body: const Text('欢迎来到澳门大学帆船协会'),
            ),
          ),
        ),
      );

      expect(find.text('UM 帆船协会'), findsOneWidget);
      expect(find.text('欢迎来到澳门大学帆船协会'), findsOneWidget);
    });

    testWidgets('首页包含底部导航栏', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              bottomNavigationBar: BottomNavigationBar(
                key: const Key('bottom_nav'),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: '首页',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.sailing),
                    label: '活动',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today),
                    label: '日程',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: '我的',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('bottom_nav')), findsOneWidget);
      expect(find.text('首页'), findsOneWidget);
      expect(find.text('活动'), findsOneWidget);
      expect(find.text('日程'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);
    });

    testWidgets('首页包含功能卡片', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GridView.count(
                crossAxisCount: 2,
                children: const [
                  Card(child: Center(child: Text('活动报名'))),
                  Card(child: Center(child: Text('船只租赁'))),
                  Card(child: Center(child: Text('财务记录'))),
                  Card(child: Center(child: Text('论坛'))),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('活动报名'), findsOneWidget);
      expect(find.text('船只租赁'), findsOneWidget);
      expect(find.text('财务记录'), findsOneWidget);
      expect(find.text('论坛'), findsOneWidget);
    });

    testWidgets('首页包含用户信息区域', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text('用户名'),
                subtitle: Text('普通用户'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('用户名'), findsOneWidget);
      expect(find.text('普通用户'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('首页包含余额显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Card(
                child: ListTile(
                  leading: Icon(Icons.account_balance_wallet),
                  title: Text('账户余额'),
                  trailing: Text('¥100.00'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('账户余额'), findsOneWidget);
      expect(find.text('¥100.00'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
    });
  });
}
