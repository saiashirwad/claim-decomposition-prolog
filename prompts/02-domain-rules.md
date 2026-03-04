# Task: Generate domain rules for contradiction detection

Read the spec at `examples/codemode-vision.md`. Your job is to generate **domain rules** — world knowledge facts that are NOT stated in the spec but are needed to detect implicit contradictions.

These are things a senior engineer familiar with LSP, TypeScript, Node/Bun, and vm sandboxing would know.

## What domain rules look like

A domain rule captures a relationship between concepts:

- `requires(X, Y)` — X requires Y to function
- `incompatible(X, Y)` — X and Y cannot coexist
- `implies(X, Y)` — if X is true, Y must also be true
- `limitation(X, Description)` — X has a known limitation

## Examples of good domain rules

- "stdio transport is 1:1 — one server process per client connection"
- "vm.runInNewContext does NOT isolate synchronous CPU-bound loops from the host event loop"
- "LSP textDocument/rename may return edits to files not yet opened by the client"
- "incremental textDocumentSync requires the client to track document versions"
- "Promise.race does not cancel the losing promise — it just ignores its result"
- "typescript-language-server wraps tsserver — crashes in tsserver kill the language server"

## Output format

Write to `examples/codemode-domain-rules.md` in this format:

```markdown
# codemode-vision — Domain Rules

## Category Name (e.g., LSP Protocol, VM Sandboxing, TypeScript/Bun)

### rule_name_in_snake_case
- **Type**: requires / incompatible / implies / limitation
- **Statement**: plain English description
- **Relevance**: why this matters for this specific spec
- **Provenance**: llm_generated (all of these are)
```

## Guidelines

- Focus on rules that could surface contradictions or unstated assumptions in THIS spec.
- Don't generate obvious trivia. "JavaScript is single-threaded" is too generic. "vm.runInNewContext shares the event loop with the host" is specific and relevant.
- Aim for 20-40 rules. Quality over quantity.
- Each rule should make a senior engineer nod and say "yeah, good catch."
- Group by technical domain.
