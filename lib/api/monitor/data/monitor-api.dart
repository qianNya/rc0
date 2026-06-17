// --C:\Users\qianlNya\GolandProjects\rc0-go\service\monitor\api\monitor--

class AuditMetricItem {
  final String serviceName;

  final String path;

  final num count;

  final num errorCount;

  final num avgDurationMs;

  final num p95DurationMs;
  AuditMetricItem({
    required this.serviceName,
    required this.path,
    required this.count,
    required this.errorCount,
    required this.avgDurationMs,
    required this.p95DurationMs,
  });
  factory AuditMetricItem.fromJson(Map<String, dynamic> m) {
    return AuditMetricItem(
      serviceName: m['service_name'] ?? "",
      path: m['path'] ?? "",
      count: m['count'] ?? 0,
      errorCount: m['error_count'] ?? 0,
      avgDurationMs: m['avg_duration_ms'] ?? 0.0,
      p95DurationMs: m['p95_duration_ms'] ?? 0.0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'service_name': serviceName,
      'path': path,
      'count': count,
      'error_count': errorCount,
      'avg_duration_ms': avgDurationMs,
      'p95_duration_ms': p95DurationMs,
    };
  }
}

class GatewayMetricSummary {
  final num requestTotal;

  final num errorTotal;

  final num avgDurationMs;
  GatewayMetricSummary({
    required this.requestTotal,
    required this.errorTotal,
    required this.avgDurationMs,
  });
  factory GatewayMetricSummary.fromJson(Map<String, dynamic> m) {
    return GatewayMetricSummary(
      requestTotal: m['request_total'] ?? 0,
      errorTotal: m['error_total'] ?? 0,
      avgDurationMs: m['avg_duration_ms'] ?? 0.0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'request_total': requestTotal,
      'error_total': errorTotal,
      'avg_duration_ms': avgDurationMs,
    };
  }
}

class GetMetricsReq {
  final String startAt;

  final String endAt;

  final String groupBy;
  GetMetricsReq({
    required this.startAt,
    required this.endAt,
    required this.groupBy,
  });
  factory GetMetricsReq.fromJson(Map<String, dynamic> m) {
    return GetMetricsReq(
      startAt: m['start_at'] ?? "",
      endAt: m['end_at'] ?? "",
      groupBy: m['group_by'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {'start_at': startAt, 'end_at': endAt, 'group_by': groupBy};
  }
}

class GetMetricsResp {
  final GatewayMetricSummary gateway;

  final List<AuditMetricItem> audit;
  GetMetricsResp({required this.gateway, required this.audit});
  factory GetMetricsResp.fromJson(Map<String, dynamic> m) {
    return GetMetricsResp(
      gateway: GatewayMetricSummary.fromJson(m['gateway']),
      audit: ((m['audit'] ?? []) as List<dynamic>)
          .map((i) => AuditMetricItem.fromJson(i))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {'gateway': gateway.toJson(), 'audit': audit.map((i) => i.toJson())};
  }
}

class GetTraceChainReq {
  final String traceId;
  GetTraceChainReq({required this.traceId});
  factory GetTraceChainReq.fromJson(Map<String, dynamic> m) {
    return GetTraceChainReq(traceId: m['trace_id'] ?? "");
  }
  Map<String, dynamic> toJson() {
    return {'trace_id': traceId};
  }
}

class HealthResp {
  final String status;

  final num services;

  final num infra;

  final String message;
  HealthResp({
    required this.status,
    required this.services,
    required this.infra,
    required this.message,
  });
  factory HealthResp.fromJson(Map<String, dynamic> m) {
    return HealthResp(
      status: m['status'] ?? "",
      services: m['services'] ?? 0,
      infra: m['infra'] ?? 0,
      message: m['message'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'services': services,
      'infra': infra,
      'message': message,
    };
  }
}

class InfraStatus {
  final String name;

  final String status;

  final num latencyMs;

  final String message;
  InfraStatus({
    required this.name,
    required this.status,
    required this.latencyMs,
    required this.message,
  });
  factory InfraStatus.fromJson(Map<String, dynamic> m) {
    return InfraStatus(
      name: m['name'] ?? "",
      status: m['status'] ?? "",
      latencyMs: m['latency_ms'] ?? 0,
      message: m['message'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'latency_ms': latencyMs,
      'message': message,
    };
  }
}

class ListInfraResp {
  final List<InfraStatus> list;
  ListInfraResp({required this.list});
  factory ListInfraResp.fromJson(Map<String, dynamic> m) {
    return ListInfraResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => InfraStatus.fromJson(i))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson())};
  }
}

class ListMonitorLogsReq {
  final num page;

  final num pageSize;

  final num userId;

  final String username;

  final String module;

  final String operation;

  final String traceId;

  final String serviceName;

  final num httpStatus;

  final String startAt;

  final String endAt;
  ListMonitorLogsReq({
    required this.page,
    required this.pageSize,
    required this.userId,
    required this.username,
    required this.module,
    required this.operation,
    required this.traceId,
    required this.serviceName,
    required this.httpStatus,
    required this.startAt,
    required this.endAt,
  });
  factory ListMonitorLogsReq.fromJson(Map<String, dynamic> m) {
    return ListMonitorLogsReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      userId: m['user_id'] ?? 0,
      username: m['username'] ?? "",
      module: m['module'] ?? "",
      operation: m['operation'] ?? "",
      traceId: m['trace_id'] ?? "",
      serviceName: m['service_name'] ?? "",
      httpStatus: m['http_status'] ?? 0,
      startAt: m['start_at'] ?? "",
      endAt: m['end_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'user_id': userId,
      'username': username,
      'module': module,
      'operation': operation,
      'trace_id': traceId,
      'service_name': serviceName,
      'http_status': httpStatus,
      'start_at': startAt,
      'end_at': endAt,
    };
  }
}

class ListMonitorLogsResp {
  final List<SysLog> list;

  final num total;
  ListMonitorLogsResp({required this.list, required this.total});
  factory ListMonitorLogsResp.fromJson(Map<String, dynamic> m) {
    return ListMonitorLogsResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => SysLog.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListServicesResp {
  final List<ServiceStatus> list;
  ListServicesResp({required this.list});
  factory ListServicesResp.fromJson(Map<String, dynamic> m) {
    return ListServicesResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => ServiceStatus.fromJson(i))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson())};
  }
}

class ServiceStatus {
  final String name;

