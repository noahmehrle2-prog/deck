# deck

**See, tile, and click-to-enlarge your macOS Terminal windows.**

If you run a pile of `Terminal.app` windows — especially when you're juggling
a bunch of [Claude Code](https://claude.com/claude-code) / AI-agent sessions at
once — they stack into an unreadable mess. `deck` lays them out so you can see
and click every one, and (optionally) swaps whichever window you click into a
big working pane.

No dependencies beyond Python 3 (which ships with macOS). No menu-bar app, no
server, no config. One file, pure AppleScript under the hood.

```
 #  STATUS      IDLE    SESSION                                   RUNNING
────────────────────────────────────────────────────────────────────────
 1  ● working   0s      Build micro-cap stock screener           claude ☕
 2  ◌ waiting   59s     Audit football betting system            claude
 3  ◌ waiting   17m     Set up ESP32 voice assistant             claude
 4  · shell     2h 3m   ~/projects                               zsh

 4 windows  —  1 working · 2 waiting · 1 shell      (11:58:18 PM)
 Tile them: deck tile   ·   jump to one: deck go <#>
```

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/noahmehrle2-prog/deck/main/install.sh | bash
```

That drops the `deck` command on your `PATH`. (Prefer to read first? The whole
thing is one Python file — [`deck`](./deck) — and one installer —
[`install.sh`](./install.sh).)

**Manual install** — just copy the script anywhere on your `PATH`:

```bash
git clone https://github.com/noahmehrle2-prog/deck.git
sudo cp deck/deck /usr/local/bin/deck && sudo chmod +x /usr/local/bin/deck
```

### Requirements

- **macOS** with the built-in **Terminal.app** (iTerm2 is not supported yet).
- **Python 3** (preinstalled on macOS; `python3 --version` to check).
- The first time `deck` moves a window, macOS may ask Terminal for permission
  to control it under **System Settings → Privacy & Security → Automation**.
  Allow it once.

---

## Use it

### See everything

```bash
deck            # clean table of every Terminal window: status, idle, task
deck watch      # same, but live-refreshing
deck html       # a pretty dark dashboard in your browser
```

Status is read from the window's title glyph: a spinner (`⠋`) means a Claude
session is **working**, a sparkle (`✳`) means it's **waiting** for you. Plain
shells show as **shell**. Idle is time since that window last printed anything.

### Tile them

```bash
deck tile       # arrange all windows into a balanced, no-overlap grid
deck tile 4     # force 4 columns
deck stack      # diagonal cascade (every title bar peeks out, click to raise)
```

`deck` reads your real screen size and reserves the menu bar + Dock, so the grid
fills the usable area exactly. Windows are numbered left-to-right, top-to-bottom.

### Click-to-enlarge (the good part)

```bash
deck follow         # turn ON (runs in the background)
deck follow 75      # turn ON with a wider 75%-width main pane
deck follow status  # is it running?
deck follow stop    # turn OFF   (also: deck stop)
```

With `follow` on, your windows form a **master + stack** layout: one big pane on
the left, the rest as small thumbnails on the right. **Click any thumbnail and
it swaps into the big pane** so you can read and type in it — the previously-big
window drops into the slot you just clicked. Only those two windows move, so it's
instant and not disorienting.

```
  ┌───────────────────────────┐ ┌─────────┐ ┌─────────┐
  │                           │ │  win 2  │ │  win 3  │
  │                           │ └─────────┘ └─────────┘
  │   the window you clicked  │ ┌─────────┐ ┌─────────┐
  │   (big — you type here)   │ │  win 4  │ │  win 5  │
  │                           │ └─────────┘ └─────────┘
  │                           │ ┌─────────┐ ┌─────────┐
  └───────────────────────────┘ │  win 6  │ │  win 7  │
                                 └─────────┘ └─────────┘
```

It keeps running in the background (no tab to babysit) until you `deck follow
stop`. It does **not** survive a reboot — run `deck follow` again, or see
[auto-start](#auto-start-on-login).

### Jump to one

```bash
deck go 3       # bring window #3 to the front
deck main 3     # make window #3 the big master pane (one-shot, no daemon)
```

---

## Auto-start on login

Want `follow` always on? Create a LaunchAgent:

```bash
mkdir -p ~/Library/LaunchAgents
cat > ~/Library/LaunchAgents/com.deck.follow.plist <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.deck.follow</string>
  <key>ProgramArguments</key>
  <array><string>/usr/local/bin/deck</string><string>follow</string><string>--fg</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
</dict></plist>
PLIST
launchctl load ~/Library/LaunchAgents/com.deck.follow.plist
```

(Adjust the path if you installed `deck` somewhere other than `/usr/local/bin`.)
Remove it with `launchctl unload ~/Library/LaunchAgents/com.deck.follow.plist`.

---

## How it works

`deck` talks to Terminal.app through AppleScript (`osascript`). It reads each
window's id, tty, and title, then `set bounds of window id …` to position them.
Status comes from the title glyph; idle comes from the tty's last-modified time.
`follow` polls the front window id ~4×/second (very light) and only acts when
you bring a different window forward — which a normal mouse click does natively.

Raising a window uses `set index of window id X to 1` (the reliable way —
`set frontmost` does not actually reorder Terminal windows).

## Limitations

- **Terminal.app only.** iTerm2 / Warp / Ghostty use different scripting models.
- **Current Space only.** Windows on other Mission Control Spaces, or minimized,
  aren't moved (AppleScript can't see them).
- **Status labels** (working/waiting) are tuned to Claude Code's title glyphs;
  other tools just show as `shell`. **Tiling and follow work for any window.**
- With many windows the stack thumbnails get short — enough to read the title
  and click, not to work in. That's the point: the *big* pane is where you work.

## Uninstall

```bash
deck follow stop
sudo rm /usr/local/bin/deck
rm -f ~/.deck-follow.pid ~/.deck-follow.log ~/.deck-dashboard.html
```

## Contributing

Issues and PRs welcome — especially iTerm2 support and multi-display awareness.

## License

MIT © Noah Mehrle. See [LICENSE](./LICENSE).
