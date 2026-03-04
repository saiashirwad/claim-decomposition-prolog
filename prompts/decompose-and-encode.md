# Task: Decompose a spec into claims and encode as Prolog

You are given a technical spec document. Your job is to:

1. Extract every atomic claim from the spec
2. Encode them as a Prolog file that can detect contradictions

## Step 1: Decompose into atomic claims

Read the spec and extract every distinct factual assertion. Each claim should be:

- **Atomic**: one assertion per claim. "The app is offline-first and uses Bun" is TWO claims.
- **Falsifiable**: opinions and aspirations are excluded. "This is a good design" is not a claim. "The server uses stdio transport" is.
- **Self-contained**: readable without the surrounding paragraph.

Give each claim an ID (c1, c2, ...) and group them by section.

## Step 2: Encode as Prolog

Write a single `.pl` file with these sections:

### Claims as facts

```prolog
claim(c1, short_descriptive_atom).
```

The atom (second argument) should be a short, readable identifier for what the claim asserts. Use snake_case.

### Categories

Every claim gets a category:
- `architectural` — internal design decisions that must be consistent with each other
- `source_verifiable` — can be checked against external docs (RFCs, API specs)
- `empirical` — needs testing to verify
- `opinion` — subjective, excluded from contradiction checking

### Domain rules

These are world-knowledge facts NOT stated in the spec, but needed to detect implicit contradictions. For example:

- "stdio transport cannot handle multiple concurrent connections"
- "vm.runInNewContext does not isolate synchronous infinite loops"
- "incremental text sync requires version tracking"

Encode these as Prolog facts with provenance:

```prolog
% <why this matters>
domain_rule(rule_name, llm_generated).
requires(Concept, Dependency).
incompatible(Thing1, Thing2).
implies(Feature, Consequence).
```

### Contradiction rules

Write Prolog rules that detect contradictions. Two types:

**Explicit**: two claims directly conflict.
```prolog
contradiction(X, Y, Reason) :-
    claim(X, something),
    claim(Y, opposite_thing),
    Reason = 'explanation'.
```

**Implicit**: claims conflict only via domain knowledge.
```prolog
contradiction(X, Y, Reason) :-
    claim(X, uses_feature_a),
    claim(Y, forbids_thing_b),
    requires(feature_a, thing_b),
    Reason = 'feature A requires thing B, but claim Y forbids it'.
```

### Query helper

Include this at the bottom:

```prolog
find_all_contradictions :-
    contradiction(X, Y, Reason),
    format('~n  CONTRADICTION: ~w <-> ~w~n', [X, Y]),
    claim(X, A), claim(Y, B),
    format('    ~w: ~w~n', [X, A]),
    format('    ~w: ~w~n', [Y, B]),
    format('    Reason: ~w~n', [Reason]),
    fail.
find_all_contradictions :-
    format('~n  Done.~n').
```

## Important guidelines

- Be exhaustive with claims. A 500-line spec should yield 80-120 claims.
- Be conservative with contradictions. Only flag things that are genuinely inconsistent, not merely unusual.
- Domain rules should be things a senior engineer would agree with, not obscure edge cases.
- Every contradiction rule must have a clear, specific reason string.
- Use `:- discontiguous` declarations as needed to avoid Prolog warnings.
- The output should be a SINGLE valid `.pl` file that can be loaded with `swipl` and queried with `?- find_all_contradictions.`

## Output

Write the Prolog file to `examples/codemode-vision.pl`. Do not output anything else — just the file.

The spec to analyze is in `examples/codemode-vision.md`.
