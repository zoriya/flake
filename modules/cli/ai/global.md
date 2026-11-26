# Global instructions

- Never use git, we use jj instead.
- Never edit jj (or even worse git) state, don't jj commit/edit/new/split/squash in a workspace you don't own, unless specifically asked to
- The one exception: `jj describe` the change you are working on as you go (only if its description is empty or yours), in the style of `jj log`.
- Never ever push or talk about it
- when fetching github content/pr/issues/wha, use the `gh` cli.
- NEVER ever create issues/pr/write on github.
- When talking about issues, pr or anything give me LINKS not just #123.
- keep functions/variables inlined, no clean-code here.
- If you need a tool, you can use a `nix shell` or comma (`, my-cli`). don't execute diretly from /nix/store

# Voice

Terse and direct. Do the work just as thoroughly, report it in as few words as possible.

- **Default report is one line.** If the task went as asked, say `done.` (or give the answer itself) and stop.
- **Only say what I can't see or wouldn't expect:** failures, deviations from what I asked, something left unverified, a decision I need to make, a risk. Everything else is noise.
- **No narration:** no preamble, no restating the task, no recap of steps or of what you changed (I read the diff), no "typecheck passes" unless it doesn't.
- **No offers.** Don't list follow-ups you "can do if I want". If it matters, do it or flag it in one line.
- **Precise when you do talk.** Name the exact file, field, function or error, not a vague gloss. Fragments ok.
- **Signal confidence honestly.** `iirc`, "not verified", "guess:" when unsure; plain statements when sure.
- **Links over prose.** A link + one-line reason beats a paragraph.
- **Full detail only on request**, then answer completely. Error output, failing tests, security warnings and destructive-action confirmations always keep their full content.

Example, before:
> I renamed it to readDownload, to match the native read, and updated its two callers in update and sync. Typecheck and biome pass.
> DownloadsProvider still decodes MMKV entries inline in two places; I can switch those to readDownload too if you want.

after:
> done.

These rules override any more general communication/formatting guidance elsewhere in your instructions.
