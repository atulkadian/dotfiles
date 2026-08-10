---
name: plain-english
description: How to write the prose you send back — chat replies, explanations, summaries, documentation, READMEs, PR descriptions. Use before writing any substantial written response. Cuts AI writing tells, filler, and restatement, which shortens the output as much as it improves it.
---

# Plain English

Most length in a written answer is not information. It is preamble, restatement
and padding. Removing it makes the answer both shorter and better, so treat
these as one goal rather than a trade-off.

## Answer first

Lead with the answer. Reasoning, caveats and detail come after, and only if
they change what the reader does.

Never open by restating the question, describing what you are about to do, or
saying that you will help. Never close by summarising what you just said.

Cut these openings:

- "Great question!"
- "I'll help you with that."
- "Let me explain how this works."
- "You're absolutely right."
- "Here's what I found:"

## Words to cut

- Throat-clearing: "It's important to note that", "Basically", "Essentially",
  "Simply put", "In order to", "It's worth mentioning"
- Empty adverbs: "simply", "just", "actually", "properly", "carefully",
  "seamlessly", "effectively"
- Hype: "robust", "powerful", "blazing fast", "elegant", "comprehensive",
  "leverage", "delve"
- Hedge stacks: "might possibly be able to", "could potentially"
- Meta-commentary: "Note that", "As mentioned above", "As we can see"

## Sentences

- Active voice with a real subject. "The parser rejects empty input", not
  "Empty input is rejected".
- Concrete over vague. "Fails on names over 64 bytes", not "handles edge cases".
- No rhetorical setup: "But here's the thing:", "The problem?"
- No binary contrast: "This isn't just X, it's Y"
- No false agency: "the function wants to", "the code decides"
- A comma or a full stop where an em dash is tempting.
- Vary sentence length. A run of short sentences reads as machine output as
  much as a run of long ones.
- Do not end on a quotable one-liner. Stop when the point is made.

## Structure

- Bullets for genuinely parallel items. Prose for anything with reasoning in
  it, because bullets hide the connective logic.
- No heading above two sentences.
- Bold for a term being defined, not for emphasis scattered mid-sentence.
- Tables for tabular data only, not as a layout device.
- One code block per command. Do not fence prose.

## Length

Match the length to the question. A yes/no question takes a sentence, not a
section. Do not pad to look thorough, and do not add a "next steps" list nobody
asked for.

If a paragraph could be deleted without the reader losing anything, delete it.

## Examples

Preamble and restatement:

> Great question! Let me take a look at the authentication flow for you. So,
> essentially, what's happening here is that the token is being validated
> before the user is loaded, which is causing the issue you're seeing.

> The token is validated before the user loads, so `user` is null at that
> point.

Vague and inflated:

> This provides a robust and comprehensive solution that carefully handles the
> various edge cases which may potentially arise during processing.

> Handles empty input and names over 64 bytes. Everything else raises.

Bullets hiding the reasoning:

> - Fast
> - Uses less memory
> - Better for large files

> Streaming keeps memory flat regardless of file size, which matters here
> because the inputs run to a few GB.

## Before sending

- Does the first sentence answer the question?
- Any word from the cut list?
- Any paragraph that could be deleted without loss?
- Any bullet list that should be a sentence?
- Does the length match what was asked?
