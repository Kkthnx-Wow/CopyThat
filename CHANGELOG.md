# Changelog

All notable changes to **CopyThat** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-06-09

### Added
- Compatibility with **World of Warcraft: Midnight (12.0)** and its new
  [Secret Values](https://warcraft.wiki.gg/wiki/Secret_Values) security model.
- Cached, version-safe `issecretvalue` local with a no-op fallback so the addon
  continues to load and run unchanged on pre-Midnight clients (TWW, Cata
  Classic, Classic Era).

### Fixed
- Prevented `attempt to perform arithmetic/compare on a secret value` errors when
  copying chat while inside an instance (dungeon, raid, or Mythic+). Chat
  messages can be returned as Secret strings in instances, which broke the
  `string.gsub`, comparison, and `table.concat` operations used to build the
  copyable text buffer.
- Chat lines whose message text is a Secret Value are now safely skipped instead
  of crashing the copy routine; all non-secret content remains fully copyable.
- Hardened the message color path: if a line's `r`/`g`/`b` color components are
  Secret, the line now falls back to white rather than performing arithmetic on a
  Secret value in `HexRGB`.

### Changed
- Bumped TOC `Interface` for Midnight from `120000` to `120005` (Patch 12.0.5).
- Reviewed the addon against the WoW addon optimization guide: event-driven
  design, file-scope local caching of globals, and isolated (non-Secret-carrying)
  frame anchors were all confirmed compliant — no changes required.

## [1.0.4]

- Previous release. Earlier history was not tracked in this file.
