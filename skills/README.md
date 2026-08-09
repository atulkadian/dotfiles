# Skills

Portable agent skills. `install.sh --skills` symlinks this whole directory to:

| Agent       | Path               |
| ----------- | ------------------ |
| Claude Code | `~/.claude/skills` |
| Cursor      | `~/.cursor/skills` |

Because the directory is linked as a unit, `git pull` here updates every agent
on the machine immediately — no re-run of the installer.

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
