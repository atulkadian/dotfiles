# Skills

Portable agent skills. `install.sh --skills` symlinks each skill below into:

| Agent       | Path               |
| ----------- | ------------------ |
| Claude Code | `~/.claude/skills` |
| Cursor      | `~/.cursor/skills` |

Skills are linked one at a time, so those directories stay real directories.
Skills that already exist on a machine keep working, and skills an agent
creates later are written to local disk rather than into this repo.

That second point is the important one: **this repo is public.** Cursor's
`create-skill` writes new personal skills to `~/.cursor/skills/`. If that path
were a symlink to this repo, a skill written on a work machine — internal
service names, deploy steps, architecture — would land in a public
repository's working tree, one `git add -A` away from being published.

After pulling a new skill, run `./install.sh --skills` to link it. Re-running
is safe and also clears links to skills removed from the repo.

## Work machines

Nothing stops you keeping work-specific skills; keep them *out of this repo*.
Put them straight in `~/.claude/skills/` or `~/.cursor/skills/` as normal
directories. They sit alongside the linked ones and are never touched by the
installer.

## Layout

One directory per skill, each containing a `SKILL.md`:

```
skills/
├── my-skill/
│   ├── SKILL.md          # required
│   ├── reference.md      # optional, loaded on demand
│   └── scripts/          # optional helper scripts
└── another-skill/
    └── SKILL.md
```

Directory name should match the `name` in the frontmatter, and both should be
kebab-case.

## SKILL.md format

Claude Code and Cursor read the same format, so skills written here work in
both without changes:

```markdown
---
name: my-skill
description: What this does and when to use it. This is the only part the agent sees before deciding to load the skill, so make the trigger conditions explicit.
---

# My Skill

Instructions for the agent go here — steps, constraints, examples.
```

`name` and `description` are the only required fields. The `description` is
what determines whether the skill gets triggered at all: describe both what it
does *and* when it should fire.

## Adding a skill

```bash
mkdir -p skills/my-skill && $EDITOR skills/my-skill/SKILL.md
git add skills/my-skill && git commit -m "add: my-skill" && git push
```

On any other machine, `git pull` is enough to pick it up.

## Notes

- Keep skills tool-agnostic. Anything that hardcodes a path or a
  vendor-specific feature stops being portable, which is the point of keeping
  them here.
- `~/.cursor/skills-cursor/` is Cursor's own built-in set and is managed by
  Cursor. Don't link into it.
