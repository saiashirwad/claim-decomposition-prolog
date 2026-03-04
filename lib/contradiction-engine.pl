% ============================================================
% Contradiction Engine — Reusable Prolog Library
% ============================================================
% This file contains GENERAL reasoning rules that work
% across any spec. It gets loaded alongside a spec-specific
% facts file that provides claims, annotations, and domain rules.
%
% The spec-specific file provides:
%   claim(Id, Text)                    — atomic claims
%   category(Id, Category)            — architectural | source_verifiable | empirical | opinion
%   asserts(Id, Property)             — claim says Property is true
%   denies(Id, Property)              — claim says Property is false/absent
%   requires(Id, Property)            — claim needs Property to work
%   provides(Id, Property)            — claim provides/enables Property
%   assumes(Id, Property)             — claim implicitly relies on Property
%   domain_requires(X, Y)            — world knowledge: X needs Y
%   domain_incompatible(X, Y)        — world knowledge: X and Y can't coexist
%   domain_implies(X, Y)             — world knowledge: if X then Y must be true
%
% This file provides:
%   contradiction/3, tension/3        — found by reasoning
%   find_all/0, check/1, without/1   — query helpers
% ============================================================

:- discontiguous claim/2.
:- discontiguous category/2.
:- discontiguous asserts/2.
:- discontiguous denies/2.
:- discontiguous requires/2.
:- discontiguous provides/2.
:- discontiguous assumes/2.
:- discontiguous domain_requires/2.
:- discontiguous domain_incompatible/2.
:- discontiguous domain_implies/2.

% ============================================================
% REASONING RULES
% ============================================================

% --- Reachability through domain_requires ---
% X eventually requires Y (1 or more hops).
% This lets Prolog chase arbitrarily deep chains.
eventually_requires(X, Y) :-
    domain_requires(X, Y).
eventually_requires(X, Y) :-
    domain_requires(X, Z),
    eventually_requires(Z, Y).

% --- CONTRADICTIONS (hard logical conflicts) ---

% Type 1: Direct denial
% Claim X denies a property that Claim Y directly requires.
contradiction(X, Y, Reason) :-
    denies(X, Property),
    requires(Y, Property),
    X \= Y,
    claim(X, TX), claim(Y, TY),
    format(atom(Reason),
        '[direct] "~w" denies ~w, but "~w" requires it',
        [TX, Property, TY]).

% Type 2: Transitive denial via domain knowledge
% Claim X denies Property. Claim Y asserts Action.
% Domain knowledge says Action (eventually) requires Property.
contradiction(X, Y, Reason) :-
    denies(X, Property),
    asserts(Y, Action),
    eventually_requires(Action, Property),
    X \= Y,
    claim(X, TX), claim(Y, TY),
    format(atom(Reason),
        '[transitive] "~w" denies ~w, but "~w" asserts ~w which eventually requires ~w',
        [TX, Property, TY, Action, Property]).

% Type 3: Mutual exclusion
% Claim X asserts Property, Claim Y denies the same Property.
contradiction(X, Y, Reason) :-
    asserts(X, Property),
    denies(Y, Property),
    X \= Y,
    claim(X, TX), claim(Y, TY),
    format(atom(Reason),
        '[mutual] "~w" asserts ~w, but "~w" denies it',
        [TX, Property, TY]).

% Type 4: Domain incompatibility
% Claims assert two things that domain knowledge says can't coexist.
contradiction(X, Y, Reason) :-
    asserts(X, A),
    asserts(Y, B),
    (domain_incompatible(A, B) ; domain_incompatible(B, A)),
    X \= Y,
    claim(X, TX), claim(Y, TY),
    format(atom(Reason),
        '[incompatible] "~w" asserts ~w and "~w" asserts ~w — domain knowledge says these conflict',
        [TX, A, TY, B]).

% Type 5: Denied dependency
% Claim X asserts Action. Action requires Intermediate.
% Claim Y denies Intermediate.
contradiction(X, Y, Reason) :-
    asserts(X, Action),
    eventually_requires(Action, Property),
    denies(Y, Property),
    X \= Y,
    claim(X, TX), claim(Y, TY),
    format(atom(Reason),
        '[denied-dep] "~w" asserts ~w which requires ~w, but "~w" denies ~w',
        [TX, Action, Property, TY, Property]).

