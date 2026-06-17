# Changelog

All notable changes to **CopyThat** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-06-16

### Added
- Complete ground-up rewrite on a lightweight **NexEnhance / CharInspectPlus-style**
  engine: shared namespace, module registry, central event dispatcher, and
  profile-based saved variables.
- **`Modules/ChatCopy.lua`** — self-contained chat copy module with live setting
  callbacks (`OnSettingChanged`) so options apply without `/reload`.
- **Multi-flavor support** — single package loads on Midnight retail, The War
  Within, Cataclysm Classic, and Classic Era (TOC `Interface` lines for each
  client).
- **Blizzard Settings panel** with a **CharInspectPlus-style layout**:
  - Landing page (logo, version, tagline, slash-command quick reference, live
    module stats).
  - **General** subcategory for all configuration.
- `Core/Widgets.lua` + `Core/Widgets.xml` for wrapped description text on the
  General page.
- Mandatory localization via `Core/Locales/enUS.lua` (no raw UI literals).
- Automatic **saved-variable migration** from the legacy flat Dashi-era
  `CopyThatDB` layout (`isEnabled`, `iconAlpha`, `iconPosition`) into the new
  `chatCopy` module table.
- Cursor rules for addon conventions and Midnight / 12.0.7 API guidance.

### Changed
- Removed the **[Dashi](https://github.com/p3lim-wow/Dashi)** dependency entirely;
  events, database, and settings now use native Blizzard APIs and an in-house
  core.
- Settings UI no longer uses Dashi widgets — options are registered through
  `Settings.RegisterVerticalLayoutCategory` and subcategories.
- `/copythat` and `/ct` now open the **General** settings page directly.
- Copy button is parented to **`UIParent`** again (anchored to the active chat
  frame), matching the original 1.x behaviour and keeping the icon visible across
  chat tab changes.
- Restored the custom **`Media/CopyButton.tga`** icon (replacing the temporary
  stock guild-note texture used during the rewrite).
- Bumped TOC `Interface` to **`120007`** (Patch 12.0.7 / Midnight: Revelations)
  alongside supported classic interface versions.
- Version bumped to **2.0.0** to reflect the architectural break from 1.x.

### Fixed
- Copy button **not appearing on first load** until toggling enable or icon
  position — caused by `OnEnable` running during `ADDON_LOADED` on `/reload`
  before chat frames were ready; module enable is now deferred one tick via
  `C_Timer.After(0)` on `PLAYER_LOGIN`.
- **`C_Timer.After` callback error** (`bad argument #2`) — `Enable` was
  referenced before its `local` declaration; function order corrected.
- **`OnEnable` treating `enable = nil` as disabled** after migration — now uses
  `IsEnabled()` consistently (nil defaults to on).
- **`Install()` retry loop** — button creation waits until the active chat frame
  exists, then explicitly shows the button.
- Retail vs classic scroll area: **`MinimalScrollBar` + `ScrollUtil`** on retail,
  **`UIPanelScrollFrameTemplate`** fallback on classic clients.

### Removed
- `Libs/Dashi/` embed and all Dashi-driven config (`Config/Settings.lua`,
  `Config/About.lua`, monolithic `CopyThat.lua`).
- Separate **About** settings sub-page — overview content moved to the landing
  page.

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
