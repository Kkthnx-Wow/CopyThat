<div align="center">

# CopyThat

**A lightweight, no-fuss way to copy your chat — one button, instant text, nothing else in the way.**

[![Last Commit](https://img.shields.io/github/last-commit/Kkthnx-Wow/CopyThat)](https://github.com/Kkthnx-Wow/CopyThat/commits/main)
[![Issues](https://img.shields.io/github/issues/Kkthnx-Wow/CopyThat)](https://github.com/Kkthnx-Wow/CopyThat/issues)
[![CurseForge](https://img.shields.io/badge/CurseForge-Download-orange)](https://www.curseforge.com/wow/addons/copythat)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/Kkthnx-Wow/CopyThat/blob/main/LICENSE)

</div>

---

## Overview

**CopyThat** adds a single, tidy button to your chat frame that pulls every visible line out of the active chat window and drops it into a clean, scrollable text box — ready to select and copy. No menus to dig through, no clutter, no overhead.

Instead of fighting Blizzard's chat frame to manually drag-select text, you click once and the whole window is right there as plain, copyable text — links flattened to their words, textures and icons stripped out, original colours preserved. Built on the same modular engine patterns as [NexEnhance](https://github.com/Kkthnx-Wow/NexEnhance), but focused on doing one job and doing it well.

- **One click** — grab the entire visible chat window instantly.
- **Clean output** — links become readable text, textures/animations are removed, message colours are kept.
- **Stays out of the way** — a small icon on the chat frame, positionable and fade-adjustable to taste.
- **Native settings** — a clean options panel built on Blizzard's own Settings API, with live-apply toggles.
- **Light by design** — a hidden frame and a reused line buffer; effectively zero cost when idle.
- **Plays everywhere** — works across Midnight, The War Within, Cataclysm Classic and Classic Era.

---

## Installation

**Via an addon manager (recommended)**
- [CurseForge](https://www.curseforge.com/wow/addons/copythat) — search for **CopyThat** and install.

**Manual**
1. Download the latest release from the [Releases](https://github.com/Kkthnx-Wow/CopyThat/releases) page.
2. Extract the `CopyThat` folder into `World of Warcraft\_retail_\Interface\AddOns`.
3. Restart the game (or `/reload` if already in-game).

---

## Getting Started

Hover the chat frame and you'll find the **Copy** icon in the corner you chose. Click it to open the copy window; click it again (or press `Escape`) to close. Inside, select the text and copy it with your usual shortcut.

| Command | Description |
| --- | --- |
| `/copythat` or `/ct` | Open the options panel |
| `/copythat help` | Show slash-command help |

---

## Features

CopyThat ships as a single self-contained module — everything lives under **Chat** in the options panel.

### Chat
- **Copy Button** — a small icon on the chat frame that captures every visible line of the active chat window into a scrollable, copyable text box. Follows the selected General-chat tab when you switch windows.
- **Clean Text Extraction** — strips textures (`|T...|t`) and animations (`|A...|a`), flattens hyperlinks to their display text, and preserves each message's original colour.
- **Icon Position** — place the button in any corner of the chat frame: **Bottom Right**, **Top Right**, **Top Left** or **Bottom Left**.
- **Icon Transparency** — set the resting opacity of the icon (it fades to full opacity on hover so it's never hard to find).
- **Enable / Disable** — turn the whole addon on or off live, with the button and copy window respecting the setting immediately.
- **Movable Window** — drag the copy window anywhere; its position is remembered between sessions.
- **Instance-Safe (Midnight)** — fully compatible with World of Warcraft: Midnight's [Secret Values](https://warcraft.wiki.gg/wiki/Secret_Values) model. Inside instances, chat content that the game marks Secret is skipped gracefully instead of erroring, and all other lines stay fully copyable.

---

## Configuration

Open the panel with **`/copythat`** (or **`/ct`**), or through the Blizzard AddOns settings. Every option applies **live**:

| Option | Description | Default |
| --- | --- | --- |
| **Enable Chat Copy** | Master on/off switch for CopyThat. | `On` |
| **Icon Transparency** | Resting opacity of the chat-frame Copy icon (0.0–1.0). | `0.5` |
| **Icon Position** | Which corner of the chat frame the icon sits in. | `Bottom Right` |

---

## Contributing

Contributions, bug reports and ideas are welcome! Open an [issue](https://github.com/Kkthnx-Wow/CopyThat/issues) or a pull request. When filing a bug, including your client version and a `/reload`-able repro helps a ton.

---

## Credits

CopyThat borrows with respect and adapts ideas from addon authors who solved this problem first:

- **Siweia** (NDui) — the original chat-copy module that NexEnhance's Chat Copy (and this addon) trace their roots to.
- **NexEnhance** — the modular engine, settings patterns and Midnight secret-value discipline this rewrite is built on.

Thank you both. CopyThat would not exist without you.

---

## Support

Appreciate the work that goes into CopyThat? Consider showing your support:

- **PayPal** — [paypal.me/KkthnxTV](https://www.paypal.com/paypalme/kkthnxtv)
- **Patreon** — [patreon.com/Kkthnx](https://www.patreon.com/Kkthnx)
- **Battle.net / Balance** — `Kkthnx#1105` or `JRussell20@gmail.com`
- **In-game gold** — Kkthnx on Area 52 (US)

---

## License

Released under the **MIT License**. See [LICENSE](https://github.com/Kkthnx-Wow/CopyThat/blob/main/LICENSE) for details.

<div align="center">

Developed and maintained by **Josh "Kkthnx" Russell**. Built with love for the default UI.

</div>
