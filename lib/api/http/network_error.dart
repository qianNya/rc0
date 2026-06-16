String friendlyNetworkError(Object error) {
  final message = error.toString();
  if (message.contains('Failed host lookup') ||
      message.contains('Network is unreachable') ||
      message.contains('Connection refused')) {
    return '无法连接服务器，请检查网络或稍后重试';
  }
  if (message.contains('Cleartext HTTP traffic')) {
    return '应用未允许 HTTP 连接，请更新到最新版本';
  }
  return '网络请求失败，请稍后重试';
}
