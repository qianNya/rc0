import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/screenplay_card.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../screenplay/presentation/widgets/screenplay_delete_actions.dart';
import '../../../user/data/user_profile_repository.dart';

class ProfileWorksPage extends StatefulWidget {
  const ProfileWorksPage({super.key});

  @override
  State<ProfileWorksPage> createState() => _ProfileWorksPageState();
}

class _ProfileWorksPageState extends State<ProfileWorksPage> {
  final _local = ScreenplayLocalRepository.instance;
  final _userRepo = UserProfileRepository.instance;
  final _auth = AuthRepository.instance;

  List<Screenplay> _remote = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _local.addListener(_onChanged);
    _load();
  }

  @override
  void dispose() {
    _local.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final profile = _auth.profile;
    if (_auth.isLoggedIn && profile != null) {
      final result = await _userRepo.listUserScreenplays(profile.id.toInt());
      if (!mounted) return;
      setState(() {
        _remote = result.items;
        _error = result.error;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteLocal(Screenplay script) async {
    final confirmed = await confirmDeleteScreenplay(context, title: script.title);
    if (!confirmed || !mounted) return;
    await _local.deleteScreenplay(script.id);
  }

  @override
  Widget build(BuildContext context) {
    final drafts = _local.localScreenplays;
    final isEmpty = drafts.isEmpty && _remote.isEmpty && !_loading;

    return Scaffold(
      appBar: AppBar(title: const Text('作品库')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : isEmpty
                ? ListView(
                    children: [
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                      EmptyStateView(
                        icon: Icons.folder_open_outlined,
                        title: '暂无作品',
                        subtitle: '创作后会显示在这里',
                        actionLabel: '开始创作',
                        onAction: () => context.go(AppRoutes.create),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: AppColors.badgeHot),
                          ),
                        ),
                      if (_remote.isNotEmpty) ...[
                        const Text(
                          '已发布',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                          itemCount: _remote.length,
                          itemBuilder: (_, i) {
                            final script = _remote[i];
                            return ScreenplayCard(
                              screenplay: script,
                              compact: true,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (drafts.isNotEmpty) ...[
                        const Text(
                          '本地草稿',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                          itemCount: drafts.length,
                          itemBuilder: (_, i) {
                            final script = drafts[i];
                            return ScreenplayCard(
                              screenplay: script,
                              compact: true,
                              onDelete: () => _deleteLocal(script),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
      ),
    );
  }
}
