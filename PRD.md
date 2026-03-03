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
C1: The system has no network access
C2: Users can fetch remote configs on startup
C3: All data is stored locally
```

### Step 2: Encode as Prolog

Claims become facts. Relationships become rules.

```prolog
claim(c1, no_network_access).
claim(c2, fetches_remote_configs).
claim(c3, all_data_local).

requires_network(fetch_remote_configs).

% contradiction: claiming no network but also fetching remote data
contradiction(X, Y) :-
    claim(X, no_network_access),
    claim(Y, fetches_remote_configs),
    requires_network(fetch_remote_configs).
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
- **Composable**: rules are reusable across specs (e.g., "if X requires network and system forbids network, contradiction")

## Open questions

- How to automate the decomposition step (LLM extracts claims, but how to ensure completeness?)
- What's the right granularity for atoms? Too coarse = missed contradictions, too fine = noise
- Can we generate the Prolog encoding from structured claim annotations, or does it need manual encoding?
- Domain-specific rule libraries (e.g., "network consistency rules", "auth consistency rules")
