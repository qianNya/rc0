import 'package:flutter/material.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../data/media_vault_repository.dart';
import '../../domain/media_vault_image.dart';
import '../media_vault/media_vault_colors.dart';
import '../media_vault/media_vault_detail_panel.dart';

/// Full-screen image detail for compact layouts.
class MediaVaultImageDetailPage extends StatefulWidget {
  const MediaVaultImageDetailPage({super.key, required this.imageId});

  final String imageId;

  @override
  State<MediaVaultImageDetailPage> createState() =>
      _MediaVaultImageDetailPageState();
}

class _MediaVaultImageDetailPageState extends State<MediaVaultImageDetailPage> {
  final _repo = MediaVaultRepository.instance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _repo.load();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final image = _repo.imageById(widget.imageId);

    return Scaffold(
      backgroundColor: MediaVaultColors.background,
      body: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: MediaVaultColors.accent,
                ),
              )
            : image == null
                ? const Center(
                    child: Text(
                      '图片未找到',
                      style: TextStyle(color: MediaVaultColors.textSecondary),
                    ),
                  )
                : MediaVaultDetailPanel(
                    image: image,
                    width: double.infinity,
                    related: _related(image),
                    onClose: () => popOrGoHome(context),
                    onFavorite: () => _repo.toggleFavorite(image.id),
                    onRelatedTap: (img) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              MediaVaultImageDetailPage(imageId: img.id),
                        ),
                      );
                    },
                  ),
    );
  }

  List<MediaVaultImage> _related(MediaVaultImage image) {
    return _repo.images
        .where((e) => e.id != image.id && e.category == image.category)
        .take(6)
        .toList(growable: false);
  }
}
