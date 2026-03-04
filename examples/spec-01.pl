% ============================================================
% NoteSync contradiction detection
% ============================================================
:- discontiguous requires_network/1.

% --- CLAIMS (extracted from the spec) -----------------------
% These are just labels — what each claim asserts.

claim(c1,  offline_first).
claim(c2,  data_on_device_only).
claim(c3,  no_data_leaves_machine).
claim(c4,  no_user_accounts).
claim(c5,  no_authentication).
claim(c6,  supports_markdown).
claim(c7,  live_markdown_preview).
claim(c8,  notes_stored_as_json).
claim(c9,  notes_in_app_data_dir).
claim(c10, fetches_cloud_preferences).
claim(c11, cloud_fetch_for_onboarding).
claim(c12, has_spell_checker).
claim(c13, spell_checker_uses_bundled_dict).
claim(c14, share_via_unique_links).
claim(c15, generates_sha256_hashes).
claim(c16, hashing_for_dedup).
claim(c17, all_processing_client_side).
claim(c18, no_server_component).
claim(c19, target_200ms_cold_start).
claim(c20, lazy_loads_markdown_parser).
claim(c21, lazy_loads_spell_dict).
claim(c22, lazy_loads_cloud_module).
claim(c23, lazy_loading_achieves_fast_start).

% --- CATEGORIES ---------------------------------------------

category(c1,  architectural).
category(c2,  architectural).
category(c3,  architectural).
category(c4,  architectural).
category(c5,  architectural).
category(c6,  architectural).
category(c7,  architectural).
category(c8,  architectural).
category(c9,  architectural).
category(c10, architectural).
category(c11, architectural).
category(c12, architectural).
category(c13, architectural).
category(c14, architectural).
category(c15, architectural).
category(c16, architectural).
category(c17, architectural).
category(c18, architectural).
category(c19, architectural).
category(c20, architectural).
category(c21, architectural).
category(c22, architectural).
category(c23, architectural).

% --- DOMAIN RULES (world knowledge, NOT from the spec) ------
% This is the "background knowledge" layer.

% Fetching from a cloud service requires network access.
requires_network(fetches_cloud_preferences).

% Sharing via links requires a server to host/resolve them.
requires_server(share_via_unique_links).

% If something requires a server, it also requires network.
requires_network(X) :- requires_server(X).

% Identifying a specific user's data in a cloud service
% requires some form of user identification (account/auth).
requires_user_identity(fetches_cloud_preferences).

% --- CONTRADICTION RULES ------------------------------------

% Explicit: claim says no network, another claim requires network
contradiction(X, Y, 'Claims conflict: no data should leave the machine, but this action requires network access') :-
    claim(X, no_data_leaves_machine),
    claim(Y, Action),
    requires_network(Action).

% Explicit: claim says no server, another claim requires a server
contradiction(X, Y, 'Claims conflict: no server component, but this feature requires a server') :-
    claim(X, no_server_component),
    claim(Y, Action),
    requires_server(Action).

% Implicit: claim says no accounts/auth, but another claim
% requires user identity
contradiction(X, Y, 'Implicit conflict: no user accounts, but this action requires identifying the user') :-
    claim(X, no_user_accounts),
    claim(Y, Action),
    requires_user_identity(Action).

% Explicit: offline-first vs actions requiring network
contradiction(X, Y, 'Claims conflict: app is offline-first, but this action requires network') :-
    claim(X, offline_first),
    claim(Y, Action),
    requires_network(Action).

% --- QUERY HELPER -------------------------------------------
% Find all contradictions and print them nicely.

find_all_contradictions :-
    contradiction(X, Y, Reason),
    format('~n  CONTRADICTION: ~w <-> ~w~n', [X, Y]),
    claim(X, A), claim(Y, B),
    format('    ~w: ~w~n', [X, A]),
    format('    ~w: ~w~n', [Y, B]),
    format('    Reason: ~w~n', [Reason]),
    fail.  % fail forces backtracking — keeps searching

find_all_contradictions :-
    format('~n  Done.~n').
