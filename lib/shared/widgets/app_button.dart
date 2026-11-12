import 'package:flutter/material.dart';

/// Wspólny przycisk aplikacji.
///
/// [primary] – wypełniony przycisk (główna akcja, np. "Log in").
/// [secondary] – przycisk z obramowaniem (akcja poboczna, np. "Log out").
/// Gdy [isLoading] = true, przycisk jest nieaktywny i pokazuje spinner.
enum AppButtonVariant { primary, secondary }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? action = isLoading ? null : onPressed;

    final Widget child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: switch (variant) {
        AppButtonVariant.primary =>
          FilledButton(onPressed: action, child: child),
        AppButtonVariant.secondary =>
          OutlinedButton(onPressed: action, child: child),
      },
    );
  }
}
