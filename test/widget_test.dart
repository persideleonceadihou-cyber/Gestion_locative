import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_locative/main.dart';

void main() {
  testWidgets('shows the home screen first', (WidgetTester tester) async {
    final completer = Completer<void>();
    await tester.pumpWidget(MyApp(firebaseInit: completer.future));

    expect(find.text('Gestion Locative'), findsOneWidget);
    expect(
      find.text(
        'Biens · Locataires · Paiements',
      ),
      findsOneWidget,
    );
  });
}
