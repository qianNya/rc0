import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/domain/screenplay/script_act.dart';
import '../../../../core/domain/screenplay/script_scene.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../widgets/screenplay_info_header.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/primary_button.dart';

class ScreenplayDetailPage extends StatefulWidget {
  const ScreenplayDetailPage({super.key, required this.scriptId});

  final String scriptId;

  @override
  State<ScreenplayDetailPage> createState() => _ScreenplayDetailPageState();
}

class _ScreenplayDetailPageState extends State<ScreenplayDetailPage> {
  final _repository = ScreenplayLocalRepository.instance;

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _repository.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => setState(() {});

  Screenplay? get _screenplay => _repository.findById(widget.scriptId);

  void _onEdit(BuildContext context, Screenplay script) {
    context.go(AppRoutes.uploadEdit(script.id));
  }

  @override
  Widget build(BuildContext context) {
    final script = _screenplay;
    if (script == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => popOrGoExplore(context),
          ),
          title: const Text('剧本详情'),
        ),
        body: const EmptyStateView(
          icon: Icons.search_off_outlined,
          title: '剧本不存在',
          subtitle: '可能已被删除，或链接无效',
        ),
      );
    }

    return ResponsiveBuilder(
      mobile: (_) => _ScreenplayDetailMobile(
        screenplay: script,
        onEdit: () => _onEdit(context, script),
      ),
      desktop: (_) => _ScreenplayDetailDesktop(
        screenplay: script,
        onEdit: () => _onEdit(context, script),
      ),
    );
  }
}

class _ScreenplayDetailMobile extends StatelessWidget {
  const _ScreenplayDetailMobile({
    required this.screenplay,
    required this.onEdit,
  });

  final Screenplay screenplay;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final frames = screenplay.allFrames;
    final framePaths = frames.map((f) => f.imagePath).toList();
    final frameCaptions = frames.map((f) => f.caption).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('剧本详情'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => popOrGoExplore(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: '编辑剧本',
            onPressed: onEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (frames.isNotEmpty)
              SizedBox(
                height: 240,
                child: PageView.builder(
                  itemCount: frames.length,
                  itemBuilder: (_, index) => PoseCoverImage(
                    imagePath: frames[index].imagePath,
                    expand: true,
                    borderRadius: 0,
                    enablePreview: true,
                    previewGallery: framePaths,
                    previewIndex: index,
                    previewCaptions: frameCaptions,
                  ),
                ),
              )
            else
              const SizedBox(
                height: 200,
                child: PoseCoverImage(expand: true, borderRadius: 0),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScreenplayInfoHeader(screenplay: screenplay),
                  const SizedBox(height: 20),
                  const Text('结构', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  for (final act in screenplay.acts)
                    _ActExpansion(
                      act: act,
                      framePaths: framePaths,
                      frameCaptions: frameCaptions,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryButton(
            label: '编辑剧本',
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }
}

class _ScreenplayDetailDesktop extends StatelessWidget {
  const _ScreenplayDetailDesktop({
    required this.screenplay,
    required this.onEdit,
  });

  final Screenplay screenplay;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final frames = screenplay.allFrames;
    final framePaths = frames.map((f) => f.imagePath).toList();
    final frameCaptions = frames.map((f) => f.caption).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => popOrGoExplore(context),
        ),
        title: Text(screenplay.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: '编辑剧本',
            onPressed: onEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (frames.isNotEmpty)
                    PoseCoverImage(
                      imagePath: frames.first.imagePath,
                      aspectRatio: 1.1,
                      iconSize: 64,
                      enablePreview: true,
                      previewGallery: framePaths,
                      previewCaptions: frameCaptions,
                    )
                  else
                    const PoseCoverImage(aspectRatio: 1.1, iconSize: 64),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: frames.length,
                    itemBuilder: (_, index) => PoseCoverImage(
                      imagePath: frames[index].imagePath,
                      aspectRatio: 1,
                      iconSize: 24,
                      borderRadius: AppDimensions.radiusSm,
                      enablePreview: true,
                      previewGallery: framePaths,
                      previewIndex: index,
                      previewCaptions: frameCaptions,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScreenplayInfoHeader(screenplay: screenplay),
                  const SizedBox(height: 20),
                  const Text('结构', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  for (final act in screenplay.acts)
                    _ActExpansion(
                      act: act,
                      framePaths: framePaths,
                      frameCaptions: frameCaptions,
                    ),
                  const SizedBox(height: 24),
                  PrimaryButton(label: '编辑剧本', onPressed: onEdit),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActExpansion extends StatelessWidget {
  const _ActExpansion({
    required this.act,
    required this.framePaths,
    required this.frameCaptions,
  });

  final ScriptAct act;
  final List<String> framePaths;
  final List<String> frameCaptions;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.radiusMd);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: EdgeInsets.zero,
          backgroundColor: AppColors.surface,
          collapsedBackgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: radius),
          collapsedShape: RoundedRectangleBorder(borderRadius: radius),
          title: Text(act.title, style: AppTextStyles.label),
          subtitle: Text(
            '${act.sceneCount}场 · ${act.frameCount}画',
            style: AppTextStyles.bodySecondary,
          ),
          children: [
            if (act.synopsis.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(act.synopsis, style: AppTextStyles.bodySecondary),
                ),
              ),
            for (final scene in act.scenes)
              _SceneSection(
                scene: scene,
                framePaths: framePaths,
                frameCaptions: frameCaptions,
              ),
          ],
        ),
      ),
    );
  }
}

class _SceneSection extends StatelessWidget {
  const _SceneSection({
    required this.scene,
    required this.framePaths,
    required this.frameCaptions,
  });

  final ScriptScene scene;
  final List<String> framePaths;
  final List<String> frameCaptions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(scene.title, style: AppTextStyles.label),
          if (scene.location.isNotEmpty || scene.timeOfDay.isNotEmpty)
            Text(
              [scene.location, scene.timeOfDay]
                  .where((e) => e.isNotEmpty)
                  .join(' · '),
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
            ),
          if (scene.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(scene.description, style: AppTextStyles.bodySecondary),
          ],
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: scene.frames.length,
            itemBuilder: (_, index) {
              final frame = scene.frames[index];
              final globalIndex = framePaths.indexOf(frame.imagePath);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: PoseCoverImage(
                      imagePath: frame.imagePath,
                      expand: true,
                      borderRadius: AppDimensions.radiusSm,
                      iconSize: 20,
                      enablePreview: true,
                      previewGallery: framePaths,
                      previewIndex: globalIndex >= 0 ? globalIndex : index,
                      previewCaptions: frameCaptions,
                    ),
                  ),
                  if (frame.caption.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        frame.caption,
                        style: AppTextStyles.bodySecondary.copyWith(
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
