import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/system_ui_style.dart';
import 'media_vault_colors.dart';

class MediaVaultTopBar extends StatelessWidget implements PreferredSizeWidget {
  const MediaVaultTopBar({
    super.key,
    this.onSearch,
    this.onFilter,
    this.onUpload,
    this.uploading = false,
  });

  final VoidCallback? onSearch;
  final VoidCallback? onFilter;
  final VoidCallback? onUpload;
  final bool uploading;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.lightStyle,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: MediaVaultColors.background,
          border: Border(bottom: BorderSide(color: MediaVaultColors.border)),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onSearch,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: MediaVaultColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: MediaVaultColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search_rounded,
                                  size: 18,
                                  color: MediaVaultColors.textTertiary,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    '搜索图片、标签、内容…',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: MediaVaultColors.textTertiary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: MediaVaultColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '⌘K',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: MediaVaultColors.textTertiary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _IconBtn(
                    icon: Icons.tune_rounded,
                    onPressed: onFilter,
                    tooltip: '筛选',
                  ),
                  const SizedBox(width: 4),
                  _UploadBtn(onPressed: uploading ? null : onUpload, loading: uploading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: MediaVaultColors.textSecondary, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _UploadBtn extends StatelessWidget {
  const _UploadBtn({this.onPressed, this.loading = false});

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: MediaVaultColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      icon: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.upload_rounded, size: 16),
      label: Text(loading ? '上传中' : '上传', style: const TextStyle(fontSize: 13)),
    );
  }
}
