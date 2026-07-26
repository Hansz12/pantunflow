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

  Pantun copyWith({
    String? text,
    String? theme,
    String? mood,
    String? location,
    bool? saved,
  }) {
    return Pantun(
      id: id,
      text: text ?? this.text,
      theme: theme ?? this.theme,
      mood: mood ?? this.mood,
      location: location ?? this.location,
      saved: saved ?? this.saved,
    );
  }

  factory Pantun.fromJson(Map<String, dynamic> json) {
    // Format untuk pantun yang disimpan oleh aplikasi.
    if (json.containsKey('text')) {
      return Pantun(
        id: json['id']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        theme: json['theme']?.toString() ?? 'Umum',
        mood: json['mood']?.toString() ?? 'Tenang',
        location: json['location']?.toString() ?? '',
        saved: json['saved'] == true,
      );
    }

    // Format dataset pantun_data.json.
    final String b1 =
        json['Baris 1 (Pembayang)']?.toString() ?? '';
    final String b2 =
        json['Baris 2 (Pembayang)']?.toString() ?? '';
    final String b3 =
        json['Baris 3 (Isi)']?.toString() ?? '';
    final String b4 =
        json['Baris 4 (Isi)']?.toString() ?? '';

    return Pantun(
      id: json['No. Baru']?.toString() ?? '',
      text: '$b1\n$b2\n$b3\n$b4',
      theme: json['Tema Baharu']?.toString() ??
          json['Tema Blok']?.toString() ??
          'Umum',
      mood: 'Tenang',
      location: json['Negeri']?.toString() ?? '',
      saved: false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'theme': theme,
      'mood': mood,
      'location': location,
      'saved': saved,
    };
  }
}