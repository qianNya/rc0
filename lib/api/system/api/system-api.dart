import '../../http/api_client.dart';
import '../data/system-api.dart';

Future health({
  Function(HealthResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/health',
    ok: (data) => ok?.call(HealthResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}
