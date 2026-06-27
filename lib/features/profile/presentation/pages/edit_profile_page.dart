import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/rc0_app_bar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _auth = AuthRepository.instance;
  late final TextEditingController _nickname;
  late final TextEditingController _bio;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _avatar;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = _auth.profile;
    _nickname = TextEditingController(text: p?.nickname ?? '');
    _bio = TextEditingController(text: p?.bio ?? '');
    _email = TextEditingController(text: p?.email ?? '');
    _phone = TextEditingController(text: p?.phone ?? '');
    _avatar = TextEditingController(text: p?.avatar ?? '');
  }

  @override
  void dispose() {
    _nickname.dispose();
    _bio.dispose();
    _email.dispose();
    _phone.dispose();
    _avatar.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final err = await _auth.updateProfileFields(
      nickname: _nickname.text.trim(),
      bio: _bio.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      avatar: _avatar.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (err != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('资料已更新')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopStackScaffold(
      title: const Text('编辑资料'),
      onBack: () => popOrGoDiscovery(context),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nickname,
            decoration: const InputDecoration(labelText: '昵称'),
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
          const SizedBox(height: 12),
          TextField(
            controller: _avatar,
            decoration: const InputDecoration(labelText: '头像 URL'),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: '保存',
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
