class Pantun {
  final String id;
  final String text;
  final String theme;
  final String mood;
  final String location;
  bool saved;

  Pantun({
    required this.id,
    required this.text,
    required this.theme,
    required this.mood,
    required this.location,
    this.saved = false,
  });

  // Fungsi copyWith untuk memudahkan update status 'saved'
  Pantun copyWith({bool? saved}) {
    return Pantun(
      id: id,
      text: text,
      theme: theme,
      mood: mood,
      location: location,
      saved: saved ?? this.saved,
    );
  }

  // Fungsi untuk terima data dari struktur JSON anda
  factory Pantun.fromJson(Map<String, dynamic> json) {
    // Cantumkan 4 baris pantun jadi satu teks lengkap
    final b1 = json['Baris 1 (Pembayang)'] ?? '';
    final b2 = json['Baris 2 (Pembayang)'] ?? '';
    final b3 = json['Baris 3 (Isi)'] ?? '';
    final b4 = json['Baris 4 (Isi)'] ?? '';
    final fullText = '$b1\n$b2\n$b3\n$b4';

    return Pantun(
      id: json['No. Baru']?.toString() ?? '',
      text: fullText,
      theme: json['Tema Baharu'] ?? json['Tema Blok'] ?? 'Umum',
      mood: 'Tenang', // Nilai default kerana tiada field mood dalam JSON
      location: json['Negeri'] ?? '',
      saved: false,
    );
  }
}