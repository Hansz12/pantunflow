import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/history_store.dart';
import '../theme/app_theme.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {
  String namaUser = 'Pengguna';
  String bioUser = 'Pencinta pantun';

  bool _isSigningOut = false;
  bool _isUpdatingProfile = false;

  final List<String> senaraiTema =
  <String>[
    'Peribahasa & Kiasan',
    'Agama & Spiritual',
    'Budi & Adab',
    'Cinta & Kasih Sayang',
    'Nasihat & Moral',
    'Jenaka',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final User? user =
        FirebaseAuth.instance.currentUser;

    final String firebaseName =
        user?.displayName?.trim() ?? '';

    final String appStoreName =
    AppStore.name.trim();

    String resolvedName;

    if (firebaseName.isNotEmpty) {
      resolvedName = firebaseName;
    } else if (appStoreName.isNotEmpty &&
        appStoreName != 'User') {
      resolvedName = appStoreName;
    } else {
      resolvedName = 'Pengguna';
    }

    namaUser = resolvedName;

    if (AppStore.name != resolvedName) {
      AppStore.name = resolvedName;
    }
  }

  int get _jumlahPantunDisimpan {
    return AppStore.collection
        .where(
          (pantun) => pantun.saved,
    )
        .length;
  }

  String get _userEmail {
    return FirebaseAuth
        .instance.currentUser?.email ??
        'Tiada emel';
  }

  String? get _photoUrl {
    final String? photo = FirebaseAuth
        .instance.currentUser?.photoURL;

    if (photo == null ||
        photo.trim().isEmpty) {
      return null;
    }

    return photo;
  }

  Future<void> _tukarTema() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      Colors.transparent,
      builder: (
          BuildContext bottomSheetContext,
          ) {
        return SafeArea(
          child: Container(
            padding:
            const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            decoration:
            const BoxDecoration(
              color: paper,
              borderRadius:
              BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.grey.shade300,
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment:
                  Alignment.centerLeft,
                  child: Text(
                    'Pilih Tema Kegemaran',
                    style: TextStyle(
                      color: deepMaroon,
                      fontSize: 20,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment:
                  Alignment.centerLeft,
                  child: Text(
                    'Tema yang dipilih akan digunakan sebagai pilihan utama anda.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child:
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount:
                    senaraiTema.length,
                    separatorBuilder:
                        (_, __) {
                      return const SizedBox(
                        height: 8,
                      );
                    },
                    itemBuilder: (
                        BuildContext context,
                        int index,
                        ) {
                      final String tema =
                      senaraiTema[index];

                      final bool isSelected =
                          AppStore
                              .preferredTheme ==
                              tema;

                      return Material(
                        color: isSelected
                            ? maroon.withValues(
                          alpha: 0.10,
                        )
                            : Colors.white,
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                        child: InkWell(
                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                          onTap: () {
                            setState(() {
                              AppStore
                                  .preferredTheme =
                                  tema;
                            });

                            Navigator.of(
                              bottomSheetContext,
                            ).pop();

                            ScaffoldMessenger.of(
                              context,
                            )
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Tema kegemaran dikemas kini kepada $tema.',
                                  ),
                                  behavior:
                                  SnackBarBehavior
                                      .floating,
                                ),
                              );
                          },
                          child: Padding(
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration:
                                  BoxDecoration(
                                    color: isSelected
                                        ? maroon
                                        : maroon
                                        .withValues(
                                      alpha: 0.10,
                                    ),
                                    shape: BoxShape
                                        .circle,
                                  ),
                                  child: Icon(
                                    Icons.favorite,
                                    color: isSelected
                                        ? Colors.white
                                        : maroon,
                                    size: 21,
                                  ),
                                ),
                                const SizedBox(
                                  width: 14,
                                ),
                                Expanded(
                                  child: Text(
                                    tema,
                                    style:
                                    TextStyle(
                                      color:
                                      deepMaroon,
                                      fontSize: 15,
                                      fontWeight:
                                      isSelected
                                          ? FontWeight
                                          .bold
                                          : FontWeight
                                          .w600,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons
                                        .check_circle,
                                    color: maroon,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editProfil() async {
    if (_isUpdatingProfile) {
      return;
    }

    final _ProfileEditResult? result =
    await showDialog<
        _ProfileEditResult>(
      context: context,
      barrierDismissible: false,
      builder: (
          BuildContext dialogContext,
          ) {
        return _EditProfileDialog(
          initialName: namaUser,
          initialBio: bioUser,
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _isUpdatingProfile = true;
    });

    try {
      final User? currentUser =
          FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message:
          'Maklumat pengguna tidak ditemui.',
        );
      }

      await currentUser.updateDisplayName(
        result.name,
      );

      await currentUser.reload();

      if (!mounted) {
        return;
      }

      setState(() {
        namaUser = result.name;
        bioUser = result.bio;
        _isUpdatingProfile = false;
      });

      AppStore.name = result.name;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Profil berjaya dikemas kini.',
            ),
            behavior:
            SnackBarBehavior.floating,
          ),
        );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isUpdatingProfile = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              error.message ??
              'Profil tidak dapat dikemas kini.',
            ),
            behavior:
            SnackBarBehavior.floating,
          ),
        );
    } catch (error) {
      debugPrint(
        'UPDATE PROFILE ERROR: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isUpdatingProfile = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Berlaku ralat semasa mengemas kini profil.',
            ),
            behavior:
            SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void>
  _bukaTetapanAkaun() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    final bool hasEmail =
        user?.email != null &&
            user!.email!.trim().isNotEmpty;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor:
      Colors.transparent,
      builder: (
          BuildContext sheetContext,
          ) {
        return SafeArea(
          child: Container(
            padding:
            const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            decoration:
            const BoxDecoration(
              color: paper,
              borderRadius:
              BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.grey.shade300,
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment:
                  Alignment.centerLeft,
                  child: Text(
                    'Tetapan Akaun',
                    style: TextStyle(
                      color: deepMaroon,
                      fontSize: 20,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _AccountInfoTile(
                  icon:
                  Icons.email_outlined,
                  title: 'Alamat emel',
                  subtitle: _userEmail,
                ),
                const SizedBox(height: 10),
                _AccountInfoTile(
                  icon: Icons
                      .verified_user_outlined,
                  title:
                  'Status pengesahan emel',
                  subtitle:
                  user!.emailVerified ==
                      true
                      ? 'Emel telah disahkan'
                      : 'Emel belum disahkan',
                ),
                if (hasEmail &&
                    user.emailVerified ==
                        false) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child:
                    OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await user
                              .sendEmailVerification();

                          if (!mounted) {
                            return;
                          }

                          if (sheetContext
                              .mounted) {
                            Navigator.of(
                              sheetContext,
                            ).pop();
                          }

                          ScaffoldMessenger.of(
                            context,
                          )
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Pautan pengesahan telah dihantar ke emel anda.',
                                ),
                                behavior:
                                SnackBarBehavior
                                    .floating,
                              ),
                            );
                        } on FirebaseAuthException catch (error) {
                          if (!mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(
                            context,
                          )
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  error.message ??
                                  'Pautan pengesahan tidak dapat dihantar.',
                                ),
                                behavior:
                                SnackBarBehavior
                                    .floating,
                              ),
                            );
                        }
                      },
                      icon: const Icon(
                        Icons
                            .mark_email_read_outlined,
                      ),
                      label: const Text(
                        'Hantar Pengesahan Emel',
                      ),
                      style: OutlinedButton
                          .styleFrom(
                        foregroundColor:
                        maroon,
                        side:
                        const BorderSide(
                          color: maroon,
                        ),
                        padding:
                        const EdgeInsets
                            .symmetric(
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void>
  _paparTentangAplikasi() async {
    await showDialog<void>(
      context: context,
      builder: (
          BuildContext dialogContext,
          ) {
        return AlertDialog(
          backgroundColor: paper,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(22),
          ),
          title: const Text(
            'Tentang PantunFlow',
            style: TextStyle(
              color: deepMaroon,
              fontWeight:
              FontWeight.bold,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: maroon,
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'PantunFlow',
                style: TextStyle(
                  color: deepMaroon,
                  fontSize: 21,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Versi 1.0.0',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'PantunFlow membantu pengguna menjana, menyimpan dan mengurus pantun Melayu berdasarkan tema, mood, kata kunci dan lokasi.',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actionsAlignment:
          MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style:
              ElevatedButton.styleFrom(
                backgroundColor: maroon,
                foregroundColor:
                Colors.white,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    final bool? shouldSignOut =
    await showDialog<bool>(
      context: context,
      builder: (
          BuildContext dialogContext,
          ) {
        return AlertDialog(
          backgroundColor: paper,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(22),
          ),
          title: const Text(
            'Log Keluar',
            style: TextStyle(
              color: deepMaroon,
              fontWeight:
              FontWeight.bold,
            ),
          ),
          content: const Text(
            'Adakah anda pasti mahu log keluar daripada akaun ini?',
            style: TextStyle(
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.red,
                foregroundColor:
                Colors.white,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child:
              const Text('Log Keluar'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true ||
        !mounted) {
      return;
    }

    setState(() {
      _isSigningOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();

      HistoryStore.clearLocalHistory();
      AppStore.clearUserSessionData();
      AppStore.name = 'User';

      if (!mounted) {
        return;
      }

      Navigator.of(context)
          .pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) =>
          const LoginPage(),
        ),
            (Route<dynamic> route) =>
        false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSigningOut = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              error.message ??
              'Log keluar tidak berjaya.',
            ),
            behavior:
            SnackBarBehavior.floating,
          ),
        );
    } catch (error) {
      debugPrint(
        'SIGN OUT ERROR: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSigningOut = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Berlaku ralat semasa log keluar.',
            ),
            behavior:
            SnackBarBehavior.floating,
          ),
        );
    }
  }

  Widget _buildAvatar() {
    final String? photoUrl =
        _photoUrl;

    if (photoUrl != null) {
      return CircleAvatar(
        radius: 48,
        backgroundColor: maroon,
        child: CircleAvatar(
          radius: 44,
          backgroundColor: cream,
          backgroundImage:
          NetworkImage(photoUrl),
          onBackgroundImageError:
              (_, __) {},
        ),
      );
    }

    final String initial =
    namaUser.trim().isNotEmpty
        ? namaUser
        .trim()[0]
        .toUpperCase()
        : 'P';

    return CircleAvatar(
      radius: 48,
      backgroundColor: maroon,
      child: CircleAvatar(
        radius: 44,
        backgroundColor: cream,
        child: Text(
          initial,
          style: const TextStyle(
            color: deepMaroon,
            fontSize: 34,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.fromLTRB(
        20,
        48,
        20,
        30,
      ),
      decoration:
      const BoxDecoration(
        color: deepMaroon,
        borderRadius: BorderRadius.only(
          bottomLeft:
          Radius.circular(34),
          bottomRight:
          Radius.circular(34),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Profil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight:
              FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Urus profil dan akaun PantunFlow anda',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 22),
          _buildAvatar(),
          const SizedBox(height: 14),
          Text(
            namaUser,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight:
              FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            bioUser,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _userEmail,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return ValueListenableBuilder<String>(
      valueListenable:
      AppStore.preferredThemeNotifier,
      builder: (
          BuildContext context,
          String preferredTheme,
          Widget? child,
          ) {
        return Row(
          children: [
            Expanded(
              child: _StatisticCard(
                icon: Icons.bookmark,
                value:
                '$_jumlahPantunDisimpan',
                label: 'Disimpan',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatisticCard(
                icon: Icons.favorite,
                value: preferredTheme,
                label:
                'Tema kegemaran',
                isTextValue: true,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFavouriteThemeCard() {
    return ValueListenableBuilder<String>(
      valueListenable:
      AppStore.preferredThemeNotifier,
      builder: (
          BuildContext context,
          String preferredTheme,
          Widget? child,
          ) {
        return Material(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(18),
          child: InkWell(
            onTap: _tukarTema,
            borderRadius:
            BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(17),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(
                  18,
                ),
                boxShadow: const [
                  BoxShadow(
                    color:
                    Color(0x10000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration:
                    BoxDecoration(
                      color: maroon
                          .withValues(alpha: 0.10),
                      shape:
                      BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: maroon,
                    ),
                  ),
                  const SizedBox(
                    width: 14,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        const Text(
                          'Tema kegemaran',
                          style: TextStyle(
                            color:
                            Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          preferredTheme,
                          style:
                          const TextStyle(
                            color:
                            deepMaroon,
                            fontSize: 16,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: maroon,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProfileMenuTile(
            icon: Icons.edit_outlined,
            title: 'Edit Profil',
            subtitle:
            'Kemas kini nama dan bio',
            onTap: _isUpdatingProfile
                ? null
                : _editProfil,
          ),
          const Divider(
            height: 1,
            indent: 70,
          ),
          _ProfileMenuTile(
            icon:
            Icons.settings_outlined,
            title: 'Tetapan Akaun',
            subtitle:
            'Lihat emel dan status akaun',
            onTap:
            _bukaTetapanAkaun,
          ),
          const Divider(
            height: 1,
            indent: 70,
          ),
          _ProfileMenuTile(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            subtitle:
            'Maklumat mengenai PantunFlow',
            onTap:
            _paparTentangAplikasi,
          ),
          const Divider(
            height: 1,
            indent: 70,
          ),
          _ProfileMenuTile(
            icon: Icons.logout,
            title: 'Log Keluar',
            subtitle:
            'Keluar daripada akaun semasa',
            iconColor: Colors.red,
            titleColor: Colors.red,
            showTrailing: false,
            onTap: _isSigningOut
                ? null
                : _signOut,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,
      body: Stack(
        children: [
          RefreshIndicator(
            color: maroon,
            onRefresh: () async {
              await FirebaseAuth
                  .instance.currentUser
                  ?.reload();

              if (!mounted) {
                return;
              }

              setState(() {
                _loadUserProfile();
              });
            },
            child:
            SingleChildScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(
                    height: 22,
                  ),
                  Padding(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 18,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        const Text(
                          'Ringkasan',
                          style: TextStyle(
                            color:
                            deepMaroon,
                            fontSize: 17,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        _buildStatisticsSection(),
                        const SizedBox(
                          height: 14,
                        ),
                        _buildFavouriteThemeCard(),
                        const SizedBox(
                          height: 24,
                        ),
                        const Text(
                          'Profil dan Akaun',
                          style: TextStyle(
                            color:
                            deepMaroon,
                            fontSize: 17,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        _buildMenuSection(),
                        const SizedBox(
                          height: 32,
                        ),
                        const Center(
                          child: Text(
                            'PantunFlow Versi 1.0.0',
                            style: TextStyle(
                              color: Colors
                                  .black38,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isSigningOut ||
              _isUpdatingProfile)
            Positioned.fill(
              child: Container(
                color: Colors.black
                    .withValues(alpha: 0.35),
                child: Center(
                  child: Card(
                    child: Padding(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 26,
                        vertical: 22,
                      ),
                      child: Column(
                        mainAxisSize:
                        MainAxisSize
                            .min,
                        children: [
                          const CircularProgressIndicator(
                            color: maroon,
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Text(
                            _isSigningOut
                                ? 'Sedang log keluar...'
                                : 'Sedang mengemas kini profil...',
                            style:
                            const TextStyle(
                              color:
                              deepMaroon,
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EditProfileDialog
    extends StatefulWidget {
  final String initialName;
  final String initialBio;

  const _EditProfileDialog({
    required this.initialName,
    required this.initialBio,
  });

  @override
  State<_EditProfileDialog>
  createState() =>
      _EditProfileDialogState();
}

class _EditProfileDialogState
    extends State<_EditProfileDialog> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _nameController;

  late final TextEditingController
  _bioController;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(
          text: widget.initialName,
        );

    _bioController =
        TextEditingController(
          text: widget.initialBio,
        );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();

    final bool isValid =
        _formKey.currentState
            ?.validate() ??
            false;

    if (!isValid) {
      return;
    }

    final String newName =
    _nameController.text.trim();

    final String enteredBio =
    _bioController.text.trim();

    final String newBio =
    enteredBio.isEmpty
        ? 'Pencinta pantun'
        : enteredBio;

    Navigator.of(context).pop(
      _ProfileEditResult(
        name: newName,
        bio: newBio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: paper,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(22),
      ),
      title: const Text(
        'Edit Profil',
        style: TextStyle(
          color: deepMaroon,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              TextFormField(
                controller:
                _nameController,
                textCapitalization:
                TextCapitalization
                    .words,
                textInputAction:
                TextInputAction.next,
                maxLength: 40,
                decoration:
                InputDecoration(
                  labelText: 'Nama',
                  hintText:
                  'Masukkan nama anda',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: maroon,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius
                        .circular(14),
                  ),
                  enabledBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius
                        .circular(14),
                    borderSide:
                    const BorderSide(
                      color:
                      Color(0xFFE2D3B8),
                    ),
                  ),
                  focusedBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius
                        .circular(14),
                    borderSide:
                    const BorderSide(
                      color: maroon,
                      width: 1.5,
                    ),
                  ),
                ),
                validator:
                    (String? value) {
                  final String name =
                      value?.trim() ?? '';

                  if (name.isEmpty) {
                    return 'Nama tidak boleh kosong.';
                  }

                  if (name.length < 2) {
                    return 'Nama mestilah sekurang-kurangnya 2 aksara.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller:
                _bioController,
                textCapitalization:
                TextCapitalization
                    .sentences,
                textInputAction:
                TextInputAction.done,
                maxLength: 80,
                minLines: 2,
                maxLines: 3,
                onFieldSubmitted: (_) {
                  _saveProfile();
                },
                decoration:
                InputDecoration(
                  labelText:
                  'Bio atau status',
                  hintText:
                  'Contoh: Pencinta pantun Melayu',
                  alignLabelWithHint: true,
                  prefixIcon:
                  const Padding(
                    padding:
                    EdgeInsets.only(
                      bottom: 42,
                    ),
                    child: Icon(
                      Icons.edit_note,
                      color: maroon,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius
                        .circular(14),
                  ),
                  enabledBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius
                        .circular(14),
                    borderSide:
                    const BorderSide(
                      color:
                      Color(0xFFE2D3B8),
                    ),
                  ),
                  focusedBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius
                        .circular(14),
                    borderSide:
                    const BorderSide(
                      color: maroon,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Batal',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
        ElevatedButton(
          style:
          ElevatedButton.styleFrom(
            backgroundColor: maroon,
            foregroundColor:
            Colors.white,
            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
          ),
          onPressed: _saveProfile,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _ProfileEditResult {
  final String name;
  final String bio;

  const _ProfileEditResult({
    required this.name,
    required this.bio,
  });
}

class _StatisticCard
    extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isTextValue;

  const _StatisticCard({
    required this.icon,
    required this.value,
    required this.label,
    this.isTextValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
      const BoxConstraints(
        minHeight: 125,
      ),
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: maroon
                  .withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: maroon,
              size: 21,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines:
            isTextValue ? 2 : 1,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              color: deepMaroon,
              fontSize:
              isTextValue ? 13 : 22,
              fontWeight:
              FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color titleColor;
  final bool showTrailing;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = deepMaroon,
    this.titleColor = Colors.black87,
    this.showTrailing = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: iconColor
              .withValues(
            alpha: 0.10,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 21,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontSize: 15,
          fontWeight:
          FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 12,
        ),
      ),
      trailing: showTrailing
          ? const Icon(
        Icons.chevron_right,
        color: Colors.black38,
      )
          : null,
      onTap: onTap,
    );
  }
}

class _AccountInfoTile
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AccountInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: maroon
                  .withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: maroon,
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  title,
                  style:
                  const TextStyle(
                    color:
                    Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  subtitle,
                  style:
                  const TextStyle(
                    color: deepMaroon,
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}