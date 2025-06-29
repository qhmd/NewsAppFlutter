import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Pastikan Anda menambahkan package ini ke pubspec.yaml
import 'package:newsapp/presentation/state/theme_provider.dart'; // Sesuaikan dengan path Anda
// import 'package:newsapp/presentation/screens/profile/profile_page.dart'; // Contoh halaman awal Anda

// Definisi ColorScheme yang Anda berikan
const lighColorScheme = ColorScheme.light(
  primary: Colors.red,
  onPrimary: Colors.black,
  primaryContainer: Colors.white,
  onSecondaryContainer: Colors.white,
);

const blackColorScheme = ColorScheme.light(
  brightness: Brightness.dark, // Penting untuk tema gelap
  primary: Colors.red,
  onPrimary: Colors.white,
  primaryContainer: Color.fromARGB(255, 16, 16, 16),
  onSecondaryContainer: Color.fromARGB(255, 28, 27, 27),
);

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Wajib untuk SharedPreferences
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Sediakan ThemeProvider
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil ThemeMode dari ThemeProvider
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'News App',
      debugShowCheckedModeBanner: false,
      // Tema Terang Anda
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lighColorScheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      // Tema Gelap Anda
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark, // Pastikan ini ada untuk darkTheme
        colorScheme: blackColorScheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      // Ini adalah kunci! MaterialApp akan menggunakan themeMode dari provider
      themeMode: themeProvider.themeMode,
      home: const DummyHomePage(), // Ganti dengan halaman awal aplikasi Anda
    );
  }
}

// Dummy Home Page untuk Demonstrasi
class DummyHomePage extends StatelessWidget {
  const DummyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>(); // Untuk menampilkan tema saat ini
    final theme = Theme.of(context); // Untuk warna dan gaya teks

    return Scaffold(
      appBar: AppBar(
        title: Text('News App', style: TextStyle(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tema Saat Ini:',
              style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onPrimary),
            ),
            Text(
              themeProvider.themeMode == ThemeMode.light
                  ? 'Terang'
                  : themeProvider.themeMode == ThemeMode.dark
                      ? 'Gelap'
                      : 'Sistem',
              style: theme.textTheme.headlineLarge?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Text(
              'Ganti Tema:',
              style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Panggil metode setThemeMode dari ThemeProvider
                context.read<ThemeProvider>().setThemeMode(ThemeMode.light);
              },
              child: const Text('Tema Terang'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.read<ThemeProvider>().setThemeMode(ThemeMode.dark);
              },
              child: const Text('Tema Gelap'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.read<ThemeProvider>().setThemeMode(ThemeMode.system);
              },
              child: const Text('Ikuti Sistem'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.read<ThemeProvider>().toggleTheme(); // Atau gunakan toggle
              },
              child: Text(
                themeProvider.themeMode == ThemeMode.light || themeProvider.themeMode == ThemeMode.system
                    ? 'Beralih ke Gelap'
                    : 'Beralih ke Terang',
              ),
            ),
          ],
        ),
      ),
      backgroundColor: theme.colorScheme.primaryContainer, // Warna latar belakang sesuai tema
    );
  }
}