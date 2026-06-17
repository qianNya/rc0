import 'api.dart';
import '../data/monitor-api.dart';

/// monitor-api

/// --/api/monitor/health--
///
/// request:
/// response: HealthResp
Future getHealth({
  Function(HealthResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/monitor/health",
    ok: (data) {
      if (ok != null) ok(HealthResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/monitor/infra--
///
/// request:
/// response: ListInfraResp
Future listInfra({
  Function(ListInfraResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/monitor/infra",
    ok: (data) {
      if (ok != null) ok(ListInfraResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/monitor/logs--
///
/// request: ListMonitorLogsReq
/// response: ListMonitorLogsResp
Future listLogs({
  Function(ListMonitorLogsResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/monitor/logs",
    ok: (data) {
      if (ok != null) ok(ListMonitorLogsResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/monitor/metrics--
///
/// request: GetMetricsReq
/// response: GetMetricsResp
Future getMetrics({
  Function(GetMetricsResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/monitor/metrics",
    ok: (data) {
      if (ok != null) ok(GetMetricsResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/monitor/services--
///
/// request:
/// response: ListServicesResp
Future listServices({
  Function(ListServicesResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/monitor/services",
    ok: (data) {
      if (ok != null) ok(ListServicesResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/monitor/traces/:trace_id--
///
/// request: GetTraceChainReq
/// response: TraceChainResp
Future getTraceChain(
  String trace_id, {
  Function(TraceChainResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/monitor/traces/${trace_id}",
    ok: (data) {
      if (ok != null) ok(TraceChainResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}
