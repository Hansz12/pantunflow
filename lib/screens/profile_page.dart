import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_theme.dart';
import '../data/app_store.dart'; // PENTING: Import AppStore supaya kita boleh simpan tema global
import 'login_page.dart'; // Untuk navigasi semula ke login selepas sign out

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Data sementara untuk profil (boleh sambung ke Firestore nanti)
  String namaUser = 'Izatul';
  String bioUser = 'Pencinta pantun';

  // Senarai pilihan tema pantun (Diselaraskan mengikut kategori tema di HomePage / JSON anda)
  final List<String> senaraiTema = [
    'Peribahasa & Kiasan',
    'Agama & Spiritual',
    'Budi & Adab',
    'Cinta & Kasih Sayang',
    'Nasihat & Moral',
    'Jenaka',
  ];

  // Fungsi untuk tukar tema kegemaran menggunakan dialog pilihan
  void _tukarTema() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Tema Kegemaran', style: TextStyle(color: deepMaroon, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: senaraiTema.length,
            itemBuilder: (context, index) {
              final tema = senaraiTema[index];
              return ListTile(
                title: Text(tema),
                leading: const Icon(Icons.favorite, color: maroon),
                onTap: () {
                  setState(() {
                    // SIMPAN TERUS KE APPDATA GLOBAL SUPAYA HOMEPAGE DAPAT BACA
                    AppStore.preferredTheme = tema;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tema kegemaran dikemas kini kepada: $tema')),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Fungsi Edit Profil (Dialog ringkas ubah nama & bio)
  void _editProfil() {
    final nameCtrl = TextEditingController(text: namaUser);
    final bioCtrl = TextEditingController(text: bioUser);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil', style: TextStyle(color: deepMaroon, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama')),
            const SizedBox(height: 12),
            TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: 'Bio / Status')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: maroon),
            onPressed: () {
              setState(() {
                namaUser = nameCtrl.text.trim();
                bioUser = bioCtrl.text.trim();
                AppStore.name = namaUser; // Kemas kini nama global juga jika perlu
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil berjaya dikemas kini!')),
              );
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Fungsi Sign Out / Log Keluar
  void _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Keluar'),
        content: const Text('Adakah anda pasti mahu log keluar dari akaun ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text('Log Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan emel pengguna semasa dari Firebase jika ada
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? 'izatulfitrahroslan@gmail.com';

    return Scaffold(
      backgroundColor: paper,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Melengkung di atas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                color: deepMaroon,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Text('Profil', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('Akaun PantunFlow anda', style: TextStyle(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 20),
                  
                  // Avatar Bulat
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: maroon,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  
                  // Nama & Bio
                  Text(namaUser, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(bioUser, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(userEmail, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Kandungan Kad Pilihan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 1. Kad Tema Kegemaran (Boleh ditekan untuk tukar)
                  InkWell(
                    onTap: _tukarTema,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: maroon.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.favorite, color: maroon),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tema Kegemaran (Tekan untuk tukar)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 2),
                                // BACA TERUS DARI APPDATA GLOBAL SUPAYA SENTIASA SINKRON
                                Text(AppStore.preferredTheme, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: deepMaroon)),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit_outlined, color: maroon, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 2. Kad Jumlah Pantun Disimpan
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: maroon.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.bookmark, color: maroon),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Jumlah Pantun Disimpan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text('${AppStore.collection.length} pantun', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: deepMaroon)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  // 3. Menu Tetapan & Akaun
                  ListTile(
                    leading: const Icon(Icons.edit, color: deepMaroon),
                    title: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Kemas kini nama dan bio'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _editProfil,
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: deepMaroon),
                    title: const Text('Tetapan Akaun (Account Setting)', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Urus keselamatan dan kata laluan'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tetapan akaun akan dibuka di sini.')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Log Keluar (Sign Out)', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                    subtitle: const Text('Keluar dari akaun semasa'),
                    onTap: _signOut,
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}