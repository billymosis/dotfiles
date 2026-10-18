# Dotfiles (chezmoi)

Personal dotfiles managed by [chezmoi](https://www.chezmoi.io/), shared between
a **macOS** machine (user `hydrax`, Homebrew at `/opt/homebrew`) and an
**Ubuntu WSL2** machine (user `billy`). Every change must work on both.

## Layout

- Source dir: `~/.local/share/chezmoi`. Edit files here, not in `~`.
- Naming follows chezmoi conventions: `dot_` → `.`, `executable_` → `+x`,
  `private_` → `0600`. Example: `dot_config/nvim/init.lua` → `~/.config/nvim/init.lua`.
- Files/dirs starting with `.` (e.g. `.zshrc`, `.config/`, `.tmux.conf`,
  `.oh-my-zsh/`) are **ignored by chezmoi**. They are stale leftovers from a
  pre-chezmoi setup; the live versions are the `dot_*` ones.
- No templates (`*.tmpl`) are used yet, so every managed file is deployed
  identically on both OSes.

Main pieces:
- `dot_zshrc`, `dot_zshenv`, `dot_profile`, `dot_fzf.zsh`: zsh + oh-my-zsh (theme `billy`).
  Auto-launches a multiplexer controlled by `$MULTIPLEXER` (`herdr` | `tmux` | other = none).
- `dot_tmux.conf`, `dot_config/herdr/`: multiplexers.
- `dot_config/nvim/`: Neovim config using built-in `vim.pack` (lockfile
  `nvim-pack-lock.json`). Requires **Neovim ≥ 0.12** (uses `vim._core.ui2`,
  `vim.o.winborder`). Neovim is installed via `bob`.
- `dot_config/wezterm/`, `dot_config/alacritty/`: terminals.
- `dot_config/{bspwm,sxhkd,polybar,xfce4,private_autostart}`, `chromium-flags.conf`,
  `mimeapps.list`: Linux desktop (X11) only, unused on macOS and WSL.

## Commands

```sh
chezmoi diff                # preview what apply would change in ~
chezmoi apply               # write source -> ~
chezmoi add ~/.config/foo   # start tracking a file
chezmoi re-add              # pull edits made in ~ back into source
chezmoi update              # git pull + apply (how the other machine syncs)
nvim --headless +qa         # smoke-test nvim config loads without errors
zsh -i -c exit              # smoke-test zshrc
```

## Cross-platform rules

- Guard OS-specific code: `[[ "$(uname)" == "Darwin" ]]` / `[[ "$OSTYPE" == darwin* ]]`
  in zsh, `if-shell "uname | grep -q Darwin"` in tmux, `vim.fn.has("mac")` /
  `vim.fn.has("wsl")` in Lua.
- WSL detection: `$WSL_INTEROP` / `$WSL_DISTRO_NAME`.
- Never hardcode `/home/billy` or `/Users/hydrax`; use `$HOME` / `~`.
- Clipboard: macOS `pbcopy`; WSL `clip.exe` or `win32yank.exe`; Linux X11 `xclip`.
- Opening URLs: macOS `open`; Linux `xdg-open`; WSL `explorer.exe` / `wslview`.
- For files that only make sense on one OS, add them to `.chezmoiignore` with a
  template guard (`{{ if ne .chezmoi.os "linux" }}...{{ end }}`) rather than
  deleting them.

## Gotchas

- `nvim-pack-lock.json` is rewritten by nvim on each machine; expect diffs and
  commit only intentional plugin changes.
- `dot_config/atuin/private_config.toml` and anything `private_` may hold
  secrets/keys. Never print or commit secrets.
- This file (`CLAUDE.md`) is in `.chezmoiignore` so it is not deployed to `~`.
