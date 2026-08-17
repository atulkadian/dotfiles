# dotfiles

macOS config and agent skills, kept in one repo and symlinked into place.

```bash
git clone https://github.com/atulkadian/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
./install.sh
```

The installer finds its own location, so the repo works from any path.

## Layout

```
├── install.sh
├── home/               mirrors $HOME; every file here is symlinked
│   ├── .gitconfig
│   ├── .zshrc
│   └── .oh-my-zsh/custom/themes/derpBox.zsh-theme
├── macOS/
│   ├── Brewfile        formulae and casks
│   └── terminal/       Terminal.app profiles
└── skills/             agent skills for Claude Code and Cursor
```

Drop a file anywhere under `home/` and the next run links it. Its path
relative to `home/` is its path relative to `$HOME`.

## Commands

| Flag | Does |
| ---- | ---- |
| *(none)* or `--all` | all four steps below |
| `--dotfiles` | install oh-my-zsh if missing, then link `home/` into `$HOME` |
| `--brew` | install Homebrew, then the Brewfile |
| `--skills` | link each skill into Claude Code and Cursor |
| `--terminal` | import the Terminal.app profile and make it the default |
| `--export-terminal` | copy live Terminal.app settings back into the repo |
| `--dry-run` | print what would happen, change nothing |

Re-running is safe. Links already pointing here are skipped, and anything else
in the way moves to `<file>.bak.<timestamp>` first.

Terminal profiles are imported rather than symlinked, because Terminal.app
keeps them in a preferences domain instead of a file. Updating a profile that
already exists means overwriting that domain, so **quit Terminal first** or
the step will tell you to and skip. A fresh import works either way.

## Skills

Skills are linked one at a time, so `~/.claude/skills` and `~/.cursor/skills`
stay real directories. Skills already on a machine keep working, and skills an
agent writes later land on local disk rather than in this repo. **This repo is
public**, so that boundary matters on a work machine.

Run `./install.sh --skills` after a pull brings in a new skill. Format is in
[skills/README.md](skills/README.md).

## Machine-specific config

Work identities, per-machine PATH entries and tokens stay out of git. Two
files, both gitignored and both optional:

| File | Loaded by |
| ---- | ---- |
| `~/.gitconfig.local` | included from `home/.gitconfig` |
| `~/.zshrc.local` | sourced at the end of `home/.zshrc` |

A work identity scoped to one directory:

```ini
[includeIf "gitdir:~/projects/abc/"]
	path = ~/projects/abc/.gitconfig
```
