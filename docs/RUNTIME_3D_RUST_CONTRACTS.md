# RC0 3D Runtime — Rust Service Contracts

Flutter orchestrates; Unity does not call Rust directly.

Base URL: configured in `lib/core/config/api_config.dart` (rc0-rust `:8080`).

## POST /v1/assets/optimize

Compress glTF and convert textures for Unity streaming.

```json
{
  "source_url": "https://...",
  "target_format": "gltf",
  "texture_format": "ktx2"
}
```

Response: `{ "job_id": "...", "status": "queued" }`

## POST /v1/export/usd

Offline USD export from scene snapshot submitted by Flutter.

```json
{
  "session_id": "...",
  "scene_snapshot": { },
  "lighting_rig": { }
}
```

## POST /v1/export/video

Sequence render + encode (cloud queue).

```json
{
  "session_id": "...",
  "fps": 24,
  "duration_sec": 5,
  "resolution": "1920x1080"
}
```

## POST /v1/ai/lighting/suggest

Natural-language lighting (future AI Interaction Module).

```json
{
  "prompt": "三点布光，暖色主光",
  "character_id": 1,
  "scene_id": null
}
```

Response: `lighting_rig` JSON compatible with `LightingSchemeMapper.rigFromJson`.

## Dart client (to implement in lib/api/runtime/)

- `RuntimeExportApi`
- `RuntimeAssetApi`
- `RuntimeAiLightingApi`