% Type 6: Broken assumption
% Claim X assumes Property. Claim Y denies it.
contradiction(X, Y, Reason) :-
    assumes(X, Property),
    denies(Y, Property),
    X \= Y,
    claim(X, TX), claim(Y, TY),
    format(atom(Reason),
        '[broken-assumption] "~w" assumes ~w, but "~w" denies it',
        [TX, Property, TY]).

% --- TENSIONS (not hard contradictions, but risky) ---

% Type T1: Unmet assumption
% Claim X assumes Property. No claim provides it.
tension_unmet_assumption(X, Property, Reason) :-
    assumes(X, Property),
    \+ provides(_, Property),
    claim(X, TX),
    format(atom(Reason),
        '[unmet-assumption] "~w" assumes ~w, but no claim provides it',
        [TX, Property]).

% Type T2: Requirement with no provider
% Claim X requires Property. No claim provides it, and no claim
% asserts it either.
tension_unmet_requirement(X, Property, Reason) :-
    requires(X, Property),
    \+ provides(_, Property),
    \+ asserts(_, Property),
    claim(X, TX),
    format(atom(Reason),
        '[unmet-requirement] "~w" requires ~w, but nothing provides or asserts it',
        [TX, Property]).

% Type T3: Domain implication not addressed
% Claim X asserts Action. Domain says Action implies Consequence.
% No claim addresses (asserts or denies) Consequence.
tension_unaddressed(X, Consequence, Reason) :-
    asserts(X, Action),
    domain_implies(Action, Consequence),
    \+ asserts(_, Consequence),
    \+ denies(_, Consequence),
    claim(X, TX),
    format(atom(Reason),
        '[unaddressed] "~w" asserts ~w which implies ~w, but spec never addresses ~w',
        [TX, Action, Consequence, Consequence]).

% ============================================================
% QUERY HELPERS
% ============================================================

% Find all contradictions (deduplicated: skip Y,X if X,Y shown)
find_contradictions :-
    format('~n=== CONTRADICTIONS ===~n'),
    forall(
        (contradiction(X, Y, Reason), X @< Y),
        (format('~n  ~w <-> ~w~n    ~w~n', [X, Y, Reason]))
    ),
    format('~n').

% Find all tensions
find_tensions :-
    format('=== UNMET ASSUMPTIONS ===~n'),
    forall(
        tension_unmet_assumption(X, Prop, Reason),
        (format('~n  ~w (~w)~n    ~w~n', [X, Prop, Reason]))
    ),
    format('~n=== UNMET REQUIREMENTS ===~n'),
    forall(
        tension_unmet_requirement(X, Prop, Reason),
        (format('~n  ~w (~w)~n    ~w~n', [X, Prop, Reason]))
    ),
    format('~n=== UNADDRESSED IMPLICATIONS ===~n'),
    forall(
        tension_unaddressed(X, Cons, Reason),
        (format('~n  ~w (~w)~n    ~w~n', [X, Cons, Reason]))
    ),
    format('~n').

% Everything
find_all :-
    find_contradictions,
    find_tensions.

% What contradicts a specific claim?
check(Claim) :-
    format('~nContradictions involving ~w:~n', [Claim]),
    claim(Claim, Text),
    format('  (~w)~n~n', [Text]),
    forall(
        (contradiction(Claim, Y, R) ; contradiction(Y, Claim, R)),
        (format('  <-> ~w: ~w~n', [Y, R]))
    ),
    format('~nTensions:~n'),
    forall(
        tension_unmet_assumption(Claim, _, R),
        (format('  ~w~n', [R]))
    ),
    forall(
        tension_unmet_requirement(Claim, _, R),
        (format('  ~w~n', [R]))
    ).

% What contradictions remain if we remove a claim?
without(Claim) :-
    format('~nContradictions WITHOUT ~w:~n', [Claim]),
    forall(
        (contradiction(X, Y, R), X \= Claim, Y \= Claim, X @< Y),
        (format('  ~w <-> ~w~n    ~w~n', [X, Y, R]))
    ).

% How many of each?
stats :-
    aggregate_all(count, (contradiction(X,Y,_), X @< Y), NC),
    aggregate_all(count, tension_unmet_assumption(_,_,_), NUA),
    aggregate_all(count, tension_unmet_requirement(_,_,_), NUR),
    aggregate_all(count, tension_unaddressed(_,_,_), NUI),
    format('Contradictions: ~w~nUnmet assumptions: ~w~nUnmet requirements: ~w~nUnaddressed implications: ~w~n',
        [NC, NUA, NUR, NUI]).
