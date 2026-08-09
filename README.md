# dotfiles

macOS config and a portable store of agent skills.

```bash
git clone https://github.com/atulkadian/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
./install.sh
```

The installer works from wherever the repo is cloned — nothing is hardcoded to
a particular path.

## Layout

```
├── install.sh          # entrypoint
├── home/               # mirrors $HOME; every file here gets symlinked
│   ├── .gitconfig
│   ├── .zshrc
│   └── .oh-my-zsh/custom/themes/derpBox.zsh-theme
├── macOS/Brewfile      # formulae + casks
└── skills/             # agent skills, linked into Claude Code and Cursor
```

Anything added under `home/` is picked up automatically on the next run — the
path relative to `home/` is the path relative to `$HOME`.

## Usage

```bash
./install.sh              # dotfiles + brew + skills
./install.sh --dotfiles   # one step at a time
./install.sh --brew
./install.sh --skills
./install.sh --dry-run    # print what would happen, change nothing
```

Re-running is safe. Symlinks already pointing at this repo are skipped;
anything else in the way is moved to `<file>.bak.<timestamp>` first.

## Skills

`skills/` is symlinked to both `~/.claude/skills` and `~/.cursor/skills`, so
a `git pull` here updates every agent on the machine at once. See
[skills/README.md](skills/README.md) for the format.

## Machine-specific config

Some settings shouldn't be committed — work git identities, per-machine PATH
entries, tokens. Two escape hatches, both gitignored:


| File                 | Purpose                                                       |
| -------------------- | ------------------------------------------------------------- |
| `~/.gitconfig.local` | Included by `.gitconfig`; work identity, conditional includes |
| `~/.zshrc.local`     | Sourced at the end of `.zshrc`                                |


Create them by hand on each machine. Neither needs to exist — both are
skipped silently if missing.

For example, a work identity scoped to one directory goes in
`~/.gitconfig.local`:

```ini
[includeIf "gitdir:~/projects/abc/"]
	path = ~/projects/abc/.gitconfig
```

