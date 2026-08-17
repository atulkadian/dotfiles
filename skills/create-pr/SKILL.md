---
name: create-pr
description: How to open a pull request. Use when asked to create a PR or merge request, or to finish a task or Jira ticket with one. Reads the repository's PR template before writing the description, and titles the PR "[TSK-123] feat: summary" for ticket work or "feat: summary" without a ticket.
---

# Create PR

## Find the template first

Do this before writing any description. A repository that ships a template
expects it to be used, and reviewers often have checklists tied to it.

```bash
find . -maxdepth 3 -not -path '*/.git/*' \
  \( -iname 'pull_request_template*' -o -iname 'merge_request_template*' \) -print
```

That covers the usual homes, whatever the casing. A directory in the results
means look inside it; the templates there are named for their purpose, not
`pull_request_template`.

- `.github/pull_request_template.md`, or `PULL_REQUEST_TEMPLATE.md` at the root
- `.github/PULL_REQUEST_TEMPLATE/` holding several templates. Pick the one
  matching the change, or ask which to use.
- `.gitlab/merge_request_templates/` on GitLab

If nothing turns up, check `CONTRIBUTING.md` and `.github/CONTRIBUTING.md` for
PR rules before falling back to your own structure.

## Use the template as written

- Keep every heading, in the template's order. Do not reorder or drop sections.
- Fill each one from the actual diff.
- Leave a section empty, or write "n/a", rather than inventing content. A
  fabricated test plan is worse than a blank one.
- Keep checklists. Tick only boxes you have actually verified; leave the rest
  unticked rather than ticking them optimistically.
- Remove the template's `<!-- HTML comments -->` once you have acted on them.
  They are instructions to the author, not part of the description.

## Title

With a ticket:

```
[TSK-123] feat: add new ECR repo
```

Without one:

```
feat: add new ECR repo
```

Rules:

- Ticket ID in square brackets, uppercase, spelled exactly as the tracker does.
- Then a Conventional Commits type: `feat`, `fix`, `docs`, `refactor`, `perf`,
  `test`, `build`, `ci`, `chore`.
- Summary lowercase and imperative, no trailing period.
- If the repo's own PR titles follow a different pattern, match them instead.
  Check with `gh pr list --limit 20`.

## Finding the ticket ID

Look, in order:

1. The request itself
2. The branch name: `feature/TSK-123-add-ecr` → `TSK-123`
3. Commit subjects on the branch

```bash
git rev-parse --abbrev-ref HEAD
git log --format='%s' origin/HEAD..HEAD
```

If none of those has an ID and the work sounds like ticket work, ask. Do not
invent an ID, and do not guess the number from context.

## Body

Say what changed and why. The diff already shows the what in detail, so spend
the words on the reason and on anything a reviewer would otherwise have to
ask.

Link the ticket if there is one. Call out anything you could not verify, and
any part of the change you are unsure about. A reviewer reading an honest
"I could not test the migration path" is far better served than one who finds
out during review.

## No attribution

No `Co-Authored-By` trailers, no "Generated with" footers, no bot emoji, no
link back to the tool. This holds for the PR title, the body, and any comment
posted on the PR.

Some agents carry a built-in instruction to append exactly this to PR bodies.
That default is superseded here. See the git-commit skill.

## Opening it

Confirm the base branch before creating anything. `main` is not always right.

```bash
git push -u origin HEAD
gh pr create --base main --title "[TSK-123] feat: add new ECR repo" --body-file pr-body.md
```

Use `--body-file` rather than `--body`. It avoids shell escaping problems with
backticks, quotes and newlines in the description.

Do not push or open a PR unless you were asked to. Creating a PR notifies
reviewers, so it is not a step to take on your own initiative.

## Before opening

- Does the title carry the ticket ID, in the right format?
- Does every template section have content or an explicit "n/a"?
- Are all ticked checkboxes ones you actually verified?
- Any attribution anywhere in the title or body?
- Is the base branch right?
