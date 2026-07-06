import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../widgets/editor/ai_hub_section.dart';

class AiCreationHubPage extends StatelessWidget {
  const AiCreationHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    void openLabs(String featureId) {
      context.push(AppRoutes.labsFeature(featureId));
    }

    return DesktopStackScaffold(
      title: const Text('AI 创作'),
      onBack: () => popOrGoStudio(context),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          const AiHubHeroBanner(),
          AiHubSection(
            title: 'AI 拆解',
            items: [
              AiFeatureItem(
                title: '导入剧本',
                subtitle: '上传剧本文本智能解析',
                icon: Icons.upload_file_outlined,
                onTap: () => openLabs('import_script'),
              ),
              AiFeatureItem(
                title: 'AI 生成大纲',
                subtitle: '根据创意生成剧本结构',
                icon: Icons.account_tree_outlined,
                onTap: () => openLabs('gen_outline'),
              ),
              AiFeatureItem(
                title: 'AI 扩写剧情',
                subtitle: '丰富场次与画面描述',
                icon: Icons.auto_stories_outlined,
                onTap: () => openLabs('gen_plot'),
              ),
              AiFeatureItem(
                title: 'AI 生成分镜',
                subtitle: '自动拆解为分镜画面',
                icon: Icons.view_comfy_outlined,
                onTap: () => openLabs('gen_storyboard'),
              ),
            ],
          ),
          AiHubSection(
            title: 'AI 生成',
            items: [
              AiFeatureItem(
                title: '生成提示词',
                subtitle: '为画面生成 AI 提示词',
                icon: Icons.text_fields_outlined,
                onTap: () => openLabs('gen_prompt'),
              ),
              AiFeatureItem(
                title: '生成图片',
                subtitle: '根据分镜生成参考图',
                icon: Icons.image_outlined,
                onTap: () => openLabs('gen_image'),
              ),
              AiFeatureItem(
                title: '生成视频',
                subtitle: '将分镜转为动态预览',
                icon: Icons.videocam_outlined,
                onTap: () => openLabs('gen_video'),
              ),
              AiFeatureItem(
                title: '角色一致性',
                subtitle: '保持角色外观统一',
                icon: Icons.people_outline,
                onTap: () => openLabs('character_consistency'),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
