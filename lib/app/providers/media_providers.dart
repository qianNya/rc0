import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rc0_media/rc0_media.dart';

import '../../core/media/app_media_upload_service.dart';

final mediaUploadServiceProvider = Provider<MediaUploadService>((ref) {
  return AppMediaUploadService.instance;
});
