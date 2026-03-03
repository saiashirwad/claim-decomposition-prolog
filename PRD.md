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

## Claim categories

Not all claims are verified the same way. Category determines verification method and Prolog encoding strategy.

- **Source-verifiable**: an authoritative doc says true or false. "HTTP 204 returns no body" → check the RFC. Verified *outside* Prolog.
- **Architectural**: no external source needed — must be consistent with other claims in the same spec. This is where Prolog shines. Internal consistency checks.
- **Empirical**: can't know from docs or logic — must try it. "Bun's vm module supports async/await in sandboxed contexts." Tagged `needs_spike`, skipped by Prolog.
- **Opinion**: design decisions, not falsifiable. "We use Bun because it's faster." Excluded from encoding entirely.

```prolog
category(c1, architectural).
category(c2, architectural).
category(c3, source_verifiable).
category(c4, empirical).
category(c5, opinion).

% only check contradictions between architectural claims
contradiction(X, Y) :-
    category(X, architectural),
    category(Y, architectural),
    conflicts(X, Y).
```

## Implicit contradictions

Explicit contradictions: two stated claims conflict. Prolog handles these directly.

Implicit contradictions: claims only conflict via unstated assumptions. "No network access" and "authenticate via OAuth2" look fine side by side — until you know OAuth2 requires network calls. That knowledge isn't in the spec.

Prolog can find implicit contradictions, but only if the unstated assumptions are encoded as **domain rules** — background facts about how technologies/concepts work, separate from spec claims.

```prolog
% spec claims (from the document)
claim(c1, no_network).
claim(c2, uses_oauth2).

% domain rules (world knowledge, not from the spec)
requires(oauth2, network).

% implicit contradiction: spec claims X, which requires Y, but spec also claims not-Y
implicit_contradiction(X, Y) :-
    claim(X, no_network),
    claim(Y, uses_oauth2),
    requires(oauth2, network).
```

Two separate inputs to the system:
1. **Spec claims** — extracted from the document
2. **Domain rules** — world knowledge about how things work

Both auditable independently. The LLM can generate domain rules, but they're a separate artifact you can vet without re-reading the whole spec.

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
