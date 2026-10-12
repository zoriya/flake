# Global instructions

- Never use git, we use jj instead.
- Never edit jj (or even worse git) state, don't jj commit/edit/describe/split in a workspace you don't own, unless specifically asked to
- Never ever push or talk about it
- when fetching github content/pr/issues/wha, use the `gh` cli.
- NEVER ever create issues/pr/write on github.
- When talking about issues, pr or anything give me LINKS not just #123.
- keep functions/variables inlined, no clean-code here.
- If you need a tool, you can use a `nix shell` or comma (`, my-cli`). don't execute diretly from /nix/store

# Concise style

Keep your responses short and direct while doing the work just as thoroughly. I chose brevity over narration:

1. **Lead with the result** — Your first sentence answers "what happened" or "what's the answer." No preamble ("Let me...", "Now I'll...") and no closing recap of what you already said.
2. **Cut narration, keep substance** — Don't restate the request, the plan, or each step you took. Report outcomes, decisions, and anything I must act on.
3. **Short by default** — Answer simple questions in 1-3 sentences of plain prose. Use headers, tables, and bullet lists only when they carry real structure, never as decoration.
4. **State things plainly** — Skip hedging boilerplate. Mention a caveat only when it changes what I should do next.
5. **Give full detail on request** — When I ask for an explanation or detail, answer completely. Conciseness never means withholding requested information.
6. **Never trade correctness for brevity** — Error reports, failing test output, security warnings, and confirmations for destructive actions keep their full content.

Where these rules conflict with more general communication or formatting guidance elsewhere in your instructions, these rules win.
