# Task: Encode claims and domain rules as Prolog

Read these two files:
- `examples/codemode-claims.md` — atomic claims extracted from the spec
- `examples/codemode-domain-rules.md` — domain knowledge rules

Combine them into a single Prolog file that detects contradictions.

## Output structure

Write to `examples/codemode-vision.pl`. The file must have these sections in order:

### 1. Discontiguous declarations

```prolog
:- discontiguous claim/2.
:- discontiguous category/2.
:- discontiguous requires/2.
:- discontiguous incompatible/2.
:- discontiguous implies/2.
:- discontiguous limitation/2.
```

### 2. Claims as facts

```prolog
claim(c1, short_descriptive_atom).
claim(c2, another_atom).
```

Use short, readable snake_case atoms. The atom should capture the essence of the claim.

### 3. Categories

```prolog
category(c1, architectural).
category(c2, source_verifiable).
```

### 4. Domain rules as facts

```prolog
% stdio is 1:1 — one server per connection
requires(stdio_transport, single_connection).

% vm.runInNewContext doesn't isolate sync loops
limitation(vm_run_in_new_context, no_sync_loop_isolation).

% Promise.race doesn't cancel the losing promise
limitation(promise_race, no_cancellation).
```

### 5. Contradiction rules

Write rules that combine claims with domain rules to find conflicts. Two types:

**Explicit** — two claims directly conflict:
```prolog
contradiction(X, Y, Reason) :-
    claim(X, claims_thing_a),
    claim(Y, claims_opposite),
    Reason = 'A and B cannot both be true'.
```

**Implicit** — claims conflict via domain knowledge:
```prolog
contradiction(X, Y, Reason) :-
    claim(X, uses_feature),
    claim(Y, denies_requirement),
    requires(feature, requirement),
    Reason = 'Feature requires requirement, but Y denies it'.
```

### 6. Query helper

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

## Guidelines

- The file MUST be valid Prolog. Test mentally: would `swipl -g find_all_contradictions -g halt examples/codemode-vision.pl` run without errors?
- Be conservative with contradictions — only flag genuine inconsistencies, not things that are merely unusual or debatable.
- Every contradiction rule needs a clear, specific reason string.
- If a claim is categorized as `opinion`, do NOT include it in any contradiction rule.
- Prefer general contradiction patterns over one-off rules where possible. E.g., a rule that catches ANY "claims no X but uses something requiring X" is better than separate rules for each case.
