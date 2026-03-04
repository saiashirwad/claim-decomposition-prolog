# Task: Decompose a spec into atomic claims

Read the spec at `examples/codemode-vision.md` and extract every distinct factual assertion.

## Rules for claims

- **Atomic**: one assertion per claim. "The app uses Bun and supports Node" → TWO claims.
- **Falsifiable**: exclude opinions, aspirations, marketing language. "This is a good design" is not a claim. "The server uses stdio transport" is.
- **Self-contained**: readable without the surrounding paragraph.

## Output format

Write to `examples/codemode-claims.md` in this exact format:

```markdown
# codemode-vision — Claim Decomposition

## Section Name

- **C1**: The claim text
- **C2**: Another claim text

## Next Section

- **C3**: ...
```

## Categorize each claim

Append a category tag to each claim:

- `[architectural]` — internal design decisions that must be consistent with each other
- `[source_verifiable]` — can be checked against external docs (RFCs, LSP spec, Node/Bun docs)
- `[empirical]` — needs testing to verify ("Bun's vm module supports X")
- `[opinion]` — subjective, excluded from analysis

Example:
- **C1**: The runtime is Bun [architectural]
- **C2**: vm.runInNewContext provides isolation [source_verifiable]
- **C3**: Bun starts faster than Node [empirical]

## Guidelines

- Be exhaustive. This is a ~500 line spec — expect 80-120 claims.
- Go paragraph by paragraph. Don't skip tables — each row often contains multiple claims.
- Preserve section structure from the original doc.
- When a claim references a specific technology, API, or protocol detail, that's usually source_verifiable.
