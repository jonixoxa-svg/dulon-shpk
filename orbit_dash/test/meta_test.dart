import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_dash/config/meta_config.dart';
import 'package:orbit_dash/services/meta_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('corrupt or truncated save never crashes and falls back to defaults',
      () async {
    for (final garbage in [
      'not json at all',
      '{"v":1,"coins":"NaN"}',
      '{"v":1,"coins":5,"life":[1,2,3]}', // wrong shape
      '{"v":1,"coins":5,"mIds":[1]}', // truncated missions
      '{',
    ]) {
      SharedPreferences.setMockInitialValues({'meta_save': garbage});
      final m = MetaService.instance;
      await m.init();
      expect(m.coins >= 0, true);
      expect(m.todaysMissions.length, 3);
    }
  });

  test('save round-trips coins, stadium and badges', () async {
    SharedPreferences.setMockInitialValues({});
    final m = MetaService.instance;
    await m.init();
    m.addCoins(500);
    expect(m.buyStadiumUpgrade(), true); // costs 50
    final coins = m.coins;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('meta_save');
    expect(raw, isNotNull);
    // simulate app restart: fresh load from the same blob
    SharedPreferences.setMockInitialValues({'meta_save': raw!});
    await m.init();
    expect(m.coins, coins);
    expect(m.stadiumLevel, 1);
  });

  test('capsule rarity distribution matches configured weights', () async {
    SharedPreferences.setMockInitialValues({});
    final m = MetaService.instance;
    await m.init();
    final counts = <String, int>{};
    for (var i = 0; i < 4000; i++) {
      final r = m.rollCapsule();
      counts[r.tier.name] = (counts[r.tier.name] ?? 0) + 1;
    }
    for (final t in MetaConfig.capsuleTiers) {
      final share = (counts[t.name] ?? 0) / 4000;
      expect((share - t.weight).abs() < 0.04, true,
          reason: '${t.name}: $share vs ${t.weight}');
    }
  });

  test('daily missions are date-stable and always include a quick one', () {
    final a = MetaService.pickMissions('2026-7-3');
    final b = MetaService.pickMissions('2026-7-3');
    expect(a, b);
    expect(a.any((i) => MetaConfig.missionPool[i].kind == 'runs'), true);
    expect(a.toSet().length, 3);
  });
}
