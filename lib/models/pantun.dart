class Pantun {
  final String id;
  final String text;
  final String theme;
  final String mood;
  final String location;
  final String keyword;
  final DateTime? generatedAt;
  bool saved;

  Pantun({
    required this.id,
    required this.text,
    required this.theme,
    required this.mood,
    required this.location,
    this.keyword = '',
    this.generatedAt,
    this.saved = false,
  });

  Pantun copyWith({
    String? text,
    String? theme,
    String? mood,
    String? location,
    String? keyword,
    DateTime? generatedAt,
    bool? saved,
  }) {
    return Pantun(
      id: id,
      text: text ?? this.text,
      theme: theme ?? this.theme,
      mood: mood ?? this.mood,
      location: location ?? this.location,
      keyword: keyword ?? this.keyword,
      generatedAt: generatedAt ?? this.generatedAt,
      saved: saved ?? this.saved,
    );
  }

  factory Pantun.fromJson(Map<String, dynamic> json) {
    // Format untuk pantun yang disimpan oleh aplikasi.
    if (json.containsKey('text')) {
      DateTime? dt;
      if (json['generatedAt'] != null) {
        if (json['generatedAt'] is String) {
          dt = DateTime.tryParse(json['generatedAt']);
        } else if (json['generatedAt'] is int) {
          dt = DateTime.fromMillisecondsSinceEpoch(json['generatedAt']);
        }
      }

      return Pantun(
        id: json['id']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        theme: json['theme']?.toString() ?? 'Umum',
        mood: json['mood']?.toString() ?? 'Tenang',
        location: json['location']?.toString() ?? '',
        keyword: json['keyword']?.toString() ?? '',
        generatedAt: dt,
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
      keyword: '',
      generatedAt: null,
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
      'keyword': keyword,
      'generatedAt': generatedAt?.toIso8601String(),
      'saved': saved,
    };
  }
}
