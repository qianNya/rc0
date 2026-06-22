import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_shadows.dart';

class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    super.key,
    required this.header,
    required this.form,
    this.footer,
    this.onBack,
    this.onHelp,
  });

  final Widget header;
  final Widget form;
  final Widget? footer;
  final VoidCallback? onBack;
  final VoidCallback? onHelp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onHelp,
                    child: const Text('帮助'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accent.withValues(alpha: 0.08),
                            AppColors.accentLight,
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusLg),
                      ),
                      child: header,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusLg),
                        boxShadow: AppShadows.card,
                      ),
                      child: form,
                    ),
                    if (footer != null) ...[
                      const SizedBox(height: 24),
                      footer!,
                    ],
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