  final String kind;

  final String key;

  final List<String> endpoints;

  final String status;

  final num latencyMs;

  final String message;
  ServiceStatus({
    required this.name,
    required this.kind,
    required this.key,
    required this.endpoints,
    required this.status,
    required this.latencyMs,
    required this.message,
  });
  factory ServiceStatus.fromJson(Map<String, dynamic> m) {
    return ServiceStatus(
      name: m['name'] ?? "",
      kind: m['kind'] ?? "",
      key: m['key'] ?? "",
      endpoints: m['endpoints']?.cast<String>() ?? [],
      status: m['status'] ?? "",
      latencyMs: m['latency_ms'] ?? 0,
      message: m['message'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'kind': kind,
      'key': key,
      'endpoints': endpoints,
      'status': status,
      'latency_ms': latencyMs,
      'message': message,
    };
  }
}

class SysLog {
  final num id;

  final num userId;

  final String username;

  final String module;

  final String operation;

  final String method;

  final String path;

  final String ip;

  final String userAgent;

  final String reqBody;

  final num respCode;

  final String respMsg;

  final String respBody;

  final String traceId;

  final String spanId;

  final String serviceName;

  final String env;

  final num httpStatus;

  final num durationMs;

  final String createAt;

  final String updateAt;
  SysLog({
    required this.id,
    required this.userId,
    required this.username,
    required this.module,
    required this.operation,
    required this.method,
    required this.path,
    required this.ip,
    required this.userAgent,
    required this.reqBody,
    required this.respCode,
    required this.respMsg,
    required this.respBody,
    required this.traceId,
    required this.spanId,
    required this.serviceName,
    required this.env,
    required this.httpStatus,
    required this.durationMs,
    required this.createAt,
    required this.updateAt,
  });
  factory SysLog.fromJson(Map<String, dynamic> m) {
    return SysLog(
      id: m['id'] ?? 0,
      userId: m['user_id'] ?? 0,
      username: m['username'] ?? "",
      module: m['module'] ?? "",
      operation: m['operation'] ?? "",
      method: m['method'] ?? "",
      path: m['path'] ?? "",
      ip: m['ip'] ?? "",
      userAgent: m['user_agent'] ?? "",
      reqBody: m['req_body'] ?? "",
      respCode: m['resp_code'] ?? 0,
      respMsg: m['resp_msg'] ?? "",
      respBody: m['resp_body'] ?? "",
      traceId: m['trace_id'] ?? "",
      spanId: m['span_id'] ?? "",
      serviceName: m['service_name'] ?? "",
      env: m['env'] ?? "",
      httpStatus: m['http_status'] ?? 0,
      durationMs: m['duration_ms'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'module': module,
      'operation': operation,
      'method': method,
      'path': path,
      'ip': ip,
      'user_agent': userAgent,
      'req_body': reqBody,
      'resp_code': respCode,
      'resp_msg': respMsg,
      'resp_body': respBody,
      'trace_id': traceId,
      'span_id': spanId,
      'service_name': serviceName,
      'env': env,
      'http_status': httpStatus,
      'duration_ms': durationMs,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class TraceChainMeta {
  final List<String> duplicateLayers;
  TraceChainMeta({required this.duplicateLayers});
  factory TraceChainMeta.fromJson(Map<String, dynamic> m) {
    return TraceChainMeta(
      duplicateLayers: m['duplicate_layers']?.cast<String>() ?? [],
    );
  }
  Map<String, dynamic> toJson() {
    return {'duplicate_layers': duplicateLayers};
  }
}

class TraceChainResp {
  final String traceId;

  final String jaegerUrl;

  final List<SysLog> spans;

  final TraceChainMeta meta;
  TraceChainResp({
    required this.traceId,
    required this.jaegerUrl,
    required this.spans,
    required this.meta,
  });
  factory TraceChainResp.fromJson(Map<String, dynamic> m) {
    return TraceChainResp(
      traceId: m['trace_id'] ?? "",
      jaegerUrl: m['jaeger_url'] ?? "",
      spans: ((m['spans'] ?? []) as List<dynamic>)
          .map((i) => SysLog.fromJson(i))
          .toList(),
      meta: TraceChainMeta.fromJson(m['meta']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'trace_id': traceId,
      'jaeger_url': jaegerUrl,
      'spans': spans.map((i) => i.toJson()),
      'meta': meta.toJson(),
    };
  }
}
