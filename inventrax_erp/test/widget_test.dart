// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inventrax_erp/src/app/app.dart';
import 'package:inventrax_erp/src/core/env_config.dart';
import 'package:inventrax_erp/src/features/auth/application/session_provider.dart';

class _TestSession extends SessionController {
  @override
  SessionState build() =>
      const SessionState(isReady: true, isAuthenticated: false);
}

void main() {
  setUpAll(() async {
    await EnvConfig.load();
  });

  testWidgets('App boots to welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(_TestSession.new),
        ],
        child: const InventraXApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Register your store'), findsOneWidget);
  });
}
