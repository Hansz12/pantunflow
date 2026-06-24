import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

InputDecoration appInput(String hint, {IconData? suffix}) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF927C68)),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix == null ? null : Icon(suffix, color: deepMaroon),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE5D7BB)),
      ),
    );

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 19),
          label: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: .6),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: maroon,
            foregroundColor: cream,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 3,
          ),
        ),
      );
}

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        decoration: const BoxDecoration(
          color: maroon,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: Row(
          children: [
            SizedBox(width: 42, child: leading),
            Expanded(
              child: Column(
                children: [
                  Text(title, style: const TextStyle(color: cream, fontSize: 19, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: Color(0xFFEFD9B4), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 42),
          ],
        ),
      );
}

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: deepMaroon),
      );
}

class ProfileInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileInfo({super.key, required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: paper,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x17000000), blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: const BoxDecoration(color: maroon, shape: BoxShape.circle), child: Icon(icon, color: cream)),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 12, color: maroon)), Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: deepMaroon))])),
          ],
        ),
      );
}

class PantunMark extends StatelessWidget {
  final double size;
  const PantunMark({super.key, required this.size});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * .78,
              height: size * .78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: gold, width: 2),
                color: paper,
              ),
            ),
            Icon(Icons.water_drop_rounded, size: size * .46, color: maroon),
            Positioned(top: size * .08, child: Icon(Icons.auto_awesome, size: size * .21, color: gold)),
            Positioned(bottom: size * .08, child: Container(width: size * .4, height: 3, color: deepMaroon)),
          ],
        ),
      );
}

class BatikBackground extends StatelessWidget {
  final Widget child;
  const BatikBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: cream)),
          const Positioned(top: -45, right: -32, child: _BatikMotif(size: 155)),
          const Positioned(bottom: -56, left: -42, child: _BatikMotif(size: 170)),
          Positioned.fill(child: child),
        ],
      );
}

class _BatikMotif extends StatelessWidget {
  final double size;
  const _BatikMotif({required this.size});

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: .11,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(
              5,
              (index) => Transform.rotate(
                angle: index * pi / 5,
                child: Container(
                  width: size * .74,
                  height: size * .74,
                  decoration: BoxDecoration(
                    border: Border.all(color: maroon, width: 2),
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
