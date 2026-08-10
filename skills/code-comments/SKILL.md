---
name: code-comments
description: How to comment code. Use when writing or editing code, docstrings, or inline comments. Keeps comments few and short — no narrating what the code already says — while protecting the comments that carry information the code cannot. For prose outside code, see the plain-english skill.
---

# Code Comments

## Default to no comment

Code says what it does. A comment earns its place only by saying something the
code cannot. Most lines need none.

Delete on sight:

- Restatements: `# increment the counter` above `counter += 1`
- Docstrings that repeat the signature and type hints
- Step narration: `# Step 1: fetch`, `# Step 2: parse`
- Section banners inside short functions
- Changelog notes: `# added in v2`, `# changed to fix the login bug`. Git has this.
- Explanations of language basics

Test: if a reader could work it out from the code in ten seconds, cut it.

## What earns a comment

- Why this approach and not the obvious one
- A constraint that is invisible locally: ordering requirements, rate limits, a
  lock held by the caller
- A workaround for someone else's bug, with a link
- An invariant that breaks quietly if violated
- Decoding a regex, bit manipulation, or a magic constant

## Do not strip everything

Match the density of the file you are in. A codebase that comments heavily
should not receive a comment-free patch; that reads as a different author.

Leave existing comments alone unless you are changing the code they describe,
or they are actively wrong. Removing comments is not a task on its own — it is
a side effect of editing the code around them.

## Length and wording

One line where one line works. A comment should rarely be longer than the code
it explains.

Write the comment itself in plain English: active voice, concrete nouns, no
filler adverbs. "Fails on names over 64 bytes" beats "carefully handles edge
cases". The plain-english skill covers this in full.

## Examples

Narration, all of it removable:

```python
# Loop through the users
for user in users:
    # Check if active
    if user.active:
        # Add to results
        results.append(user)
```

```python
for user in users:
    if user.active:
        results.append(user)
```

A docstring restating the signature, replaced by what a caller cannot see:

```python
def send_email(to: str, subject: str) -> bool:
    """Send an email.

    Args:
        to: The recipient address.
        subject: The subject line.

    Returns:
        True if the email was sent successfully.
    """
```

```python
def send_email(to: str, subject: str) -> bool:
    """Returns False on a 4xx from the provider. Raises only on network error."""
```

A comment worth keeping:

```js
// Retry twice: the provider returns 502 for about a second after a deploy.
```

## Before finishing

- Can any comment be deleted without losing information? Delete it.
- Does any comment say what, rather than why? Rewrite or cut.
- Does the comment density match the rest of the file?
