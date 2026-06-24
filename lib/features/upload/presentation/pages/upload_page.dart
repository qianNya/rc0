import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_builder.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../studio/presentation/screenplay_editor_host.dart';
import '../widgets/upload_screenplay_preview_section.dart';

/// New screenplay creation wizard (editing redirects to `/studio?edit=`).
class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenplayEditorHost(
      builder: (context, controller) => _UploadPageContent(
        controller: controller,
      ),
    );
  }
}

class _UploadPageContent extends StatelessWidget {
  const _UploadPageContent({required this.controller});

  final ScreenplayEditorController controller;

  @override
  Widget build(BuildContext context) {
    const pageTitle = '上传剧本';

    return ResponsiveBuilder(
      mobile: (_) => Scaffold(
        appBar: AppBar(
          title: const Text(pageTitle),
          leading: TextButton(
            onPressed: controller.onCancel,
            child: const Text('取消'),
          ),
          leadingWidth: 72,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildForm(compact: true),
              if (controller.isPicking || controller.isPublishing)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
      desktop: (_) => Scaffold(
        appBar: AppBar(
          title: const Text(pageTitle),
          leading: TextButton(
            onPressed: controller.onCancel,
            child: const Text('取消'),
          ),
          leadingWidth: 72,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildForm(compact: false),
              if (controller.isPicking || controller.isPublishing)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              const SizedBox(height: 24),
              SizedBox(width: 480, child: _buildActionButtons()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm({required bool compact}) {
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreviewSection(),
          const SizedBox(height: 24),
          controller.buildStructureEditor(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildPreviewSection()),
        const SizedBox(width: 32),
        Expanded(flex: 2, child: controller.buildStructureEditor()),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return UploadScreenplayPreviewSection(
      draft: controller.draft,
      titleController: controller.titleController,
      synopsisController: controller.synopsisController,
      onShootParamsChanged: controller.onShootParamsChanged,
      poolTags: controller.poolTags,
      onToggleScreenplayTag: controller.toggleScreenplayTag,
      onAddScreenplayTag: controller.addScreenplayTag,
      tagsLoading: controller.tagsLoading,
      tagsError: controller.tagsError,
      onRetryTags: controller.retryTags,
      onPickCover: controller.onPickCover,
      onResetCover: controller.onResetCover,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            label: '保存到本地',
            onPressed: controller.isPublishing || !controller.draft.hasFrames
                ? null
                : () => controller.onSaveLocal(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            label: '发布到云端',
            onPressed: controller.isPublishing || !controller.draft.hasFrames
                ? null
                : controller.onPublishToCloud,
            isLoading: controller.isPublishing,
          ),
        ),
      ],
    );
  }
}
