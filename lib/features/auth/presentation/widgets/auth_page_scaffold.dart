import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/platform/platform_features.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/desktop/desktop_card.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/glass/glass_card.dart';

class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    super.key,
    required this.header,
    required this.form,
    this.footer,
    this.onBack,
    this.onHelp,
    this.desktopTitle,
  });

  final Widget header;
  final Widget form;
  final Widget? footer;
  final VoidCallback? onBack;
  final VoidCallback? onHelp;
  final String? desktopTitle;

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accent.withValues(alpha: 0.08),
                AppColors.accentLight,
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          child: header,
        ),
        const SizedBox(height: 20),
        GlassCard(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: form,
        ),
        if (footer != null) ...[
          const SizedBox(height: 24),
          footer!,
        ],
      ],
    );
  }

  /// A soft accent-tinted backdrop so the frosted [GlassCard] form has
  /// something to blur, producing the liquid-glass effect.
  Widget _withBackdrop(BuildContext context, Widget child) {
    final base = Theme.of(context).scaffoldBackgroundColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(
              AppColors.accent.withValues(alpha: 0.14),
              base,
            ),
            base,
          ],
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        Breakpoints.isDesktop(context) && shouldUseDesktopWindowChrome;

    if (isDesktop) {
      return DesktopStackScaffold(
        title: Text(desktopTitle ?? '账号'),
        onBack: onBack ?? () => Navigator.of(context).maybePop(),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: onHelp,
            child: const Text('帮助'),
          ),
        ],
        body: _withBackdrop(
          context,
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: DesktopCard(
                  clipChild: false,
                  padding: const EdgeInsets.all(AppDimensions.pagePadding),
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _withBackdrop(
        context,
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed:
                          onBack ?? () => Navigator.of(context).maybePop(),
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
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
