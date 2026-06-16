// --C:\Users\qianlNya\GolandProjects\rc0-go\service\gallery\api\gallery--

class AcgnImage {
  final num id;

  final String title;

  final String description;

  final num imageType;

  final num contentRating;

  final num orientation;

  final num width;

  final num height;

  final num aspectRatio;

  final String dominantHex;

  final String sourceUrl;

  final String sourceSite;

  final String sourcePostId;

  final num license;

  final num visibility;

  final String publishAt;

  final num status;

  final String createAt;

  final String updateAt;
  AcgnImage({
    required this.id,
    required this.title,
    required this.description,
    required this.imageType,
    required this.contentRating,
    required this.orientation,
    required this.width,
    required this.height,
    required this.aspectRatio,
    required this.dominantHex,
    required this.sourceUrl,
    required this.sourceSite,
    required this.sourcePostId,
    required this.license,
    required this.visibility,
    required this.publishAt,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });
  factory AcgnImage.fromJson(Map<String, dynamic> m) {
    return AcgnImage(
      id: m['id'] ?? 0,
      title: m['title'] ?? "",
      description: m['description'] ?? "",
      imageType: m['image_type'] ?? 0,
      contentRating: m['content_rating'] ?? 0,
      orientation: m['orientation'] ?? 0,
      width: m['width'] ?? 0,
      height: m['height'] ?? 0,
      aspectRatio: m['aspect_ratio'] ?? 0.0,
      dominantHex: m['dominant_hex'] ?? "",
      sourceUrl: m['source_url'] ?? "",
      sourceSite: m['source_site'] ?? "",
      sourcePostId: m['source_post_id'] ?? "",
      license: m['license'] ?? 0,
      visibility: m['visibility'] ?? 0,
      publishAt: m['publish_at'] ?? "",
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_type': imageType,
      'content_rating': contentRating,
      'orientation': orientation,
      'width': width,
      'height': height,
      'aspect_ratio': aspectRatio,
      'dominant_hex': dominantHex,
      'source_url': sourceUrl,
      'source_site': sourceSite,
      'source_post_id': sourcePostId,
      'license': license,
      'visibility': visibility,
      'publish_at': publishAt,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class AcgnImageAnalysis {
  final num id;

  final num imageId;

  final String pipelineVer;

  final String analyzer;

  final num status;

  final String errorMsg;

  final String startedAt;

  final String finishedAt;

  final num durationMs;

  final String rawResult;

  final String createAt;

  final String updateAt;
  AcgnImageAnalysis({
    required this.id,
    required this.imageId,
    required this.pipelineVer,
    required this.analyzer,
    required this.status,
    required this.errorMsg,
    required this.startedAt,
    required this.finishedAt,
    required this.durationMs,
    required this.rawResult,
    required this.createAt,
    required this.updateAt,
  });
  factory AcgnImageAnalysis.fromJson(Map<String, dynamic> m) {
    return AcgnImageAnalysis(
      id: m['id'] ?? 0,
      imageId: m['image_id'] ?? 0,
      pipelineVer: m['pipeline_ver'] ?? "",
      analyzer: m['analyzer'] ?? "",
      status: m['status'] ?? 0,
      errorMsg: m['error_msg'] ?? "",
      startedAt: m['started_at'] ?? "",
      finishedAt: m['finished_at'] ?? "",
      durationMs: m['duration_ms'] ?? 0,
      rawResult: m['raw_result'] ?? "",
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_id': imageId,
      'pipeline_ver': pipelineVer,
      'analyzer': analyzer,
      'status': status,
      'error_msg': errorMsg,
      'started_at': startedAt,
      'finished_at': finishedAt,
      'duration_ms': durationMs,
      'raw_result': rawResult,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class AcgnImageFile {
  final num id;

  final num imageId;

  final num fileRole;

  final String storage;

  final String bucket;

  final String objectKey;

  final String url;

  final String mime;

  final num fileSize;

  final num width;

  final num height;

  final String checksum;

  final num status;

  final String createAt;

  final String updateAt;
  AcgnImageFile({
    required this.id,
    required this.imageId,
    required this.fileRole,
    required this.storage,
    required this.bucket,
    required this.objectKey,
    required this.url,
    required this.mime,
    required this.fileSize,
    required this.width,
    required this.height,
    required this.checksum,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });
  factory AcgnImageFile.fromJson(Map<String, dynamic> m) {
    return AcgnImageFile(
      id: m['id'] ?? 0,
      imageId: m['image_id'] ?? 0,
      fileRole: m['file_role'] ?? 0,
      storage: m['storage'] ?? "",
      bucket: m['bucket'] ?? "",
      objectKey: m['object_key'] ?? "",
      url: m['url'] ?? "",
      mime: m['mime'] ?? "",
      fileSize: m['file_size'] ?? 0,
      width: m['width'] ?? 0,
      height: m['height'] ?? 0,
      checksum: m['checksum'] ?? "",
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_id': imageId,
      'file_role': fileRole,
      'storage': storage,
      'bucket': bucket,
      'object_key': objectKey,
      'url': url,
      'mime': mime,
      'file_size': fileSize,
      'width': width,
      'height': height,
      'checksum': checksum,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class AcgnImageMetrics {
  final num imageId;

  final num analysisId;

  final num centroidX;

  final num centroidY;

  final num balanceScore;

  final num tensionScore;

  final num warmCoolIndex;

  final num schemaUpDown;

  final num schemaBalance;

  final String colorHist;

  final String compositionHints;

  final String autoTags;

  final String updateAt;
  AcgnImageMetrics({
    required this.imageId,
    required this.analysisId,
    required this.centroidX,
    required this.centroidY,
    required this.balanceScore,
    required this.tensionScore,
    required this.warmCoolIndex,
    required this.schemaUpDown,
    required this.schemaBalance,
    required this.colorHist,
    required this.compositionHints,
    required this.autoTags,
    required this.updateAt,
  });
  factory AcgnImageMetrics.fromJson(Map<String, dynamic> m) {
    return AcgnImageMetrics(
      imageId: m['image_id'] ?? 0,
      analysisId: m['analysis_id'] ?? 0,
      centroidX: m['centroid_x'] ?? 0.0,
      centroidY: m['centroid_y'] ?? 0.0,
      balanceScore: m['balance_score'] ?? 0.0,
      tensionScore: m['tension_score'] ?? 0.0,
      warmCoolIndex: m['warm_cool_index'] ?? 0.0,
      schemaUpDown: m['schema_up_down'] ?? 0.0,
      schemaBalance: m['schema_balance'] ?? 0.0,
      colorHist: m['color_hist'] ?? "",
      compositionHints: m['composition_hints'] ?? "",
      autoTags: m['auto_tags'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'image_id': imageId,
      'analysis_id': analysisId,
      'centroid_x': centroidX,
      'centroid_y': centroidY,
      'balance_score': balanceScore,
      'tension_score': tensionScore,
      'warm_cool_index': warmCoolIndex,
      'schema_up_down': schemaUpDown,
      'schema_balance': schemaBalance,
      'color_hist': colorHist,
      'composition_hints': compositionHints,
      'auto_tags': autoTags,
      'update_at': updateAt,
    };
  }
}

class AcgnImageTag {
  final num id;

  final num imageId;

  final num tagId;

  final num source;

  final num confidence;

  final num analysisId;

  final num status;

  final String createAt;

  final String updateAt;
  AcgnImageTag({
    required this.id,
    required this.imageId,
    required this.tagId,
    required this.source,
    required this.confidence,
    required this.analysisId,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });
  factory AcgnImageTag.fromJson(Map<String, dynamic> m) {
    return AcgnImageTag(
      id: m['id'] ?? 0,
      imageId: m['image_id'] ?? 0,
      tagId: m['tag_id'] ?? 0,
      source: m['source'] ?? 0,
      confidence: m['confidence'] ?? 0.0,
      analysisId: m['analysis_id'] ?? 0,
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_id': imageId,
      'tag_id': tagId,
      'source': source,
      'confidence': confidence,
      'analysis_id': analysisId,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class AcgnImageWork {
  final num id;

  final num imageId;

  final num workId;

  final num relationType;

  final num status;

  final String createAt;

  final String updateAt;
  AcgnImageWork({
    required this.id,
    required this.imageId,
    required this.workId,
    required this.relationType,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });
  factory AcgnImageWork.fromJson(Map<String, dynamic> m) {
    return AcgnImageWork(
      id: m['id'] ?? 0,
      imageId: m['image_id'] ?? 0,
      workId: m['work_id'] ?? 0,
      relationType: m['relation_type'] ?? 0,
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_id': imageId,
      'work_id': workId,
      'relation_type': relationType,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class AcgnTag {
  final num id;

  final String namespace;

  final String name;

  final String slug;

  final num parentId;

  final String description;

  final num status;

  final String createAt;

  final String updateAt;
  AcgnTag({
    required this.id,
    required this.namespace,
    required this.name,
    required this.slug,
    required this.parentId,
    required this.description,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });
  factory AcgnTag.fromJson(Map<String, dynamic> m) {
    return AcgnTag(
      id: m['id'] ?? 0,
      namespace: m['namespace'] ?? "",
      name: m['name'] ?? "",
      slug: m['slug'] ?? "",
      parentId: m['parent_id'] ?? 0,
      description: m['description'] ?? "",
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namespace': namespace,
      'name': name,
      'slug': slug,
      'parent_id': parentId,
      'description': description,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class AcgnWork {
  final num id;

  final String title;

  final String titleOrig;

  final num workType;

  final num releaseYear;

  final String coverUrl;

  final String summary;

  final String externalId;

  final String externalSrc;

  final num status;

  final String createAt;

  final String updateAt;
  AcgnWork({
    required this.id,
    required this.title,
    required this.titleOrig,
    required this.workType,
    required this.releaseYear,
    required this.coverUrl,
    required this.summary,
    required this.externalId,
    required this.externalSrc,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });
  factory AcgnWork.fromJson(Map<String, dynamic> m) {
    return AcgnWork(
      id: m['id'] ?? 0,
      title: m['title'] ?? "",
      titleOrig: m['title_orig'] ?? "",
      workType: m['work_type'] ?? 0,
      releaseYear: m['release_year'] ?? 0,
      coverUrl: m['cover_url'] ?? "",
      summary: m['summary'] ?? "",
      externalId: m['external_id'] ?? "",
      externalSrc: m['external_src'] ?? "",
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_orig': titleOrig,
      'work_type': workType,
      'release_year': releaseYear,
      'cover_url': coverUrl,
      'summary': summary,
      'external_id': externalId,
      'external_src': externalSrc,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class CreateAcgnImageAnalysisReq {
  final num imageId;

  final String pipelineVer;

  final String analyzer;

  final num status;

  final String errorMsg;

  final String startedAt;

  final String finishedAt;

  final num durationMs;

  final String rawResult;
  CreateAcgnImageAnalysisReq({
    required this.imageId,
    required this.pipelineVer,
    required this.analyzer,
    required this.status,
    required this.errorMsg,
    required this.startedAt,
    required this.finishedAt,
    required this.durationMs,
    required this.rawResult,
  });
  factory CreateAcgnImageAnalysisReq.fromJson(Map<String, dynamic> m) {
    return CreateAcgnImageAnalysisReq(
      imageId: m['image_id'] ?? 0,
      pipelineVer: m['pipeline_ver'] ?? "",
      analyzer: m['analyzer'] ?? "",
      status: m['status'] ?? 0,
      errorMsg: m['error_msg'] ?? "",
      startedAt: m['started_at'] ?? "",
      finishedAt: m['finished_at'] ?? "",
      durationMs: m['duration_ms'] ?? 0,
      rawResult: m['raw_result'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'image_id': imageId,
      'pipeline_ver': pipelineVer,
      'analyzer': analyzer,
      'status': status,
      'error_msg': errorMsg,
      'started_at': startedAt,
      'finished_at': finishedAt,
      'duration_ms': durationMs,
      'raw_result': rawResult,
    };
  }
}

class CreateAcgnImageFileReq {
  final num imageId;

  final num fileRole;

  final String storage;

  final String bucket;

  final String objectKey;

  final String url;

  final String mime;

  final num fileSize;

  final num width;

  final num height;

  final String checksum;

  final num status;
  CreateAcgnImageFileReq({
    required this.imageId,
    required this.fileRole,
    required this.storage,
    required this.bucket,
    required this.objectKey,
    required this.url,
    required this.mime,
    required this.fileSize,
    required this.width,
    required this.height,
    required this.checksum,
    required this.status,
  });
  factory CreateAcgnImageFileReq.fromJson(Map<String, dynamic> m) {
    return CreateAcgnImageFileReq(
      imageId: m['image_id'] ?? 0,
      fileRole: m['file_role'] ?? 0,
      storage: m['storage'] ?? "",
      bucket: m['bucket'] ?? "",
      objectKey: m['object_key'] ?? "",
      url: m['url'] ?? "",
      mime: m['mime'] ?? "",
      fileSize: m['file_size'] ?? 0,
      width: m['width'] ?? 0,
      height: m['height'] ?? 0,
      checksum: m['checksum'] ?? "",
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'image_id': imageId,
      'file_role': fileRole,
      'storage': storage,
      'bucket': bucket,
      'object_key': objectKey,
      'url': url,
      'mime': mime,
      'file_size': fileSize,
      'width': width,
      'height': height,
      'checksum': checksum,
      'status': status,
    };
  }
}

class CreateAcgnImageMetricsReq {
  final num imageId;

  final num analysisId;

  final num centroidX;

  final num centroidY;

  final num balanceScore;

  final num tensionScore;

  final num warmCoolIndex;

  final num schemaUpDown;

  final num schemaBalance;

  final String colorHist;

  final String compositionHints;

  final String autoTags;
  CreateAcgnImageMetricsReq({
    required this.imageId,
    required this.analysisId,
    required this.centroidX,
    required this.centroidY,
    required this.balanceScore,
    required this.tensionScore,
    required this.warmCoolIndex,
    required this.schemaUpDown,
    required this.schemaBalance,
    required this.colorHist,
    required this.compositionHints,
    required this.autoTags,
  });
  factory CreateAcgnImageMetricsReq.fromJson(Map<String, dynamic> m) {
    return CreateAcgnImageMetricsReq(
      imageId: m['image_id'] ?? 0,
      analysisId: m['analysis_id'] ?? 0,
      centroidX: m['centroid_x'] ?? 0.0,
      centroidY: m['centroid_y'] ?? 0.0,
      balanceScore: m['balance_score'] ?? 0.0,
      tensionScore: m['tension_score'] ?? 0.0,
      warmCoolIndex: m['warm_cool_index'] ?? 0.0,
      schemaUpDown: m['schema_up_down'] ?? 0.0,
      schemaBalance: m['schema_balance'] ?? 0.0,
      colorHist: m['color_hist'] ?? "",
      compositionHints: m['composition_hints'] ?? "",
      autoTags: m['auto_tags'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'image_id': imageId,
      'analysis_id': analysisId,
      'centroid_x': centroidX,
      'centroid_y': centroidY,
      'balance_score': balanceScore,
      'tension_score': tensionScore,
      'warm_cool_index': warmCoolIndex,
      'schema_up_down': schemaUpDown,
      'schema_balance': schemaBalance,
      'color_hist': colorHist,
      'composition_hints': compositionHints,
      'auto_tags': autoTags,
    };
  }
}

class CreateAcgnImageReq {
  final String title;

  final String description;

  final num imageType;

  final num contentRating;

  final num orientation;

  final num width;

  final num height;

  final num aspectRatio;

  final String dominantHex;

  final String sourceUrl;

  final String sourceSite;

  final String sourcePostId;

  final num license;

  final num visibility;

  final String publishAt;

  final num status;
  CreateAcgnImageReq({
    required this.title,
    required this.description,
    required this.imageType,
    required this.contentRating,
    required this.orientation,
    required this.width,
    required this.height,
    required this.aspectRatio,
    required this.dominantHex,
    required this.sourceUrl,
    required this.sourceSite,
    required this.sourcePostId,
    required this.license,
    required this.visibility,
    required this.publishAt,
    required this.status,
  });
  factory CreateAcgnImageReq.fromJson(Map<String, dynamic> m) {
    return CreateAcgnImageReq(
      title: m['title'] ?? "",
      description: m['description'] ?? "",
      imageType: m['image_type'] ?? 0,
      contentRating: m['content_rating'] ?? 0,
      orientation: m['orientation'] ?? 0,
      width: m['width'] ?? 0,
      height: m['height'] ?? 0,
      aspectRatio: m['aspect_ratio'] ?? 0.0,
      dominantHex: m['dominant_hex'] ?? "",
      sourceUrl: m['source_url'] ?? "",
      sourceSite: m['source_site'] ?? "",
      sourcePostId: m['source_post_id'] ?? "",
      license: m['license'] ?? 0,
      visibility: m['visibility'] ?? 0,
      publishAt: m['publish_at'] ?? "",
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image_type': imageType,
      'content_rating': contentRating,
      'orientation': orientation,
      'width': width,
      'height': height,
      'aspect_ratio': aspectRatio,
      'dominant_hex': dominantHex,
      'source_url': sourceUrl,
      'source_site': sourceSite,
      'source_post_id': sourcePostId,
      'license': license,
      'visibility': visibility,
      'publish_at': publishAt,
      'status': status,
    };
  }
}

class CreateAcgnImageTagReq {
  final num imageId;

  final num tagId;

  final num source;

  final num confidence;

  final num analysisId;

  final num status;
  CreateAcgnImageTagReq({
    required this.imageId,
    required this.tagId,
    required this.source,
    required this.confidence,
    required this.analysisId,
    required this.status,
  });
  factory CreateAcgnImageTagReq.fromJson(Map<String, dynamic> m) {
    return CreateAcgnImageTagReq(
      imageId: m['image_id'] ?? 0,
      tagId: m['tag_id'] ?? 0,
      source: m['source'] ?? 0,
      confidence: m['confidence'] ?? 0.0,
      analysisId: m['analysis_id'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'image_id': imageId,
      'tag_id': tagId,
      'source': source,
      'confidence': confidence,
      'analysis_id': analysisId,
      'status': status,
    };
  }
}

class CreateAcgnImageWorkReq {
  final num imageId;

  final num workId;

  final num relationType;

  final num status;
  CreateAcgnImageWorkReq({
    required this.imageId,
    required this.workId,
    required this.relationType,
    required this.status,
  });
  factory CreateAcgnImageWorkReq.fromJson(Map<String, dynamic> m) {
    return CreateAcgnImageWorkReq(
      imageId: m['image_id'] ?? 0,
      workId: m['work_id'] ?? 0,
      relationType: m['relation_type'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'image_id': imageId,
      'work_id': workId,
      'relation_type': relationType,
      'status': status,
    };
  }
}

class CreateAcgnTagReq {
  final String namespace;

  final String name;

  final String slug;

  final num parentId;

  final String description;

  final num status;
  CreateAcgnTagReq({
    required this.namespace,
    required this.name,
    required this.slug,
    required this.parentId,
    required this.description,
    required this.status,
  });
  factory CreateAcgnTagReq.fromJson(Map<String, dynamic> m) {
    return CreateAcgnTagReq(
      namespace: m['namespace'] ?? "",
      name: m['name'] ?? "",
      slug: m['slug'] ?? "",
      parentId: m['parent_id'] ?? 0,
      description: m['description'] ?? "",
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'namespace': namespace,
      'name': name,
      'slug': slug,
      'parent_id': parentId,
      'description': description,
      'status': status,
    };
  }
}

class CreateAcgnWorkReq {
  final String title;

  final String titleOrig;

  final num workType;

  final num releaseYear;

  final String coverUrl;

  final String summary;

  final String externalId;

  final String externalSrc;

  final num status;
  CreateAcgnWorkReq({
    required this.title,
    required this.titleOrig,
    required this.workType,
    required this.releaseYear,
    required this.coverUrl,
    required this.summary,
    required this.externalId,
    required this.externalSrc,
    required this.status,
  });
  factory CreateAcgnWorkReq.fromJson(Map<String, dynamic> m) {
    return CreateAcgnWorkReq(
      title: m['title'] ?? "",
      titleOrig: m['title_orig'] ?? "",
      workType: m['work_type'] ?? 0,
      releaseYear: m['release_year'] ?? 0,
      coverUrl: m['cover_url'] ?? "",
      summary: m['summary'] ?? "",
      externalId: m['external_id'] ?? "",
      externalSrc: m['external_src'] ?? "",
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'title_orig': titleOrig,
      'work_type': workType,
      'release_year': releaseYear,
      'cover_url': coverUrl,
      'summary': summary,
      'external_id': externalId,
      'external_src': externalSrc,
      'status': status,
    };
  }
}

class DeleteAcgnImageAnalysisReq {
  final num id;
  DeleteAcgnImageAnalysisReq({required this.id});
  factory DeleteAcgnImageAnalysisReq.fromJson(Map<String, dynamic> m) {
    return DeleteAcgnImageAnalysisReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class DeleteAcgnImageFileReq {
  final num id;
  DeleteAcgnImageFileReq({required this.id});
  factory DeleteAcgnImageFileReq.fromJson(Map<String, dynamic> m) {
    return DeleteAcgnImageFileReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class DeleteAcgnImageMetricsReq {
  final num imageId;
  DeleteAcgnImageMetricsReq({required this.imageId});
  factory DeleteAcgnImageMetricsReq.fromJson(Map<String, dynamic> m) {
    return DeleteAcgnImageMetricsReq(imageId: m['image_id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'image_id': imageId};
  }
}

class DeleteAcgnImageReq {
  final num id;
  DeleteAcgnImageReq({required this.id});
  factory DeleteAcgnImageReq.fromJson(Map<String, dynamic> m) {
    return DeleteAcgnImageReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class DeleteAcgnImageTagReq {
  final num id;
  DeleteAcgnImageTagReq({required this.id});
  factory DeleteAcgnImageTagReq.fromJson(Map<String, dynamic> m) {
    return DeleteAcgnImageTagReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class DeleteAcgnImageWorkReq {
  final num id;
  DeleteAcgnImageWorkReq({required this.id});
  factory DeleteAcgnImageWorkReq.fromJson(Map<String, dynamic> m) {
    return DeleteAcgnImageWorkReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class DeleteAcgnTagReq {
  final num id;
  DeleteAcgnTagReq({required this.id});
  factory DeleteAcgnTagReq.fromJson(Map<String, dynamic> m) {
    return DeleteAcgnTagReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class DeleteAcgnWorkReq {
  final num id;
  DeleteAcgnWorkReq({required this.id});
  factory DeleteAcgnWorkReq.fromJson(Map<String, dynamic> m) {
    return DeleteAcgnWorkReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetAcgnImageAnalysisReq {
  final num id;
  GetAcgnImageAnalysisReq({required this.id});
  factory GetAcgnImageAnalysisReq.fromJson(Map<String, dynamic> m) {
    return GetAcgnImageAnalysisReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetAcgnImageFileReq {
  final num id;
  GetAcgnImageFileReq({required this.id});
  factory GetAcgnImageFileReq.fromJson(Map<String, dynamic> m) {
    return GetAcgnImageFileReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetAcgnImageMetricsReq {
  final num imageId;
  GetAcgnImageMetricsReq({required this.imageId});
  factory GetAcgnImageMetricsReq.fromJson(Map<String, dynamic> m) {
    return GetAcgnImageMetricsReq(imageId: m['image_id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'image_id': imageId};
  }
}

class GetAcgnImageReq {
  final num id;
  GetAcgnImageReq({required this.id});
  factory GetAcgnImageReq.fromJson(Map<String, dynamic> m) {
    return GetAcgnImageReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetAcgnImageTagReq {
  final num id;
  GetAcgnImageTagReq({required this.id});
  factory GetAcgnImageTagReq.fromJson(Map<String, dynamic> m) {
    return GetAcgnImageTagReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetAcgnImageWorkReq {
  final num id;
  GetAcgnImageWorkReq({required this.id});
  factory GetAcgnImageWorkReq.fromJson(Map<String, dynamic> m) {
    return GetAcgnImageWorkReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetAcgnTagReq {
  final num id;
  GetAcgnTagReq({required this.id});
  factory GetAcgnTagReq.fromJson(Map<String, dynamic> m) {
    return GetAcgnTagReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetAcgnWorkReq {
  final num id;
  GetAcgnWorkReq({required this.id});
  factory GetAcgnWorkReq.fromJson(Map<String, dynamic> m) {
    return GetAcgnWorkReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class ListAcgnImageAnalysesReq {
  final num page;

  final num pageSize;

  final num imageId;

  final String analyzer;

  final num status;

  final num deleted;
  ListAcgnImageAnalysesReq({
    required this.page,
    required this.pageSize,
    required this.imageId,
    required this.analyzer,
    required this.status,
    required this.deleted,
  });
  factory ListAcgnImageAnalysesReq.fromJson(Map<String, dynamic> m) {
    return ListAcgnImageAnalysesReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      imageId: m['image_id'] ?? 0,
      analyzer: m['analyzer'] ?? "",
      status: m['status'] ?? 0,
      deleted: m['deleted'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'image_id': imageId,
      'analyzer': analyzer,
      'status': status,
      'deleted': deleted,
    };
  }
}

class ListAcgnImageAnalysesResp {
  final List<AcgnImageAnalysis> list;

  final num total;
  ListAcgnImageAnalysesResp({required this.list, required this.total});
  factory ListAcgnImageAnalysesResp.fromJson(Map<String, dynamic> m) {
    return ListAcgnImageAnalysesResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => AcgnImageAnalysis.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListAcgnImageFilesReq {
  final num page;

  final num pageSize;

  final num imageId;

  final num fileRole;

  final num status;

  final num deleted;
  ListAcgnImageFilesReq({
    required this.page,
    required this.pageSize,
    required this.imageId,
    required this.fileRole,
    required this.status,
    required this.deleted,
  });
  factory ListAcgnImageFilesReq.fromJson(Map<String, dynamic> m) {
    return ListAcgnImageFilesReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      imageId: m['image_id'] ?? 0,
      fileRole: m['file_role'] ?? 0,
      status: m['status'] ?? 0,
      deleted: m['deleted'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'image_id': imageId,
      'file_role': fileRole,
      'status': status,
      'deleted': deleted,
    };
  }
}

class ListAcgnImageFilesResp {
  final List<AcgnImageFile> list;

  final num total;
  ListAcgnImageFilesResp({required this.list, required this.total});
  factory ListAcgnImageFilesResp.fromJson(Map<String, dynamic> m) {
    return ListAcgnImageFilesResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => AcgnImageFile.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListAcgnImageMetricsReq {
  final num page;

  final num pageSize;

  final num imageId;
  ListAcgnImageMetricsReq({
    required this.page,
    required this.pageSize,
    required this.imageId,
  });
  factory ListAcgnImageMetricsReq.fromJson(Map<String, dynamic> m) {
    return ListAcgnImageMetricsReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      imageId: m['image_id'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'page': page, 'page_size': pageSize, 'image_id': imageId};
  }
}

class ListAcgnImageMetricsResp {
  final List<AcgnImageMetrics> list;

  final num total;
  ListAcgnImageMetricsResp({required this.list, required this.total});
  factory ListAcgnImageMetricsResp.fromJson(Map<String, dynamic> m) {
    return ListAcgnImageMetricsResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => AcgnImageMetrics.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListAcgnImageTagsReq {
  final num page;

  final num pageSize;

  final num imageId;

  final num tagId;

  final num source;

  final num status;

  final num deleted;
  ListAcgnImageTagsReq({
    required this.page,
    required this.pageSize,
    required this.imageId,
    required this.tagId,
    required this.source,
    required this.status,
    required this.deleted,
  });
  factory ListAcgnImageTagsReq.fromJson(Map<String, dynamic> m) {
    return ListAcgnImageTagsReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      imageId: m['image_id'] ?? 0,
      tagId: m['tag_id'] ?? 0,
      source: m['source'] ?? 0,
      status: m['status'] ?? 0,
      deleted: m['deleted'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'image_id': imageId,
      'tag_id': tagId,
      'source': source,
      'status': status,
      'deleted': deleted,
    };
  }
}

class ListAcgnImageTagsResp {
  final List<AcgnImageTag> list;

  final num total;
  ListAcgnImageTagsResp({required this.list, required this.total});
  factory ListAcgnImageTagsResp.fromJson(Map<String, dynamic> m) {
    return ListAcgnImageTagsResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => AcgnImageTag.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListAcgnImageWorksReq {
  final num page;

  final num pageSize;

  final num imageId;

  final num workId;

  final num relationType;

  final num status;

  final num deleted;
  ListAcgnImageWorksReq({
    required this.page,
    required this.pageSize,
    required this.imageId,
    required this.workId,
    required this.relationType,
    required this.status,
    required this.deleted,
  });
  factory ListAcgnImageWorksReq.fromJson(Map<String, dynamic> m) {
    return ListAcgnImageWorksReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      imageId: m['image_id'] ?? 0,
      workId: m['work_id'] ?? 0,
      relationType: m['relation_type'] ?? 0,
      status: m['status'] ?? 0,
      deleted: m['deleted'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'image_id': imageId,
      'work_id': workId,
      'relation_type': relationType,
      'status': status,
      'deleted': deleted,
    };
  }
}

class ListAcgnImageWorksResp {
  final List<AcgnImageWork> list;

  final num total;
  ListAcgnImageWorksResp({required this.list, required this.total});
  factory ListAcgnImageWorksResp.fromJson(Map<String, dynamic> m) {
    return ListAcgnImageWorksResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => AcgnImageWork.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListAcgnImagesReq {
  final num page;

  final num pageSize;

  final String title;

  final num imageType;

  final num contentRating;

  final num visibility;

  final String sourceSite;

  final num status;

  final num deleted;
  ListAcgnImagesReq({
    required this.page,
    required this.pageSize,
    required this.title,
    required this.imageType,
    required this.contentRating,
    required this.visibility,
    required this.sourceSite,
    required this.status,
    required this.deleted,
  });
  factory ListAcgnImagesReq.fromJson(Map<String, dynamic> m) {
    return ListAcgnImagesReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      title: m['title'] ?? "",
      imageType: m['image_type'] ?? 0,
      contentRating: m['content_rating'] ?? 0,
      visibility: m['visibility'] ?? 0,
      sourceSite: m['source_site'] ?? "",
      status: m['status'] ?? 0,
      deleted: m['deleted'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'title': title,
      'image_type': imageType,
      'content_rating': contentRating,
      'visibility': visibility,
      'source_site': sourceSite,
      'status': status,
      'deleted': deleted,
    };
  }
}

class ListAcgnImagesResp {
  final List<AcgnImage> list;

  final num total;
  ListAcgnImagesResp({required this.list, required this.total});
  factory ListAcgnImagesResp.fromJson(Map<String, dynamic> m) {
    return ListAcgnImagesResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => AcgnImage.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListAcgnTagsReq {
  final num page;

  final num pageSize;

  final String namespace;

  final String name;

  final String slug;

  final num parentId;

  final num status;

  final num deleted;
  ListAcgnTagsReq({
    required this.page,
    required this.pageSize,
    required this.namespace,
    required this.name,
    required this.slug,
    required this.parentId,
    required this.status,
    required this.deleted,
  });
  factory ListAcgnTagsReq.fromJson(Map<String, dynamic> m) {
    return ListAcgnTagsReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      namespace: m['namespace'] ?? "",
      name: m['name'] ?? "",
      slug: m['slug'] ?? "",
      parentId: m['parent_id'] ?? 0,
      status: m['status'] ?? 0,
      deleted: m['deleted'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'namespace': namespace,
      'name': name,
      'slug': slug,
      'parent_id': parentId,
      'status': status,
      'deleted': deleted,
    };
  }
}

class ListAcgnTagsResp {
  final List<AcgnTag> list;

  final num total;
  ListAcgnTagsResp({required this.list, required this.total});
  factory ListAcgnTagsResp.fromJson(Map<String, dynamic> m) {
    return ListAcgnTagsResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => AcgnTag.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListAcgnWorksReq {
  final num page;

  final num pageSize;

  final String title;

  final num workType;

  final String externalSrc;

  final num status;

  final num deleted;
  ListAcgnWorksReq({
    required this.page,
    required this.pageSize,
    required this.title,
    required this.workType,
    required this.externalSrc,
    required this.status,
    required this.deleted,
  });
  factory ListAcgnWorksReq.fromJson(Map<String, dynamic> m) {
    return ListAcgnWorksReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      title: m['title'] ?? "",
      workType: m['work_type'] ?? 0,
      externalSrc: m['external_src'] ?? "",
      status: m['status'] ?? 0,
      deleted: m['deleted'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'title': title,
      'work_type': workType,
      'external_src': externalSrc,
      'status': status,
      'deleted': deleted,
    };
  }
}

class ListAcgnWorksResp {
  final List<AcgnWork> list;

  final num total;
  ListAcgnWorksResp({required this.list, required this.total});
  factory ListAcgnWorksResp.fromJson(Map<String, dynamic> m) {
    return ListAcgnWorksResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => AcgnWork.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class PingResp {
  final String pong;
  PingResp({required this.pong});
  factory PingResp.fromJson(Map<String, dynamic> m) {
    return PingResp(pong: m['pong'] ?? "");
  }
  Map<String, dynamic> toJson() {
    return {'pong': pong};
  }
}

class UpdateAcgnImageAnalysisReq {
  final num id;

  final num imageId;

  final String pipelineVer;

  final String analyzer;

  final num status;

  final String errorMsg;

  final String startedAt;

  final String finishedAt;

  final num durationMs;

  final String rawResult;
  UpdateAcgnImageAnalysisReq({
    required this.id,
    required this.imageId,
    required this.pipelineVer,
    required this.analyzer,
    required this.status,
    required this.errorMsg,
    required this.startedAt,
    required this.finishedAt,
    required this.durationMs,
    required this.rawResult,
  });
  factory UpdateAcgnImageAnalysisReq.fromJson(Map<String, dynamic> m) {
    return UpdateAcgnImageAnalysisReq(
      id: m['id'] ?? 0,
      imageId: m['image_id'] ?? 0,
      pipelineVer: m['pipeline_ver'] ?? "",
      analyzer: m['analyzer'] ?? "",
      status: m['status'] ?? 0,
      errorMsg: m['error_msg'] ?? "",
      startedAt: m['started_at'] ?? "",
      finishedAt: m['finished_at'] ?? "",
      durationMs: m['duration_ms'] ?? 0,
      rawResult: m['raw_result'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_id': imageId,
      'pipeline_ver': pipelineVer,
      'analyzer': analyzer,
      'status': status,
      'error_msg': errorMsg,
      'started_at': startedAt,
      'finished_at': finishedAt,
      'duration_ms': durationMs,
      'raw_result': rawResult,
    };
  }
}

class UpdateAcgnImageFileReq {
  final num id;

  final num imageId;

  final num fileRole;

  final String storage;

  final String bucket;

  final String objectKey;

  final String url;

  final String mime;

  final num fileSize;

  final num width;

  final num height;

  final String checksum;

  final num status;
  UpdateAcgnImageFileReq({
    required this.id,
    required this.imageId,
    required this.fileRole,
    required this.storage,
    required this.bucket,
    required this.objectKey,
    required this.url,
    required this.mime,
    required this.fileSize,
    required this.width,
    required this.height,
    required this.checksum,
    required this.status,
  });
  factory UpdateAcgnImageFileReq.fromJson(Map<String, dynamic> m) {
    return UpdateAcgnImageFileReq(
      id: m['id'] ?? 0,
      imageId: m['image_id'] ?? 0,
      fileRole: m['file_role'] ?? 0,
      storage: m['storage'] ?? "",
      bucket: m['bucket'] ?? "",
      objectKey: m['object_key'] ?? "",
      url: m['url'] ?? "",
      mime: m['mime'] ?? "",
      fileSize: m['file_size'] ?? 0,
      width: m['width'] ?? 0,
      height: m['height'] ?? 0,
      checksum: m['checksum'] ?? "",
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_id': imageId,
      'file_role': fileRole,
      'storage': storage,
      'bucket': bucket,
      'object_key': objectKey,
      'url': url,
      'mime': mime,
      'file_size': fileSize,
      'width': width,
      'height': height,
      'checksum': checksum,
      'status': status,
    };
  }
}

class UpdateAcgnImageMetricsReq {
  final num imageId;

  final num analysisId;

  final num centroidX;

  final num centroidY;

  final num balanceScore;

  final num tensionScore;

  final num warmCoolIndex;

  final num schemaUpDown;

  final num schemaBalance;

  final String colorHist;

  final String compositionHints;

  final String autoTags;
  UpdateAcgnImageMetricsReq({
    required this.imageId,
    required this.analysisId,
    required this.centroidX,
    required this.centroidY,
    required this.balanceScore,
    required this.tensionScore,
    required this.warmCoolIndex,
    required this.schemaUpDown,
    required this.schemaBalance,
    required this.colorHist,
    required this.compositionHints,
    required this.autoTags,
  });
  factory UpdateAcgnImageMetricsReq.fromJson(Map<String, dynamic> m) {
    return UpdateAcgnImageMetricsReq(
      imageId: m['image_id'] ?? 0,
      analysisId: m['analysis_id'] ?? 0,
      centroidX: m['centroid_x'] ?? 0.0,
      centroidY: m['centroid_y'] ?? 0.0,
      balanceScore: m['balance_score'] ?? 0.0,
      tensionScore: m['tension_score'] ?? 0.0,
      warmCoolIndex: m['warm_cool_index'] ?? 0.0,
      schemaUpDown: m['schema_up_down'] ?? 0.0,
      schemaBalance: m['schema_balance'] ?? 0.0,
      colorHist: m['color_hist'] ?? "",
      compositionHints: m['composition_hints'] ?? "",
      autoTags: m['auto_tags'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'image_id': imageId,
      'analysis_id': analysisId,
      'centroid_x': centroidX,
      'centroid_y': centroidY,
      'balance_score': balanceScore,
      'tension_score': tensionScore,
      'warm_cool_index': warmCoolIndex,
      'schema_up_down': schemaUpDown,
      'schema_balance': schemaBalance,
      'color_hist': colorHist,
      'composition_hints': compositionHints,
      'auto_tags': autoTags,
    };
  }
}

class UpdateAcgnImageReq {
  final num id;

  final String title;

  final String description;

  final num imageType;

  final num contentRating;

  final num orientation;

  final num width;

  final num height;

  final num aspectRatio;

  final String dominantHex;

  final String sourceUrl;

  final String sourceSite;

  final String sourcePostId;

  final num license;

  final num visibility;

  final String publishAt;

  final num status;
  UpdateAcgnImageReq({
    required this.id,
    required this.title,
    required this.description,
    required this.imageType,
    required this.contentRating,
    required this.orientation,
    required this.width,
    required this.height,
    required this.aspectRatio,
    required this.dominantHex,
    required this.sourceUrl,
    required this.sourceSite,
    required this.sourcePostId,
    required this.license,
    required this.visibility,
    required this.publishAt,
    required this.status,
  });
  factory UpdateAcgnImageReq.fromJson(Map<String, dynamic> m) {
    return UpdateAcgnImageReq(
      id: m['id'] ?? 0,
      title: m['title'] ?? "",
      description: m['description'] ?? "",
      imageType: m['image_type'] ?? 0,
      contentRating: m['content_rating'] ?? 0,
      orientation: m['orientation'] ?? 0,
      width: m['width'] ?? 0,
      height: m['height'] ?? 0,
      aspectRatio: m['aspect_ratio'] ?? 0.0,
      dominantHex: m['dominant_hex'] ?? "",
      sourceUrl: m['source_url'] ?? "",
      sourceSite: m['source_site'] ?? "",
      sourcePostId: m['source_post_id'] ?? "",
      license: m['license'] ?? 0,
      visibility: m['visibility'] ?? 0,
      publishAt: m['publish_at'] ?? "",
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_type': imageType,
      'content_rating': contentRating,
      'orientation': orientation,
      'width': width,
      'height': height,
      'aspect_ratio': aspectRatio,
      'dominant_hex': dominantHex,
      'source_url': sourceUrl,
      'source_site': sourceSite,
      'source_post_id': sourcePostId,
      'license': license,
      'visibility': visibility,
      'publish_at': publishAt,
      'status': status,
    };
  }
}

class UpdateAcgnImageTagReq {
  final num id;

  final num imageId;

  final num tagId;

  final num source;

  final num confidence;

  final num analysisId;

  final num status;
  UpdateAcgnImageTagReq({
    required this.id,
    required this.imageId,
    required this.tagId,
    required this.source,
    required this.confidence,
    required this.analysisId,
    required this.status,
  });
  factory UpdateAcgnImageTagReq.fromJson(Map<String, dynamic> m) {
    return UpdateAcgnImageTagReq(
      id: m['id'] ?? 0,
      imageId: m['image_id'] ?? 0,
      tagId: m['tag_id'] ?? 0,
      source: m['source'] ?? 0,
      confidence: m['confidence'] ?? 0.0,
      analysisId: m['analysis_id'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_id': imageId,
      'tag_id': tagId,
      'source': source,
      'confidence': confidence,
      'analysis_id': analysisId,
      'status': status,
    };
  }
}

class UpdateAcgnImageWorkReq {
  final num id;

  final num imageId;

  final num workId;

  final num relationType;

  final num status;
  UpdateAcgnImageWorkReq({
    required this.id,
    required this.imageId,
    required this.workId,
    required this.relationType,
    required this.status,
  });
  factory UpdateAcgnImageWorkReq.fromJson(Map<String, dynamic> m) {
    return UpdateAcgnImageWorkReq(
      id: m['id'] ?? 0,
      imageId: m['image_id'] ?? 0,
      workId: m['work_id'] ?? 0,
      relationType: m['relation_type'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_id': imageId,
      'work_id': workId,
      'relation_type': relationType,
      'status': status,
    };
  }
}

class UpdateAcgnTagReq {
  final num id;

  final String namespace;

  final String name;

  final String slug;

  final num parentId;

  final String description;

  final num status;
  UpdateAcgnTagReq({
    required this.id,
    required this.namespace,
    required this.name,
    required this.slug,
    required this.parentId,
    required this.description,
    required this.status,
  });
  factory UpdateAcgnTagReq.fromJson(Map<String, dynamic> m) {
    return UpdateAcgnTagReq(
      id: m['id'] ?? 0,
      namespace: m['namespace'] ?? "",
      name: m['name'] ?? "",
      slug: m['slug'] ?? "",
      parentId: m['parent_id'] ?? 0,
      description: m['description'] ?? "",
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namespace': namespace,
      'name': name,
      'slug': slug,
      'parent_id': parentId,
      'description': description,
      'status': status,
    };
  }
}

class UpdateAcgnWorkReq {
  final num id;

  final String title;

  final String titleOrig;

  final num workType;

  final num releaseYear;

  final String coverUrl;

  final String summary;

  final String externalId;

  final String externalSrc;

  final num status;
  UpdateAcgnWorkReq({
    required this.id,
    required this.title,
    required this.titleOrig,
    required this.workType,
    required this.releaseYear,
    required this.coverUrl,
    required this.summary,
    required this.externalId,
    required this.externalSrc,
    required this.status,
  });
  factory UpdateAcgnWorkReq.fromJson(Map<String, dynamic> m) {
    return UpdateAcgnWorkReq(
      id: m['id'] ?? 0,
      title: m['title'] ?? "",
      titleOrig: m['title_orig'] ?? "",
      workType: m['work_type'] ?? 0,
      releaseYear: m['release_year'] ?? 0,
      coverUrl: m['cover_url'] ?? "",
      summary: m['summary'] ?? "",
      externalId: m['external_id'] ?? "",
      externalSrc: m['external_src'] ?? "",
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_orig': titleOrig,
      'work_type': workType,
      'release_year': releaseYear,
      'cover_url': coverUrl,
      'summary': summary,
      'external_id': externalId,
      'external_src': externalSrc,
      'status': status,
    };
  }
}
