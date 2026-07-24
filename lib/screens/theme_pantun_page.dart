import 'package:flutter/material.dart';
import '../models/pantun.dart';
import '../data/app_store.dart';

class ThemePantunPage extends StatelessWidget {
  final String themeName;

  const ThemePantunPage({Key? key, required this.themeName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tapis pantun mengikut tema yang dipilih
    final List<Pantun> filteredList = AppStore.collection
        .where((p) => p.theme.toLowerCase() == themeName.toLowerCase())
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: Text(
          themeName,
          style: const TextStyle(color: Color(0xFF4A2E2B), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4A2E2B)),
      ),
      body: filteredList.isEmpty
          ? const Center(
              child: Text(
                "Tiada pantun dijumpai untuk tema ini.",
                style: TextStyle(color: Color(0xFF7A6B68), fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final pantun = filteredList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A2E2B),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "No: ${pantun.id}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (pantun.location.isNotEmpty)
                            Text(
                              pantun.location,
                              style: const TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        pantun.text,
                        style: const TextStyle(
                          color: Color(0xFFFDFBF7),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}