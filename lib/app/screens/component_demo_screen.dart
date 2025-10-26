import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class ComponentDemoScreen extends StatelessWidget {
  const ComponentDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.componentDemo),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.buttons,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                CustomButton(
                  text: 'Primary Button',
                  onPressed: () {},
                  variant: ButtonVariant.primary,
                ),
                CustomButton(
                  text: 'Secondary Button',
                  onPressed: () {},
                  variant: ButtonVariant.secondary,
                ),
                CustomButton(
                  text: 'Outlined Button',
                  onPressed: () {},
                  variant: ButtonVariant.outlined,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              l10n.textFields,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const CustomTextField(
              label: 'Text Field',
              hint: 'Enter text here...',
            ),
            const SizedBox(height: 16),
            const CustomTextField(
              label: 'Password Field',
              hint: 'Enter password...',
              obscureText: true,
            ),
            const SizedBox(height: 16),
            const CustomTextField(
              label: 'Disabled Field',
              hint: 'This field is disabled',
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }
}
