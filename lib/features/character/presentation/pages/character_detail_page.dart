import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/auth_providers.dart';
import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../../../shared/widgets/rc0_image.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../scene/data/scene_repository.dart';
import '../../data/character_local_store.dart';
import '../../data/character_repository.dart';
import '../../domain/character_detail_data.dart';
import '../../domain/character_entry.dart';
import '../widgets/character_action_sheet.dart';
import '../widgets/detail/character_costumes_tab.dart';
import '../widgets/detail/character_info_card.dart';
import '../widgets/detail/character_info_tab.dart';
import '../widgets/detail/character_props_tab.dart';
import '../widgets/detail/character_scenes_tab.dart';
import '../widgets/detail/character_works_tab.dart';
import '../../../../shared/widgets/glass/glass.dart';

class CharacterDetailPage extends ConsumerStatefulWidget {
  const CharacterDetailPage({super.key, required this.characterId});

  final int characterId;

  @override
  ConsumerState<CharacterDetailPage> createState() =>
      _CharacterDetailPageState();
}

class _CharacterDetailPageState extends ConsumerState<CharacterDetailPage> {
  final _repo = CharacterRepository.instance;
  bool _loading = true;
  String? _error;
  CharacterEntry? _entry;
  CharacterDetailSnapshot? _snapshot;
  bool _favorite = false;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _repo.fetchDetail(widget.characterId);
    final favorite =
        await CharacterLocalStore.instance.isFavorite(widget.characterId);
    final localCover =
        await CharacterLocalStore.instance.localCoverPath(widget.characterId);
    final refs = await CharacterLocalStore.instance
        .referenceImageUrls(widget.characterId);

    final costumes = await _repo.listCostumes(widget.characterId);
    final props = await _repo.listProps(widget.characterId);
    final affinities = await _repo.listAffinities(widget.characterId);
    final works = await _repo.listCharacterScreenplays(widget.characterId);

    final enrichedAffinities = await _enrichAffinities(affinities.items);

    if (!mounted) return;

    final entry = result.character;
    final refCount = refs.isEmpty
        ? (entry?.coverUrl.isNotEmpty == true ? 1 : 0)
        : refs.length;

