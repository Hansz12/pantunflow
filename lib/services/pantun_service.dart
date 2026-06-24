import 'dart:math';

import '../data/app_store.dart';
import '../models/pantun.dart';

Pantun recommendPantun() {
  final matches = AppStore.collection
      .where((pantun) => pantun.theme == AppStore.preferredTheme)
      .toList();
  return matches.isEmpty ? AppStore.collection.first : matches.first;
}

Pantun generatePantun(
  String keyword,
  String theme,
  String mood,
  String location,
) {
  final place = location.trim().isEmpty ? 'taman indah' : location.trim();
  final idea = keyword.trim().isEmpty ? 'kasih dan budi' : keyword.trim();
  final endings = {
    'Cinta': ['rindu', 'menunggu'],
    'Nasihat': ['diri', 'berbakti'],
    'Persahabatan': ['sehati', 'abadi'],
  };
  final end = endings[theme] ?? ['berseri', 'dihargai'];
  final pembayang = [
    'Bunga melati harum mewangi,\nTumbuh segar di tepi kali;',
    'Burung kenari terbang tinggi,\nHinggap sebentar di pohon jati;',
    'Ombak beralun di tepi pantai,\nCahaya bulan jatuh ke bumi;',
  ][Random().nextInt(3)];

  return Pantun(
    text: '$pembayang\n$idea menjadi pesan di hati,\nDi $place tetap ${end.last}.',
    theme: theme,
    mood: mood,
    location: location,
  );
}
