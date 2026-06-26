import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../auth/data/auth_repository.dart';
import '../../domain/character_entry.dart';
import '../../data/character_repository.dart';

class CharacterDetailPage extends StatefulWidget {
  const CharacterDetailPage({super.key, required this.characterId});

  final int characterId;

  @override
  State<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends State<CharacterDetailPage> {
  final _repo = CharacterRepository.instance;
  final _auth = AuthRepository.instance;
  bool _loading = true;
  String? _error;
  CharacterEntry? _entry;

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
    if (!mounted) return;
    setState(() {
      _entry = result.character;
      _error = result.error;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entry;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          entry?.name.isNotEmpty == true ? entry!.name : '角色详情',
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : entry == null
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                    EmptyStateView(
                      icon: Icons.person_outline,
                      title: _error ?? '角色不存在',
                      subtitle: _error,
                      actionLabel: _error != null ? '重试' : null,
                      onAction: _error != null ? _load : null,
                    ),
                  ],
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.surfaceSecondary,
                        child: Text(
                          entry.name.isNotEmpty
                              ? entry.name.characters.first
                              : '?',
                          style: AppTextStyles.title.copyWith(fontSize: 28),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(entry.name, style: AppTextStyles.title),
                      if (entry.nameOrig.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(entry.nameOrig, style: AppTextStyles.bodySecondary),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        [
                          entry.genderLabel,
                          if (entry.displaySubtitle.isNotEmpty)
                            entry.displaySubtitle,
                        ].join(' · '),
                        style: AppTextStyles.bodySecondary.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                      if (entry.aliases.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '别名：${entry.aliases.join('、')}',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                      if (entry.summary.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text('简介', style: AppTextStyles.label),
                        const SizedBox(height: 4),
                        Text(entry.summary, style: AppTextStyles.body),
                      ],
                      if (entry.appearance.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text('外观设定', style: AppTextStyles.label),
                        const SizedBox(height: 4),
                        Text(entry.appearance, style: AppTextStyles.body),
                      ],
                      if (entry.personality.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text('性格 / 人设', style: AppTextStyles.label),
                        const SizedBox(height: 4),
                        Text(entry.personality, style: AppTextStyles.body),
                      ],
                      if (!_auth.isLoggedIn) ...[
                        const SizedBox(height: 24),
                        Text(
                          '登录后可编辑角色',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
