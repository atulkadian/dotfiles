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
├── macOS/
│   ├── Brewfile        # formulae + casks
│   └── terminal/       # Terminal.app profiles (.terminal)
└── skills/             # agent skills, linked into Claude Code and Cursor
```

Anything added under `home/` is picked up automatically on the next run — the
path relative to `home/` is the path relative to `$HOME`.

## Usage

```bash
./install.sh              # dotfiles + brew + skills + terminal
./install.sh --dotfiles   # one step at a time
./install.sh --brew
./install.sh --skills
./install.sh --terminal
./install.sh --dry-run    # print what would happen, change nothing
```

Re-running is safe. Symlinks already pointing at this repo are skipped;
anything else in the way is moved to `<file>.bak.<timestamp>` first.

## Skills

Each skill in `skills/` is symlinked individually into `~/.claude/skills` and
`~/.cursor/skills`. See [skills/README.md](skills/README.md) for the format.

Linking them one by one, rather than linking `skills/` as a whole directory,
keeps the agent's skills folder a real directory. Skills already on the
machine keep working, and any skill an agent creates later lands on local disk
instead of inside this repo — which matters because **this repo is public**
and it is cloned onto machines where new skills may be work-specific.

The trade-off: after a `git pull` brings in a new skill, run
`./install.sh --skills` again to link it. The step is idempotent, and it also
clears links to skills that have been removed from the repo.

## Terminal.app

`macOS/terminal/clear-dark.terminal` is the **Clear Dark** profile: SF Mono
Semibold 16pt, 120×30 window, dark translucent background (95% opacity, 50%
blur) and a full 16-colour ANSI palette.

Unlike the dotfiles, this can't be symlinked — Terminal.app keeps profiles in
a preferences domain, not a file. So it is imported instead:

```bash
./install.sh --terminal
```

Importing is done by handing the file to Terminal.app itself rather than
writing it with `defaults`. A running Terminal holds its preferences in memory
and rewrites the whole domain when it quits, which would silently discard
anything written underneath it.

For the same reason, setting the profile as the *default* may not stick while
Terminal is open. If a new window comes up with the old look, quit and reopen
Terminal, or set it under Terminal → Settings → Profiles. The profile itself
is imported either way.

After changing settings in the UI, pull them back into the repo and commit:

```bash
./install.sh --export-terminal
```

To capture a different profile, change `TERMINAL_PROFILE` at the top of
`install.sh`. Every `.terminal` file in `macOS/terminal/` is imported; that
variable only decides which one becomes the default.

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

