import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/auth_providers.dart';
import '../../../../app/router/navigation_utils.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/system_ui_style.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../data/profile_avatar_upload_service.dart';
import '../../data/profile_background_upload_service.dart';
import '../../domain/profile_display.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import '../../../../shared/widgets/liquid_glass_surface.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/rc0_image.dart';
import '../../../../shared/widgets/shell_insets.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _nickname;
  late final TextEditingController _bio;
  late final TextEditingController _email;
  late final TextEditingController _phone;

  String _avatarUrl = '';
  String _backgroundUrl = '';
  String? _localAvatarPreviewPath;
  String? _localBackgroundPreviewPath;
  bool _saving = false;
  bool _loading = false;
  bool _uploadingAvatar = false;
  bool _uploadingBackground = false;

  @override
  void initState() {
    super.initState();
    final session = ref.read(authSessionProvider);
    final p = session.profile;
    _nickname = TextEditingController(text: p?.nickname ?? '');
    _bio = TextEditingController(text: p?.bio ?? '');
    _email = TextEditingController(text: p?.email ?? '');
    _phone = TextEditingController(text: p?.phone ?? '');
    _avatarUrl = p?.avatar ?? '';
    _backgroundUrl = p?.backgroundUrl ?? '';
    if (session.isLoggedIn && p == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
    }
  }

  @override
  void dispose() {
    _nickname.dispose();
    _bio.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!ref.read(authSessionProvider).isLoggedIn) return;
    setState(() => _loading = true);
    await ref.read(authRepositoryProvider).refreshProfile();
    if (!mounted) return;
    _syncFieldsFromProfile();
    setState(() => _loading = false);
  }

  void _syncFieldsFromProfile() {
    final p = ref.read(authSessionProvider).profile;
    if (p == null) return;
    _nickname.text = p.nickname;
    _bio.text = p.bio;
    _email.text = p.email;
    _phone.text = p.phone;
    if (!_uploadingAvatar) {
      _avatarUrl = p.avatar;
      _localAvatarPreviewPath = null;
    }
    if (!_uploadingBackground) {
      _backgroundUrl = p.backgroundUrl;
      _localBackgroundPreviewPath = null;
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_uploadingAvatar || _saving) return;

    setState(() => _uploadingAvatar = true);
    final result = await ProfileAvatarUploadService.instance.pickAndUpload();
    if (!mounted) return;

    setState(() {
      _uploadingAvatar = false;
      if (result.localPreviewPath != null && result.imageUrl == null) {
        _localAvatarPreviewPath = result.localPreviewPath;
      }
      if (result.imageUrl != null && result.imageUrl!.isNotEmpty) {
        _avatarUrl = result.imageUrl!;
        _localAvatarPreviewPath = null;
      }
    });

    if (result.error != null) {
      _showSnack(result.error!);
    } else if (result.imageUrl != null) {
      _showSnack('头像已更新，记得保存资料');
    }
  }

  Future<void> _pickAndUploadBackground() async {
    if (_uploadingBackground || _saving) return;

    setState(() => _uploadingBackground = true);
    final result = await ProfileBackgroundUploadService.instance.pickAndUpload();
    if (!mounted) return;

    setState(() {
      _uploadingBackground = false;
      if (result.localPreviewPath != null && result.imageUrl == null) {
        _localBackgroundPreviewPath = result.localPreviewPath;
      }
      if (result.imageUrl != null && result.imageUrl!.isNotEmpty) {
        _backgroundUrl = result.imageUrl!;
        _localBackgroundPreviewPath = null;
      }
    });

    if (result.error != null) {
      _showSnack(result.error!);
    } else if (result.imageUrl != null) {
      _showSnack('背景图已更新，记得保存资料');
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final err = await ref.read(authRepositoryProvider).updateProfileFields(
      nickname: _nickname.text.trim(),
      bio: _bio.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      avatar: _avatarUrl.trim(),
      backgroundUrl: _backgroundUrl.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (err != null) {
      _showSnack(err);
      return;
    }
    _showSnack('资料已更新');
    context.pop();
  }

  String? _avatarPreviewPath() {
    if (_localAvatarPreviewPath != null && _localAvatarPreviewPath!.isNotEmpty) {
      return _localAvatarPreviewPath;
    }
    return ProfileDisplay.avatarPathFromRaw(_avatarUrl);
  }

  String? _backgroundPreviewPath() {
    if (_localBackgroundPreviewPath != null &&
        _localBackgroundPreviewPath!.isNotEmpty) {
      return _localBackgroundPreviewPath;
    }
    return ProfileDisplay.imagePathFromRaw(_backgroundUrl);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authSessionProvider, (previous, next) {
      if (previous?.profile != next.profile) {
        _syncFieldsFromProfile();
        scheduleSetState(this);
      }
    });

    final profile = ref.watch(authSessionProvider).profile;
    final avatarPreviewPath = _avatarPreviewPath();
    final backgroundPreviewPath = _backgroundPreviewPath();
    final busy =
        _saving || _loading || _uploadingAvatar || _uploadingBackground;
    final immersive = !Breakpoints.isDesktop(context);
    final topInset = immersive ? MediaQuery.paddingOf(context).top : 0.0;

    final body = _loading && profile == null
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: EdgeInsets.zero,
            children: [
              _EditProfileHeader(
                topInset: topInset,
                backgroundPath: backgroundPreviewPath,
                avatarPath: avatarPreviewPath,
                uploadingBackground: _uploadingBackground,
                uploadingAvatar: _uploadingAvatar,
                onPickBackground: busy ? null : _pickAndUploadBackground,
                onPickAvatar: busy ? null : _pickAndUploadAvatar,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingMd,
                  AppDimensions.spacingMd,
                  AppDimensions.spacingMd,
                  0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      ProfileDisplay.displayName(profile),
                      style: AppTextStyles.title,
                      textAlign: TextAlign.center,
                    ),
                    if (ProfileDisplay.handle(profile) != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '@${ProfileDisplay.handle(profile)}',
                        style: AppTextStyles.bodySecondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: AppDimensions.spacingLg),
                    TextField(
                      controller: _nickname,
                      decoration: const InputDecoration(labelText: '昵称'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bio,
                      decoration: const InputDecoration(labelText: '简介'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: '邮箱'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phone,
                      decoration: const InputDecoration(labelText: '手机'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: '保存',
                      isLoading: _saving,
                      onPressed: busy ? null : _save,
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                  ],
                ),
              ),
              const ShellBottomSpacer(),
            ],
          );

    if (Breakpoints.isDesktop(context)) {
      return DesktopStackScaffold(
        title: const Text('编辑资料'),
        onBack: () => popOrGoDiscovery(context),
        body: body,
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.darkStyle,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            body,
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppDimensions.spacingXs,
                    top: AppDimensions.spacingXs,
                  ),
                  child: LiquidGlassSurface(
                    borderRadius: BorderRadius.circular(999),
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => popOrGoDiscovery(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileHeader extends StatelessWidget {
  const _EditProfileHeader({
    required this.topInset,
    this.backgroundPath,
    this.avatarPath,
    this.uploadingBackground = false,
    this.uploadingAvatar = false,
    this.onPickBackground,
    this.onPickAvatar,
  });

  static const _backgroundHeight = 160.0;
  static const _avatarOverlap = 48.0;

  final double topInset;
  final String? backgroundPath;
  final String? avatarPath;
  final bool uploadingBackground;
  final bool uploadingAvatar;
  final VoidCallback? onPickBackground;
  final VoidCallback? onPickAvatar;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: topInset + _backgroundHeight + _avatarOverlap,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topInset + _backgroundHeight,
                child: _EditableBackground(
                  path: backgroundPath,
                  height: topInset + _backgroundHeight,
                  uploading: uploadingBackground,
                  onTap: onPickBackground,
                ),
              ),
              Positioned(
                top: topInset + _backgroundHeight - _avatarOverlap,
                left: 0,
                right: 0,
                child: Center(
                  child: _EditableAvatar(
                    path: avatarPath,
                    uploading: uploadingAvatar,
                    onTap: onPickAvatar,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: [
              GlassButton(
                label: '更换背景',
                icon: Icons.wallpaper_outlined,
                loading: uploadingBackground,
                onPressed: onPickBackground,
              ),
              GlassButton(
                label: '更换头像',
                icon: Icons.photo_camera_outlined,
                loading: uploadingAvatar,
                onPressed: onPickAvatar,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
      ],
    );
  }
}

class _EditableBackground extends StatelessWidget {
  const _EditableBackground({
    required this.height,
    this.path,
    this.uploading = false,
    this.onTap,
  });

  final double height;
  final String? path;
  final bool uploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.characterBackgroundDark,
                  AppColors.profileGradientEnd.withValues(alpha: 0.92),
                ]
              : [
                  AppColors.profileGradientStart,
                  AppColors.profileGradientEnd,
                ],
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: height,
            child: path != null && path!.isNotEmpty
                ? Rc0Image(
                    path: path!,
                    width: double.infinity,
                    height: height,
                    fit: BoxFit.cover,
                    errorWidget: fallback,
                  )
                : fallback,
          ),
          if (uploading)
            Container(
              width: double.infinity,
              height: height,
              color: Colors.black45,
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Positioned(
            right: AppDimensions.spacingMd,
            bottom: AppDimensions.spacingMd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wallpaper_outlined, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    '更换背景',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar({
    this.path,
    this.uploading = false,
    this.onTap,
  });

  final String? path;
  final bool uploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const size = 96.0;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: SizedBox(
              width: size,
              height: size,
              child: _buildImage(size),
            ),
          ),
          if (uploading)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.photo_camera_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(double size) {
    if (path != null && path!.isNotEmpty) {
      return Rc0Image(
        path: path!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: const Icon(
          Icons.person,
          size: 40,
          color: AppColors.textSecondary,
        ),
      );
    }

    return const ColoredBox(
      color: AppColors.placeholder,
      child: Icon(Icons.person, size: 40, color: AppColors.textSecondary),
    );
  }
}
