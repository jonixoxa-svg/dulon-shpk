import '../services/storage_service.dart';

/// Minimal two-language string table (English + Albanian). Add keys here;
/// the UI reads via Strings.t('key'). Falls back to English, then the key.
class Strings {
  Strings._();

  static const _en = {
    'settings': 'SETTINGS',
    'audio': 'Audio',
    'effects_volume': 'Effects volume',
    'sound': 'Sound',
    'haptics': 'Haptics (vibration)',
    'accessibility': 'Accessibility',
    'colorblind': 'High-contrast palette',
    'left_hand': 'Left-hand mode',
    'language': 'Language',
    'restore_purchases': 'Restore purchases',
    'privacy': 'Privacy settings',
    'play': 'PLAY',
    'store': 'STORE',
    'missions': 'MISSIONS',
    'badges': 'BADGES',
  };

  static const _sq = {
    'settings': 'CILËSIMET',
    'audio': 'Audio',
    'effects_volume': 'Volumi i efekteve',
    'sound': 'Zëri',
    'haptics': 'Dridhje (haptics)',
    'accessibility': 'Qasshmëria',
    'colorblind': 'Paletë me kontrast të lartë',
    'left_hand': 'Modaliteti për dorën e majtë',
    'language': 'Gjuha',
    'restore_purchases': 'Rikthe blerjet',
    'privacy': 'Cilësimet e privatësisë',
    'play': 'LUAJ',
    'store': 'DYQANI',
    'missions': 'MISIONET',
    'badges': 'DISTINKSIONET',
  };

  static String t(String key) {
    final lang = StorageService.instance.language;
    final table = lang == 'sq' ? _sq : _en;
    return table[key] ?? _en[key] ?? key;
  }
}
