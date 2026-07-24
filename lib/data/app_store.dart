import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/pantun.dart';

class AppStore {
  // 1. Senaraikan tema yang sah supaya padanan tidak gagal
  static String name = 'Izatul'; 
  static String preferredTheme = 'Peribahasa & Kiasan'; 

  // Senarai permulaan kosong sebelum data dimuat turun dari JSON
  static List<Pantun> collection = [];

  // Fungsi untuk baca fail JSON dari folder assets
  static Future<void> loadPantunFromAsset() async {
    // Elakkan muat turun berulang kali jika koleksi sudah ada isi
    if (collection.isNotEmpty) return;

    try {
      // 1. Baca fail string dari assets
      final String response = await rootBundle.loadString('assets/pantun_data.json');
      
      // 2. Decode string JSON kepada Map
      final Map<String, dynamic> decodedMap = jsonDecode(response);
      
      // 3. Ambil senarai di dalam kunci "data_klasifikasi_pantun"
      final List<dynamic> data = decodedMap['data_klasifikasi_pantun'] ?? [];
      
      // 4. Masukkan ke dalam senarai collection menggunakan Pantun.fromJson
      collection = data.map((json) => Pantun.fromJson(json)).toList();
      
      print("Berjaya muat turun ${collection.length} pantun dari JSON!");
    } catch (e) {
      print("Ralat semasa membaca fail pantun_data.json: $e");
    }
  }
}