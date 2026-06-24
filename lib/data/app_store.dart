import '../models/pantun.dart';

class AppStore {
  static String name = 'Farhana';
  static String preferredTheme = 'Cinta';

  static final List<Pantun> collection = [
    Pantun(
      text: 'Pulau Redang pasirnya putih,\n'
          'Tempat berehat di hujung minggu;\n'
          'Walau badai datang menyisih,\n'
          'Kasih abadi tetap ku tunggu.',
      theme: 'Cinta',
      mood: 'Gembira',
      location: 'Pulau Redang',
      saved: true,
    ),
    Pantun(
      text: 'Pagi cerah burung bernyanyi,\n'
          'Awan lembut indah berseri;\n'
          'Budi yang baik kekal dihargai,\n'
          'Menjadi cahaya dalam diri.',
      theme: 'Nasihat',
      mood: 'Tenang',
      location: '',
      saved: true,
    ),
  ];
}
