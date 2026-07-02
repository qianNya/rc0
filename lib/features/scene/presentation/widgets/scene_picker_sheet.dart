import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/scene_repository.dart';
import '../../domain/scene_entry.dart';
import 'scene_create_sheet.dart';

class ScenePickerSheet extends StatefulWidget {
  const ScenePickerSheet({
    super.key,
    this.selectedSceneId,
  });

  final String? selectedSceneId;

  static Future<SceneEntry?> show(
    BuildContext context, {
    String? selectedSceneId,
  }) {
    return showModalBottomSheet<SceneEntry>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ScenePickerSheet(
        selectedSceneId: selectedSceneId,
      ),
    );
  }

  @override
  State<ScenePickerSheet> createState() => _ScenePickerSheetState();
}

class _ScenePickerSheetState extends State<ScenePickerSheet> {
  final _repo = SceneRepository.instance;
  final _searchController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _repo.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _repo.loadFirstPage(
      q: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;
    final items = _repo.filteredItems;

    return SizedBox(
      height: maxHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text('选择场景', style: AppTextStyles.title),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final createdId = await showSceneCreateSheet(
                      context,
                      useRootNavigator: true,
                    );
                    if (!context.mounted || createdId == null) return;
                    final result = await _repo.fetchDetail(createdId);
                    final entry = result.scene;
                    if (entry != null && context.mounted) {
                      Navigator.pop(context, entry);
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('新建'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '搜索场景',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.block_outlined),
            title: const Text('不绑定场景'),
            selected: widget.selectedSceneId == null,
            onTap: () => Navigator.pop(context),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? const Center(child: Text('暂无场景'))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final entry = items[index];
                          final selected = entry.id == widget.selectedSceneId;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.accentLight,
                              child: const Icon(
                                Icons.landscape_outlined,
                                color: AppColors.accent,
                                size: 20,
                              ),
                            ),
                            title: Text(entry.title),
                            subtitle: Text(
                              entry.location.isNotEmpty
                                  ? entry.location
                                  : entry.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            selected: selected,
                            trailing: selected
                                ? const Icon(Icons.check, color: AppColors.accent)
                                : null,
                            onTap: () => Navigator.pop(context, entry),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
