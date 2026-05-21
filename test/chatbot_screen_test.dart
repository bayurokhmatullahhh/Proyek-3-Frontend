import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_urban_health/screens/chatbot/chatbot_screen.dart';
import 'package:smart_urban_health/widgets/chatbot/chatbot_fab.dart';

/// ============================================================
/// WIDGET TEST — ChatbotScreen & ChatbotFab
/// Menguji: rendering UI, interaksi, navigasi
/// ============================================================

void main() {
  // ──────────────────────────────────────────────────────────────
  // GROUP 1: ChatbotFab Widget Tests
  // NOTE: FAB memiliki pulse animation loop, jadi JANGAN pakai
  //       pumpAndSettle() — gunakan pump() dengan durasi tertentu.
  // ──────────────────────────────────────────────────────────────
  group('ChatbotFab Widget', () {
    testWidgets('harus render tanpa error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [ChatbotFab()]),
          ),
        ),
      );
      // pump saja, jangan pumpAndSettle (animasi infinite loop)
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ChatbotFab), findsOneWidget);
    });

    testWidgets('harus memiliki icon smart_toy', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [ChatbotFab()]),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.smart_toy_rounded), findsOneWidget);
    });

    testWidgets('tap harus navigasi ke ChatbotScreen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [ChatbotFab()]),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Tap pada GestureDetector yang membungkus FAB
      final fabFinder = find.byIcon(Icons.smart_toy_rounded);
      expect(fabFinder, findsOneWidget);

      await tester.tap(fabFinder);
      // Tunggu bounce animation (150ms fwd + 150ms rev) + route transition (400ms)
      await tester.pump(const Duration(milliseconds: 160));
      await tester.pump(const Duration(milliseconds: 160));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Harus navigasi ke ChatbotScreen
      expect(find.byType(ChatbotScreen), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────
  // GROUP 2: ChatbotScreen Widget Tests
  // ──────────────────────────────────────────────────────────────
  group('ChatbotScreen Widget', () {
    testWidgets('harus render tanpa error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ChatbotScreen()),
      );
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byType(ChatbotScreen), findsOneWidget);
    });

    testWidgets('harus menampilkan AppBar dengan nama ELSA', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ChatbotScreen()),
      );
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('ELSA HealthBot'), findsOneWidget);
    });

    testWidgets('harus menampilkan status online', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ChatbotScreen()),
      );
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.textContaining('Online'), findsOneWidget);
    });

    testWidgets('harus menampilkan welcome message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ChatbotScreen()),
      );
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.textContaining('ELSA'), findsWidgets);
    });

    testWidgets('harus menampilkan quick suggestions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ChatbotScreen()),
      );
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Coba tanyakan:'), findsOneWidget);
    });

    testWidgets('harus memiliki input field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ChatbotScreen()),
      );
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('harus memiliki send button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ChatbotScreen()),
      );
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('input text lalu send harus menambah pesan user',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ChatbotScreen()),
      );
      await tester.pump(const Duration(milliseconds: 700));

      // Ketik pesan
      await tester.enterText(find.byType(TextField), 'saya sakit kepala');
      await tester.pump();

      // Tap send
      await tester.tap(find.byIcon(Icons.send_rounded));
      // Pump melewati setState awal
      await tester.pump(const Duration(milliseconds: 100));

      // Pesan user dirender via RichText, cari lewat byWidgetPredicate
      final userMsgFinder = find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          return widget.text.toPlainText().contains('saya sakit kepala');
        }
        return false;
      });
      expect(userMsgFinder, findsOneWidget);

      // Pump melewati Future.delayed(500ms) + respons bot
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('harus memiliki menu button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ChatbotScreen()),
      );
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
    });

    testWidgets('tap menu harus menampilkan bottom sheet', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ChatbotScreen()),
      );
      await tester.pump(const Duration(milliseconds: 700));

      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Riwayat Chat'), findsOneWidget);
      expect(find.text('Tentang ELSA'), findsOneWidget);
    });

    testWidgets('back button harus ada', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ChatbotScreen()),
      );
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byIcon(Icons.arrow_back_ios_rounded), findsOneWidget);
    });
  });
}
