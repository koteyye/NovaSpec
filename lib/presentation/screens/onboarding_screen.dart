import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/presentation/widgets/dialogs/onboarding_dialog.dart';

/// Экран онбординга
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    // Показываем диалог после первого фрейма
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const OnboardingDialog(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NsColorsDark.background : NsColorsLight.background,
      body: const SizedBox.expand(),
    );
  }
}
