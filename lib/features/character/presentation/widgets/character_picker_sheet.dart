import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/character_repository.dart';
import '../../domain/character_entry.dart';

class CharacterPickerSheet extends StatefulWidget {
  const CharacterPickerSheet({
    super.key,
    this.workId,
    this.selectedCharacterId,
  });

  final int? workId;
  final int? selectedCharacterId;

  static Future<CharacterEntry?> show(
    BuildContext context, {
    int? workId,
    int? selectedCharacterId,
  }) {
    return showModalBottomSheet<CharacterEntry>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => CharacterPickerSheet(
        workId: workId,
        selectedCharacterId: selectedCharacterId,
      ),
    );
  }

  @override
  State<CharacterPickerSheet> createState() => _CharacterPickerSheetState();
}

class _CharacterPickerSheetState extends State<CharacterPickerSheet> {
  final _repo = CharacterRepository.instance;
  final _searchController = TextEditingController();
  bool _loading = true;
  String? _error;
  List<CharacterEntry> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    if (widget.workId != null && widget.workId! > 0) {
      final result = await _repo.fetchWorkCharacters(
        workId: widget.workId!,
        q: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _items = result.items;
        _error = result.error;
        _loading = false;
      });
      return;
    }

    await _repo.loadFirstPage(
      q: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _items = _repo.items;
      _error = _repo.error;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;
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
                  child: Text('选择角色', style: AppTextStyles.title),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final createdId =
                        await context.push<int?>(AppRoutes.characterCreate);
                    if (!context.mounted || createdId == null) return;
                    final result =
                        await _repo.fetchDetail(createdId);
                    final entry = result.character;
                    if (entry != null && context.mounted) {
                      Navigator.pop(context, entry);
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('新建'),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索角色',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _load,
                ),
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _items.isEmpty
                        ? const Center(child: Text('暂无角色'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _items.length + 1,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return ListTile(
                                  onTap: () => Navigator.pop(context, null),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusMd,
                                    ),
                                    side: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  leading: const Icon(Icons.block),
                                  title: const Text('不绑定角色'),
                                  trailing: widget.selectedCharacterId == null
                                      ? const Icon(Icons.check, size: 18)
                                      : null,
                                );
                              }
                              final entry = _items[index - 1];
                              final selected =
                                  widget.selectedCharacterId == entry.id;
                              return ListTile(
                                onTap: () => Navigator.pop(context, entry),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd,
                                  ),
                                  side: BorderSide(
                                    color: selected
                                        ? AppColors.accent
                                        : AppColors.border,
                                  ),
                                ),
                                leading: CircleAvatar(
                                  child: Text(
                                    entry.name.isNotEmpty
                                        ? entry.name.characters.first
                                        : '?',
                                  ),
                                ),
                                title: Text(entry.name),
                                subtitle: Text(
                                  entry.appearance.isNotEmpty
                                      ? entry.appearance
                                      : entry.summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: selected
                                    ? Icon(Icons.check, color: AppColors.accent)
                                    : null,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
