# Wonderland YTMusic

A standalone, auditable YouTube Music acquisition subsystem for macOS.

## Install

From the archive's extracted directory:

```bash
./install.sh
```

The installer targets `/Users/Wonderland/wonderland/systems/ytmusic` by default.
Override with `WL_ROOT=/some/root ./install.sh`.

The installer refuses to overwrite an existing target. Review and back up before replacing anything.

## Commands

```bash
ytmusic status
ytmusic acquire 'https://music.youtube.com/watch?v=...'
ytmusic playlist 'https://music.youtube.com/playlist?list=...'
ytmusic album 'https://music.youtube.com/playlist?list=...'
ytmusic verify
ytmusic audit
ytmusic recover
```

`acquire`, `playlist`, and `album` use yt-dlp. Playlist and album commands permit collection URLs; album URLs are YouTube Music playlist URLs.

## Layout

- `incoming/`: completed, promoted media files
- `staging/`: active acquisition work directories
- `manifests/`: per-job JSON manifests
- `evidence/`: append-only JSONL event journal and audit output
- `quarantine/`: retained invalid/incomplete outputs
- `config/config.toml`: non-secret configuration
- `bin/ytmusic`: CLI entry point
- `lib/ytmusic.py`: implementation

## Safety model

- Downloads are staged before promotion.
- Existing destination files are never overwritten.
- Promotion uses an exclusive destination creation operation.
- A SHA-256 digest and ffprobe metadata are recorded.
- The event journal records acquisition lifecycle events.
- No DRM circumvention or access-control bypass is implemented.
- Authentication is opt-in through yt-dlp's supported browser-cookie option.
- Browser cookies and credentials are never written to manifests or logs.
- `recover` reports interrupted jobs; it does not delete or automatically resume them.

This tool is for content you are authorized to download. Platform terms and rights-holder restrictions still apply.

## Configuration

Edit `config/config.toml`. Default browser cookie source is disabled.
To enable Firefox cookies, set:

```toml
cookies_from_browser = "firefox"
```

Use only if you are authorized to access the account and content. Avoid exporting cookie files.
