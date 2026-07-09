import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/character_repository.dart';
import '../../domain/character_detail_data.dart';
import '../../domain/character_entry.dart';

/// Result of character picker: character + optional costume.
class CharacterPickResult {
  const CharacterPickResult({
    required this.character,
    this.costumeId,
  });

  final CharacterEntry character;
  final int? costumeId;
}

class CharacterPickerSheet extends StatefulWidget {
  const CharacterPickerSheet({
    super.key,
    this.workId,
    this.selectedCharacterId,
    this.allowCostumePick = true,
  });

  final int? workId;
  final int? selectedCharacterId;
  final bool allowCostumePick;

  static Future<CharacterEntry?> show(
    BuildContext context, {
    int? workId,
    int? selectedCharacterId,
  }) async {
    final result = await showResult(
      context,
      workId: workId,
      selectedCharacterId: selectedCharacterId,
      allowCostumePick: false,
    );
    return result?.character;
  }

  static Future<CharacterPickResult?> showResult(
    BuildContext context, {
    int? workId,
    int? selectedCharacterId,
    bool allowCostumePick = true,
  }) {
    return showModalBottomSheet<CharacterPickResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => CharacterPickerSheet(
        workId: workId,
        selectedCharacterId: selectedCharacterId,
        allowCostumePick: allowCostumePick,
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
  CharacterEntry? _pendingCharacter;
  List<CharacterCostumeItem> _costumes = const [];
  bool _loadingCostumes = false;

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
      _pendingCharacter = null;
      _costumes = const [];
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

  Future<void> _onSelectCharacter(CharacterEntry entry) async {
    if (!widget.allowCostumePick) {
      Navigator.pop(
        context,
        CharacterPickResult(character: entry),
      );
      return;
    }

    setState(() {
      _pendingCharacter = entry;
      _loadingCostumes = true;
      _costumes = const [];
    });
    final result = await _repo.listCostumes(entry.id);
    if (!mounted) return;
    setState(() {
      _costumes = result.items;
      _loadingCostumes = false;
    });

    // No costumes → return immediately with default appearance.
    if (_costumes.isEmpty && mounted) {
      Navigator.pop(context, CharacterPickResult(character: entry));
    }
  }

  void _confirmCostume(int? costumeId) {
    final character = _pendingCharacter;
    if (character == null) return;
    Navigator.pop(
      context,
      CharacterPickResult(character: character, costumeId: costumeId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;
    final pickingCostume = _pendingCharacter != null;

    return SizedBox(
      height: maxHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                if (pickingCostume)
                  IconButton(
                    tooltip: '返回',
                    onPressed: () => setState(() {
                      _pendingCharacter = null;
                      _costumes = const [];
                    }),
                    icon: const Icon(Icons.arrow_back),
                  ),
                Expanded(
                  child: Text(
                    pickingCostume
                        ? '选择服装 · ${_pendingCharacter!.name}'
                        : '选择角色',
                    style: AppTextStyles.title,
                  ),
                ),
                if (!pickingCostume)
                  TextButton.icon(
                    onPressed: () async {
                      final createdId =
                          await context.push<int?>(AppRoutes.characterCreate);
                      if (!context.mounted || createdId == null) return;
                      final result = await _repo.fetchDetail(createdId);
                      final entry = result.character;
                      if (entry != null && context.mounted) {
                        await _onSelectCharacter(entry);
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
          if (!pickingCostume) ...[
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
          ],
          Expanded(
            child: pickingCostume
                ? _buildCostumeStep()
                : _buildCharacterStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterStep() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_items.isEmpty) {
      return const Center(child: Text('暂无角色'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      itemCount: _items.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            onTap: () => Navigator.pop(context, null),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              side: const BorderSide(color: AppColors.border),
            ),
            leading: const Icon(Icons.block),
            title: const Text('不绑定角色'),
            trailing: widget.selectedCharacterId == null
                ? const Icon(Icons.check, size: 18)
                : null,
          );
        }
        final entry = _items[index - 1];
        final selected = widget.selectedCharacterId == entry.id;
        return ListTile(
          onTap: () => _onSelectCharacter(entry),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            side: BorderSide(
              color: selected ? AppColors.accent : AppColors.border,
            ),
          ),
          leading: CircleAvatar(
            child: Text(
              entry.name.isNotEmpty ? entry.name.characters.first : '?',
            ),
          ),
          title: Text(entry.name),
          subtitle: Text(
            entry.appearance.isNotEmpty ? entry.appearance : entry.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: selected
              ? Icon(Icons.check, color: AppColors.accent)
              : (widget.allowCostumePick
                  ? const Icon(Icons.chevron_right, size: 18)
                  : null),
        );
      },
    );
  }

  Widget _buildCostumeStep() {
    if (_loadingCostumes) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      children: [
        ListTile(
          onTap: () => _confirmCostume(null),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            side: const BorderSide(color: AppColors.border),
          ),
          leading: const Icon(Icons.checkroom_outlined),
          title: const Text('默认外观'),
          subtitle: Text(
            _pendingCharacter?.appearance.isNotEmpty == true
                ? _pendingCharacter!.appearance
                : '使用角色本体外观',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
        for (final c in _costumes) ...[
          ListTile(
            onTap: () => _confirmCostume(c.id),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              side: const BorderSide(color: AppColors.border),
            ),
            leading: const Icon(Icons.checkroom),
            title: Text(c.isDefault ? '${c.name}（默认）' : c.name),
            subtitle: c.description.isEmpty
                ? null
                : Text(
                    c.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
