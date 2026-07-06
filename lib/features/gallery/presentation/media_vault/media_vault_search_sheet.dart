import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../data/media_vault_repository.dart';
import '../../domain/media_vault_image.dart';
import 'media_vault_colors.dart';

Future<MediaVaultImage?> showMediaVaultSearchSheet(BuildContext context) {
  return showGlassScrollSheet<MediaVaultImage>(
    context,
    maxHeightFraction: 0.8,
    padding: const EdgeInsets.fromLTRB(
      AppDimensions.spacingMd,
      0,
      AppDimensions.spacingMd,
      AppDimensions.spacingMd,
    ),
    builder: (context, maxHeight) => _SearchBody(maxHeight: maxHeight),
  );
}

class _SearchBody extends StatefulWidget {
  const _SearchBody({required this.maxHeight});

  final double maxHeight;

  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> {
  final _controller = TextEditingController();
  List<MediaVaultImage> _results = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      _results = MediaVaultRepository.instance.filtered(query: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.maxHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: MediaVaultColors.textPrimary),
            decoration: InputDecoration(
              hintText: '关键词、标签、内容搜索…',
              hintStyle: const TextStyle(color: MediaVaultColors.textTertiary),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: MediaVaultColors.textSecondary,
              ),
              filled: true,
              fillColor: MediaVaultColors.surfaceElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _search,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Text(
                      _controller.text.isEmpty ? '输入关键词搜索' : '无匹配图片',
                      style: const TextStyle(
                        color: MediaVaultColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (_, _) => Divider(
                      color: MediaVaultColors.border,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final img = _results[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: MediaVaultColors.accentGlow,
                          child: Icon(
                            img.placeholderIcon ?? Icons.image_outlined,
                            color: MediaVaultColors.accent,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          img.title,
                          style: const TextStyle(
                            color: MediaVaultColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          img.tags.take(2).join(' '),
                          style: const TextStyle(
                            color: MediaVaultColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(img),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
