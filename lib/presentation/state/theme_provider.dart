import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Pastikan Anda menambahkan package ini ke pubspec.yaml

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default: Ikuti pengaturan sistem

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode(); // Muat tema yang tersimpan saat provider diinisialisasi
  }

  // Memuat preferensi tema dari SharedPreferences
  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    // 0: system, 1: light, 2: dark (sesuai index enum ThemeMode)
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners(); // Beri tahu pendengar bahwa tema telah dimuat
  }

  // Mengatur dan menyimpan tema baru
  void setThemeMode(ThemeMode mode) async {
    if (mode != _themeMode) { // Hanya perbarui jika ada perubahan
      _themeMode = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeMode', mode.index); // Simpan index enum
      notifyListeners(); // Beri tahu widget untuk membangun ulang
    }
  }

  // Fungsi praktis untuk mengganti antara terang dan gelap (opsional)
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}