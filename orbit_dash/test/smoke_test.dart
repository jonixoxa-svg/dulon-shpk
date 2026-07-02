import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_dash/game/orbit_dash_game.dart';
import 'package:orbit_dash/ui/screens/main_menu_screen.dart';

import 'package:orbit_dash/main.dart';

void main() {
  testWidgets('main menu renders', (tester) async {
    await tester.pumpWidget(const OrbitDashApp());
    await tester.pump();

    expect(find.byType(MainMenuScreen), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('REMOVE ADS'), findsOneWidget);
  });

  test('angleDistance wraps correctly', () {
    expect(angleDistance(0, 0), 0);
    expect(angleDistance(0.1, -0.1), closeTo(0.2, 1e-9));
    expect(angleDistance(6.2, 0.1), lessThan(0.3)); // wraps around 2π
    expect(angleDistance(3.14, -3.14), lessThan(0.01));
  });
}
