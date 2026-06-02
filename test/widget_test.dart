import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_locative/main.dart';

void main() {
  testWidgets('shows the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Gestion Locative'), findsOneWidget);
    expect(
      find.text(
        'Votre espace de suivi des biens, locataires et paiements se prepare.',
      ),
      findsOneWidget,
    );
  });
}
