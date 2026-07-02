mergeInto(global, {
  WebBridge_SendToFlutter: function (ptr) {
    var json = UTF8ToString(ptr);
    if (window.rc0UnityBridge && window.rc0UnityBridge.onUnityEvent) {
      window.rc0UnityBridge.onUnityEvent(json);
    }
  },
  NativeBridge_SendToFlutter: function (ptr) {
    var json = UTF8ToString(ptr);
    if (window.rc0UnityBridge && window.rc0UnityBridge.onUnityEvent) {
      window.rc0UnityBridge.onUnityEvent(json);
    }
  },
});
