import 'package:flutter/material.dart';

import '../../data/lighting_repository.dart';
import '../../domain/lighting_scheme.dart';

class LightingPickerSheet extends StatefulWidget {
  const LightingPickerSheet({super.key});

  static Future<LightingScheme?> show(BuildContext context) {
    return showModalBottomSheet<LightingScheme>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const LightingPickerSheet(),
    );
  }

  @override
  State<LightingPickerSheet> createState() => _LightingPickerSheetState();
}

class _LightingPickerSheetState extends State<LightingPickerSheet> {
  final _repo = LightingRepository.instance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _repo.addListener(_onRepo);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepo);
    super.dispose();
  }

  void _onRepo() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    await _repo.load();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;
    final schemes = [..._repo.builtInSchemes, ..._repo.userSchemes];

    return SizedBox(
      height: maxHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('选择灯光方案', style: TextStyle(fontSize: 17)),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: schemes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final scheme = schemes[index];
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tileColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    title: Text(scheme.title),
                    subtitle: Text(
                      '${scheme.lights.length} 盏灯 · ${scheme.displaySummary}',
                    ),
                    onTap: () => Navigator.pop(context, scheme),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
