# claim-decomposition-prolog

Automated contradiction detection for spec documents using Prolog.

## Problem

AI-generated specs mix true claims with fabrications. Paragraph-level plausibility hides per-claim errors. Manual review doesn't scale — a 500-line spec has ~100 atomic claims and ~5000 pairwise relationships to check.

## Core idea

1. Decompose a spec into atomic claims (each gets an ID)
2. Encode claims as Prolog facts
3. Encode relationships and consistency rules
4. Prolog's unification + backtracking exhaustively finds every contradiction

## How it works

### Step 1: Decompose

Input: prose spec. Output: numbered atomic claims.

```
C1: All file reads go through the LSP
C2: searchText does direct file search
C3: The sandbox only exposes lsp.*, path.*, and JS builtins
```

### Step 2: Encode as Prolog

Claims become facts. Relationships become rules.

```prolog
claim(c1, all_reads_via_lsp).
claim(c2, search_text_direct_file).
claim(c3, sandbox_only_lsp_path_builtins).

is_read_operation(search_text).
uses_lsp(search_text, false).

% contradiction: a read operation that doesn't use LSP violates c1
contradiction(C1, C2) :-
    claim(C1, all_reads_via_lsp),
    claim(C2, Desc),
    is_read_operation(Op),
    uses_lsp(Op, false).
```

### Step 3: Query

```prolog
?- contradiction(X, Y).
X = c1, Y = c2.
```

Prolog's backtracking searches the entire claim space. No manual N² pairwise checks.

### Step 4: Axioms

Establish foundational claims first. Everything else derives from or must be consistent with axioms. When a contradiction is found, trace it back to which axiom it violates — either the axiom is wrong or the derived claim is.

## Key properties

- **Exhaustive**: Prolog checks all pairs, not just obvious ones
- **Traceable**: every contradiction comes with the chain of claims that produced it
- **Incremental**: add new claims and rules, re-query — no need to re-review the whole doc
- **Composable**: rules are reusable across specs (e.g., "if X is async and Y assumes sync X, contradiction")

## Open questions

- How to automate the decomposition step (LLM extracts claims, but how to ensure completeness?)
- What's the right granularity for atoms? Too coarse = missed contradictions, too fine = noise
- Can we generate the Prolog encoding from structured claim annotations, or does it need manual encoding?
- Domain-specific rule libraries (e.g., "LSP consistency rules", "REST API consistency rules")