    setState(() {
      _entry = entry;
      _error = result.error;
      _favorite = favorite;
      _snapshot = entry == null
          ? null
          : buildCharacterDetailSnapshot(
              entry: entry,
              referenceCount: refCount,
              localCover: localCover,
              costumes: costumes.items,
              props: props.items,
              affinities: enrichedAffinities,
              works: works.items,
            );
      _loading = false;
    });
  }

  Future<List<CharacterSceneAffinityItem>> _enrichAffinities(
    List<CharacterSceneAffinityItem> items,
  ) async {
    if (items.isEmpty) return items;
    final sceneRepo = SceneRepository.instance;
    final out = <CharacterSceneAffinityItem>[];
    for (final item in items) {
      final detail = await sceneRepo.fetchDetail(item.sceneId.toString());
      final scene = detail.scene;
      out.add(
        CharacterSceneAffinityItem(
          id: item.id,
          sceneId: item.sceneId,
          weight: item.weight,
          note: item.note,
          sceneTitle: scene?.title ?? '',
          sceneCoverUrl: scene?.coverUrl ?? '',
        ),
      );
    }
    return out;
  }

  Future<void> _toggleFavorite() async {
    final next = !_favorite;
    await CharacterLocalStore.instance.setFavorite(widget.characterId, next);
    if (!mounted) return;
    setState(() => _favorite = next);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(next ? '已收藏' : '已取消收藏')));
  }

  void _startCreation(BuildContext context) {
    final entry = _entry;
    if (entry == null) return;
    context.push(
      AppRoutes.studioEditorCreateWithCharacter(
        entry.id,
        name: entry.name,
      ),
    );
  }

  void _previewLighting(BuildContext context) {
    context.push(
      AppRoutes.lightingWithContext(characterId: widget.characterId),
    );
  }

  Future<void> _showAddCostumeSheet() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final created = await showGlassSheet<bool>(
      context,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('添加服装', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppDimensions.spacingMd),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '服装名称'),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '外观描述',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                Navigator.of(context).pop(true);
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );
    final name = nameController.text.trim();
    final description = descController.text.trim();
    nameController.dispose();
    descController.dispose();
    if (created != true || name.isEmpty) return;

    final result = await _repo.createCostume(
      widget.characterId,
      name: name,
      description: description,
      isDefault: (_snapshot?.costumes.isEmpty ?? true),
    );
    if (!mounted) return;
    if (result.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }
    await _load();
  }

  Future<void> _showAddPropSheet() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final created = await showGlassSheet<bool>(
      context,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('添加道具', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppDimensions.spacingMd),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '道具名称'),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '描述',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                Navigator.of(context).pop(true);
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );
    final name = nameController.text.trim();
    final description = descController.text.trim();
    nameController.dispose();
    descController.dispose();
    if (created != true || name.isEmpty) return;

    final result = await _repo.createProp(
      widget.characterId,
      name: name,
      description: description,
    );
    if (!mounted) return;
    if (result.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }
    await _load();
  }

  Future<void> _setDefaultCostume(CharacterCostumeItem costume) async {
    final result =
        await _repo.setDefaultCostume(widget.characterId, costume.id);
    if (!mounted) return;
    if (result.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entry;
    final snapshot = _snapshot;
    final canEdit = ref.watch(isLoggedInProvider);

    final immersive = entry != null && snapshot != null;

    return DesktopStackScaffold(
      overlayAppBar: immersive,
      appBarForegroundColor: immersive ? Colors.white : null,
      title: immersive
          ? const SizedBox.shrink()
          : Text(entry?.name.isNotEmpty == true ? entry!.name : '角色详情'),
      centerTitle: false,
      onBack: () => popOrGoDiscovery(context),
      actions: [
        if (entry != null)
          IconButton(
            icon: const Icon(Icons.wb_incandescent_outlined),
            tooltip: '预览灯光',
            onPressed: () => _previewLighting(context),
          ),
        if (entry != null)
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => showCharacterActionSheet(
              context: context,
              entry: entry,
              repo: _repo,
              isLoggedIn: canEdit,
              isFavorite: _favorite,
              onToggleFavorite: _toggleFavorite,
              onRefresh: _load,
            ),
          ),
      ],
      floatingActionButton: entry == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(
                right: AppDimensions.spacingMd,
                bottom: AppDimensions.spacingLg,
              ),
              child: _CreateFab(onPressed: () => _startCreation(context)),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : entry == null || snapshot == null
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                    GlassEmptyState(
                      icon: Icons.person_outline,
                      title: _error ?? '角色不存在',
                      subtitle: _error,
                      actionLabel: _error != null ? '重试' : null,
                      onAction: _error != null ? _load : null,
                    ),
                  ],
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _CharacterHeader(
                        snapshot: snapshot,
                        isFavorite: _favorite,
                        onFavorite: _toggleFavorite,
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: PinnedFeedTabBarDelegate(
                        tabs: AppCatalog.characterDetailTabs,
                        selectedIndex: _tabIndex,
                        onChanged: (index) => setState(() => _tabIndex = index),
                        backgroundColor: AppColors.pageBackground,
                      ),
                    ),
                    SliverFillRemaining(
                      child: FadeSlideIndexedStack(
                        index: _tabIndex,
                        children: [
                          CharacterInfoTab(entry: entry, snapshot: snapshot),
                          CharacterCostumesTab(
                            costumes: snapshot.costumes,
                            canEdit: canEdit,
                            onAdd: canEdit ? _showAddCostumeSheet : null,
                            onSetDefault:
                                canEdit ? _setDefaultCostume : null,
                          ),
                          CharacterPropsTab(
                            props: snapshot.props,
                            canEdit: canEdit,
                            onAdd: canEdit ? _showAddPropSheet : null,
                          ),
                          CharacterScenesTab(affinities: snapshot.affinities),
                          CharacterWorksTab(works: snapshot.works),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _CharacterHeader extends StatelessWidget {
  const _CharacterHeader({
    required this.snapshot,
    required this.isFavorite,
    required this.onFavorite,
  });

  final CharacterDetailSnapshot snapshot;
  final bool isFavorite;
  final VoidCallback onFavorite;

  static const double _heroHeight = 320;
  static const double _cardOverlap = 40;

  @override
  Widget build(BuildContext context) {
    final coverPath = snapshot.coverPath;

    return Column(
      children: [
        SizedBox(
          height: _heroHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (coverPath.isNotEmpty)
                Rc0Image(path: coverPath, fit: BoxFit.cover)
              else
                const PlaceholderImage(aspectRatio: 16 / 9, borderRadius: 0),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.heroScrimTop,
                      AppColors.heroScrimMid,
                      AppColors.heroScrimBottom,
                    ],
                    stops: [0.0, 0.35, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -_cardOverlap),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
            ),
            child: CharacterInfoCard(
              snapshot: snapshot,
              isFavorite: isFavorite,
              onFavorite: onFavorite,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
      ],
    );
  }
}

class _CreateFab extends StatelessWidget {
  const _CreateFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.profileGradientEnd],
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: AppShadows.floatingBar,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_camera_outlined, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                '开始创作',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
