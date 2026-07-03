import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_dash/game/orbit_dash_game.dart';
import 'package:orbit_dash/services/progression_service.dart';
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
    expect(find.text('LEVEL 1'), findsOneWidget);
  });

  test('angleDistance wraps correctly', () {
    expect(angleDistance(0, 0), 0);
    expect(angleDistance(0.1, -0.1), closeTo(0.2, 1e-9));
    expect(angleDistance(6.2, 0.1), lessThan(0.3)); // wraps around 2π
    expect(angleDistance(3.14, -3.14), lessThan(0.01));
  });

  test('shortestAngleDelta is signed and wraps', () {
    expect(shortestAngleDelta(0.3, 0.1), closeTo(0.2, 1e-9));
    expect(shortestAngleDelta(0.1, 0.3), closeTo(-0.2, 1e-9));
    // Crossing the 0/2π seam picks the short way round.
    expect(shortestAngleDelta(6.2, 0.1).abs(), lessThan(0.3));
  });

  test('xp curve is monotonic and starts at level 1', () {
    expect(ProgressionService.xpForLevel(1), greaterThan(0));
    for (var lvl = 1; lvl < 12; lvl++) {
      expect(ProgressionService.xpForLevel(lvl + 1),
          greaterThan(ProgressionService.xpForLevel(lvl)));
    }
  });
}
