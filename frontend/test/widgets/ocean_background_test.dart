import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uma_sailing_app/widgets/ocean/ocean_background.dart';

void main() {
  group('OceanBackground Widget Tests', () {
    testWidgets('OceanBackground 组件渲染测试', (WidgetTester tester) async {
      // 创建一个简单的子 widget
      const testChild = Text('Test Content');

      // 构建 OceanBackground 组件
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OceanBackground(
              child: testChild,
              enableWave: false,
              enableParticles: false,
            ),
          ),
        ),
      );

      // 验证子 widget 被渲染
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('OceanBackground 禁用波浪动画', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OceanBackground(
              child: Text('No Wave'),
              enableWave: false,
            ),
          ),
        ),
      );

      expect(find.text('No Wave'), findsOneWidget);
    });

    testWidgets('OceanBackground 启用粒子效果', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OceanBackground(
              child: Text('With Particles'),
              enableParticles: true,
              particleCount: 3,
            ),
          ),
        ),
      );

      expect(find.text('With Particles'), findsOneWidget);
    });

    testWidgets('OceanBackground 自定义波浪颜色', (WidgetTester tester) async {
      const customWaveColor = Colors.blue;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OceanBackground(
              child: Text('Custom Color'),
              enableWave: false,
              waveColor: customWaveColor,
            ),
          ),
        ),
      );

      expect(find.text('Custom Color'), findsOneWidget);
    });

    testWidgets('OceanBackground 包含多个子元素', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OceanBackground(
              child: Column(
                children: [
                  Text('Item 1'),
                  Text('Item 2'),
                  Text('Item 3'),
                ],
              ),
              enableWave: false,
            ),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });
  });
}
