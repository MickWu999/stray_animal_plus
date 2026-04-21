import 'dart:math';
import 'package:flutter/material.dart';
import '../app_theme.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  static const List<String> _dogImages = [
    'assets/images/dog/alvan-nee-T-0EW-SEbsE-unsplash.jpg',
    'assets/images/dog/baptist-standaert-mx0DEnfYxic-unsplash.jpg',
    'assets/images/dog/joe-caione-qO-PIF84Vxg-unsplash.jpg',
    'assets/images/dog/login_dog.jpg',
    'assets/images/dog/milli-2l0CWTpcChI-unsplash.jpg',
    'assets/images/dog/oscar-sutton-yihlaRCCvd4-unsplash.jpg',
    'assets/images/dog/richard-brutyo-Sg3XwuEpybU-unsplash.jpg',
  ];

  late final String _selectedDogImage;

  @override
  void initState() {
    super.initState();
    _selectedDogImage = _dogImages[Random().nextInt(_dogImages.length)];
  }

  void _onExplorePressed() {}

  void _onLoginPressed() {}

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double imageTop = size.height * 0.30;

    return Scaffold(
      body: ColoredBox(
        color: AppTheme.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _DogBackground(
              imagePath: _selectedDogImage,
              top: imageTop,
            ),
            _FadeOverlay(
              top: imageTop - 180,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 170,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '帶我回家',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.text,
                        height: 1.05,
                      ),
                    ),
                    const Text(
                      '流浪動物認養 App',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.subText,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '給牠一個家，牠會用一生愛你 ♥',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0x66000000),
                            offset: Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _PrimaryButton(
                      label: '開始探索',
                      onPressed: _onExplorePressed,
                    ),
                    const SizedBox(height: 12),
                    _SecondaryButton(
                      label: '登入 / 註冊',
                      onPressed: _onLoginPressed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DogBackground extends StatelessWidget {
  const _DogBackground({required this.imagePath, required this.top});

  final String imagePath;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      top: top,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.28],
            colors: [Colors.transparent, Colors.white],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}

class _FadeOverlay extends StatelessWidget {
  const _FadeOverlay({required this.top});

  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      top: top,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.18, 0.38, 0.62, 0.82, 1.0],
              colors: [
                AppTheme.background,
                AppTheme.background.withValues(alpha: 0.65),
                AppTheme.background.withValues(alpha: 0.25),
                AppTheme.background.withValues(alpha: 0.1),
                AppTheme.background.withValues(alpha: 0.05),
                AppTheme.background.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryButton,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.86),
          foregroundColor: AppTheme.text,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
