import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../../shared/widgets/rc0_widgets.dart';

const _collapseDuration = Duration(milliseconds: 200);
const _collapseCurve = Curves.easeOutCubic;

class CollapsibleTagPicker extends StatefulWidget {
  const CollapsibleTagPicker({
    super.key,
    required this.poolTags,
    required this.selectedTags,
    required this.onToggle,
    this.title = '标签',
    this.onAdd,
    this.initiallyCollapsed = false,
    this.loading = false,
    this.error,
    this.onRetry,
    this.showAddChip = true,
    this.badgeCount,
    this.collapsedSummaryTags,
  });

  final String title;
  final List<String> poolTags;
  final Set<String> selectedTags;
  final ValueChanged<String> onToggle;
  final ValueChanged<String>? onAdd;
  final bool initiallyCollapsed;
  final bool loading;
  final String? error;
  final VoidCallback? onRetry;
  final bool showAddChip;
  final int? badgeCount;
  final List<String>? collapsedSummaryTags;

  @override
  State<CollapsibleTagPicker> createState() => _CollapsibleTagPickerState();
}

class _CollapsibleTagPickerState extends State<CollapsibleTagPicker> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = !widget.initiallyCollapsed;
  }

  Future<void> _showAddDialog() async {
    if (widget.onAdd == null) return;
    final controller = TextEditingController();
    final tag = await showGlassDialog<String>(
      context,
      child: GlassDialog(
        title: const Text('添加标签'),
        onClose: () => Navigator.pop(context),
        child: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入标签名称'),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        footer: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('添加'),
              ),
            ],
          ),
        ),
      ),
    );
    if (tag != null && tag.isNotEmpty) {
      widget.onAdd!(tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = widget.badgeCount ?? widget.selectedTags.length;
    final summaryTags = widget.collapsedSummaryTags ??
        (widget.selectedTags.toList()..sort());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.title} ($selectedCount)',
                  style: AppTextStyles.label,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _expanded
                      ? const SizedBox.shrink()
                      : _TagSummaryStrip(tags: summaryTags),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: _collapseDuration,
          curve: _collapseCurve,
          alignment: Alignment.topCenter,
          child: Visibility(
            visible: _expanded,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.loading && widget.poolTags.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  if (widget.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InlineErrorBanner(
                        message: widget.error!,
                        onRetry: widget.onRetry,
                      ),
                    ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in widget.poolTags)
                        TagChip(
                          label: tag,
                          selected: widget.selectedTags.contains(tag),
                          onTap: () => widget.onToggle(tag),
                        ),
                      if (widget.showAddChip && widget.onAdd != null)
                        ActionChip(
                          label: const Text('+ 添加'),
                          onPressed: _showAddDialog,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TagSummaryStrip extends StatelessWidget {
  const _TagSummaryStrip({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return Text(
        '未选择',
        style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < tags.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            TagChip(label: tags[i], selected: true),
          ],
        ],
      ),
    );
  }
}
