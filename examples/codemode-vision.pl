% ============================================================
% codemode-vision contradiction detection
% ============================================================

:- discontiguous claim/2.
:- discontiguous category/2.
:- discontiguous requires/2.
:- discontiguous incompatible/2.
:- discontiguous implies/2.
:- discontiguous limitation/2.

% --- CLAIMS ---------------------------------------------------
% Selected claims relevant to contradiction detection.
% Purely descriptive claims (type fields, etc.) are omitted.

% Core architecture
claim(c1,  is_mcp_server).
claim(c2,  single_execute_tool).
claim(c3,  execute_backed_by_lsp).
claim(c4,  llm_writes_javascript).
claim(c5,  code_runs_in_vm_sandbox).
claim(c6,  transactional_semantics).
claim(c7,  llms_better_at_code_than_tools).  % opinion

% Positioning vs Serena
claim(c8,  serena_is_multi_tool_server).
claim(c10, focused_code_execution_runtime).
claim(c11, optimized_for_typescript).
claim(c13, curated_lsp_api).

% No interactive features
claim(c17, no_completion_features).
claim(c18, no_hover_tooltips).
claim(c19, no_interactive_features).
claim(c20, headless_programmatic_tool).

% Runtime & transport
claim(c31, primary_runtime_is_bun).
claim(c32, node_compatible).
claim(c33, no_bun_specific_apis).
claim(c35, mcp_transport_is_stdio).
claim(c39, sandbox_uses_vm_run_in_new_context).
claim(c40, timeout_uses_promise_race).
claim(c43, bun_has_good_vm_support).
claim(c44, package_manager_is_bun).
claim(c46, tool_accepts_javascript_string).

% Code normalization
claim(c55, adopts_normalize_code_pattern).
claim(c59, lightweight_ast_parsing).
claim(c60, ast_parser_is_acorn).
claim(c61, last_expression_auto_returned).
claim(c62, last_promise_auto_awaited).

% Timeout
claim(c63, timeout_is_mandatory).
claim(c64, execution_wrapped_in_promise_race).
claim(c65, default_timeout_30_seconds).
claim(c70, timeout_does_not_catch_sync_loops).
claim(c71, sync_loop_risk_accepted_for_v1).
claim(c73, sync_loop_fix_is_worker_threads_v2).

% Concurrency
claim(c74, execute_calls_serialized_with_mutex).
claim(c75, concurrent_scripts_corrupt_lsp_state).
claim(c78, serialization_not_a_bottleneck).

% API surface
claim(c79, eight_read_operations).
claim(c90, search_text_not_lsp_based).
claim(c94, six_write_operations).
claim(c106, fifteen_lsp_functions_total).

% Sandbox — available
claim(c196, all_15_lsp_primitives_in_vm).
claim(c197, js_builtins_available).
claim(c200, path_utils_available).

% Sandbox — not available
claim(c201, no_fetch_or_network_in_sandbox).
claim(c202, no_fs_require_import_in_sandbox).
claim(c204, no_settimeout_in_sandbox).
claim(c206, no_runtime_globals_in_sandbox).

% Diagnostics
claim(c117, lsp_diagnostics_push_based).
claim(c118, lsp_diagnostics_not_request_response).
claim(c121, diagnostics_wait_timeout_2s).
claim(c123, write_result_waits_2s_for_diagnostics).

% Transactional writes
claim(c174, first_access_sends_did_open).
claim(c175, original_content_stored_on_first_access).
claim(c179, reads_go_through_lsp_buffer_not_disk).
claim(c180, success_flushes_all_dirty_buffers_atomically).
claim(c181, failure_rolls_back_to_originals_via_did_change).
claim(c182, failure_leaves_disk_untouched).
claim(c184, rollback_does_not_use_close_open).

% Rollback mechanism
claim(c183, rollback_uses_did_change).
claim(c186, did_change_rollback_more_reliable).

% Language server
claim(c224, v1_typescript_only).
claim(c225, language_server_is_ts_language_server).
claim(c226, language_server_communicates_over_stdio).
claim(c227, architecture_is_language_agnostic).

% Initialization
claim(c233, listens_for_quiescent_true).
claim(c235, quiescent_fallback_3_seconds).
claim(c237, warmup_happens_in_background).
claim(c238, warmup_not_on_first_execute).

% Document sync
claim(c239, client_declares_incremental_sync).
claim(c243, rollback_version_still_increments).

% Crash recovery
claim(c248, lsp_death_rejects_pending_requests).
claim(c250, script_failure_triggers_rollback).
claim(c252, respawn_with_full_init_on_detection).
claim(c253, previously_open_docs_not_replayed).

% LSP capabilities NOT used
claim(c266, no_completion_in_v1).
claim(c267, no_hover_in_v1).
claim(c268, no_code_action_in_v1).

% Deferred features
claim(c284, multi_language_deferred).
claim(c288, shell_execution_out_of_scope).
claim(c294, worker_threads_deferred).
claim(c296, checkpoint_mid_script_flush_deferred).
claim(c297, scripts_should_be_short_in_v1).

% Risks
claim(c299, diagnostics_may_be_stale).
claim(c303, cold_start_may_miss_references).
claim(c306, warmup_does_not_block_first_request).
claim(c307, first_request_waits_if_warmup_incomplete).
claim(c315, sync_infinite_loop_blocks_event_loop).
claim(c316, mcp_server_hangs_on_sync_loop).

% Comparison / competition
claim(c322, fewer_moving_parts_than_serena).
claim(c323, has_transactional_semantics).
claim(c324, more_token_efficient_one_tool).

% Success criteria
claim(c326, llm_can_do_multi_file_refactor_in_one_call).
claim(c327, failed_scripts_roll_back_cleanly).
claim(c328, llm_self_corrects_from_errors).

% --- CATEGORIES -----------------------------------------------

category(c1,  architectural).
category(c2,  architectural).
category(c3,  architectural).
category(c4,  architectural).
category(c5,  architectural).
category(c6,  architectural).
category(c7,  opinion).
category(c8,  source_verifiable).
category(c10, architectural).
category(c11, architectural).
category(c13, architectural).
category(c17, architectural).
category(c18, architectural).
category(c19, architectural).
category(c20, architectural).
category(c31, architectural).
category(c32, architectural).
category(c33, architectural).
category(c35, architectural).
category(c39, architectural).
category(c40, architectural).
category(c43, empirical).
category(c44, architectural).
category(c46, architectural).
category(c55, architectural).
category(c59, architectural).
category(c60, architectural).
category(c61, architectural).
category(c62, architectural).
category(c63, architectural).
category(c64, architectural).
category(c65, architectural).
category(c70, architectural).
category(c71, architectural).
category(c73, architectural).
category(c74, architectural).
category(c75, architectural).
category(c78, architectural).
category(c79, architectural).
category(c90, architectural).
category(c94, architectural).
category(c106, architectural).
category(c196, architectural).
category(c197, architectural).
category(c200, architectural).
category(c201, architectural).
category(c202, architectural).
category(c204, architectural).
category(c206, architectural).
category(c117, source_verifiable).
category(c118, source_verifiable).
category(c121, architectural).
category(c123, architectural).
category(c174, architectural).
category(c175, architectural).
category(c179, architectural).
category(c180, architectural).
category(c181, architectural).
category(c182, architectural).
category(c183, architectural).
category(c184, architectural).
category(c186, architectural).
category(c224, architectural).
category(c225, architectural).
category(c226, architectural).
category(c227, architectural).
category(c233, source_verifiable).
category(c235, architectural).
category(c237, architectural).
category(c238, architectural).
category(c239, source_verifiable).
category(c243, architectural).
category(c248, architectural).
category(c250, architectural).
category(c252, architectural).
category(c253, architectural).
category(c266, architectural).
category(c267, architectural).
category(c268, architectural).
category(c284, architectural).
category(c288, architectural).
category(c294, architectural).
category(c296, architectural).
category(c297, architectural).
category(c299, empirical).
category(c303, empirical).
category(c306, architectural).
category(c307, architectural).
category(c315, source_verifiable).
category(c316, architectural).
category(c322, architectural).
category(c323, source_verifiable).
category(c324, empirical).
category(c326, architectural).
category(c327, architectural).
category(c328, architectural).

% --- DOMAIN RULES (world knowledge, NOT from the spec) --------

% VM Sandboxing & Isolation

% vm.runInNewContext runs on the host event loop; sync CPU blocks everything
limitation(vm_run_in_new_context, shares_event_loop).

% vm.runInNewContext can be escaped via prototype chain traversal
limitation(vm_run_in_new_context, prototype_chain_escape).

% Promise.race does not cancel or abort the losing promise
limitation(promise_race, no_cancellation).

% vm sandbox code doesn't participate in async_hooks tracking
limitation(vm_run_in_new_context, no_async_hooks).

% Removing setTimeout breaks common debounce/retry patterns LLMs write
implies(no_settimeout_in_sandbox, breaks_retry_patterns).

% LSP Protocol

% stdio transport is 1:1 — one server process per client connection
limitation(stdio_transport, single_connection_only).

% typescript-language-server wraps tsserver; OOM in tsserver is primary crash mode
requires(typescript_language_server, tsserver_process).
limitation(tsserver_process, oom_is_primary_crash_mode).

% textDocument/rename may return edits to files the client never opened
implies(lsp_rename, may_edit_unopened_files).

% Incremental sync requires monotonically increasing version numbers
requires(incremental_sync, monotonic_version_numbers).

% Rapid didClose+didOpen causes tsserver to lose state
incompatible(rapid_close_open, tsserver_state_consistency).

% No LSP request to pull diagnostics — push only via publishDiagnostics
limitation(lsp_diagnostics, push_only_no_pull).

% workspace/symbol does fuzzy matching, not exact matching
limitation(workspace_symbol, fuzzy_not_exact).

% prepareRename can reject (e.g., built-in types, node_modules)
limitation(prepare_rename, can_reject_symbols).

% documentSymbol returns ranges, not source text
limitation(document_symbol, returns_ranges_not_content).

% TypeScript / tsserver Specifics

% tsserver does not eagerly index entire project — lazy indexing
limitation(tsserver, lazy_indexing).

% Each didOpen file consumes tsserver memory; 100+ files risks OOM
limitation(tsserver, memory_grows_with_open_files).

% tsserver uses UTF-16 offsets; supplementary plane chars cause offset issues
limitation(tsserver, utf16_position_encoding).

% In monorepos, goToDefinition may jump to .d.ts not source .ts
limitation(tsserver, project_references_go_to_dts).

% Without codeAction, no programmatic auto-import
implies(no_code_action, no_auto_import).

% Bun / Node Compatibility

% Bun vm module is a compat shim, not 1:1 with Node vm
limitation(bun_vm, not_identical_to_node_vm).

% Bun stdio buffering differs from Node's
limitation(bun_stdio, different_buffering_from_node).

% Bun child_process.spawn has different signal handling from Node
limitation(bun_spawn, different_signal_handling).

% Transactional Semantics

% Sequential multi-file disk writes are not truly atomic
limitation(sequential_disk_writes, not_truly_atomic).

% Partial flush: already-written files are NOT restored on rollback
limitation(partial_flush_rollback, does_not_restore_disk_writes).

% External edits while file is buffered make stored originals stale
limitation(buffered_originals, invalidated_by_external_edits).

% didChange rollback triggers re-analysis for each rolled-back file
implies(did_change_rollback, triggers_reanalysis_storm).

% MCP Protocol

% console.log in MCP server process would corrupt JSON-RPC stream
incompatible(console_log_on_stdout, mcp_json_rpc_stream).

% MCP clients may truncate tool results beyond ~100KB
limitation(mcp_tool_results, size_limit_100kb).

% MCP tools/call returns a single result — no streaming
limitation(mcp_tool_call, no_streaming).

% Code Normalization

% Acorn parses JavaScript only — TypeScript syntax causes parse errors
limitation(acorn_parser, javascript_only).
incompatible(acorn_parser, typescript_syntax).

% Auto-return of last expression is ambiguous for assignments vs expressions
limitation(implicit_return, ambiguous_for_assignments).

% console.log ordering is unpredictable with Promise.all
limitation(console_log_capture, unpredictable_ordering_with_promise_all).

% Concurrency

% Async mutex has no queue depth limit — no backpressure
limitation(async_mutex, no_queue_depth_limit).

% Mutex has no circuit breaker — cascading failures possible
limitation(async_mutex, no_circuit_breaker).

% Symbol Path Resolution

% Overload [N] indices shift when overloads are added/removed
limitation(overload_index, unstable_across_edits).

% documentSymbol doesn't cover standalone statements, if blocks, try/catch
limitation(document_symbol, does_not_cover_all_constructs).

% --- CONTRADICTION RULES --------------------------------------

% == Explicit contradictions ==

% C70 says timeout doesn't catch sync loops, but C63 says timeout is mandatory
% and C327 says failed scripts roll back cleanly. A sync loop prevents both
% timeout and rollback.
contradiction(c63, c70, 'Mandatory timeout is ineffective against sync infinite loops — Promise.race cannot interrupt blocked event loop') :-
    claim(c63, timeout_is_mandatory),
    claim(c70, timeout_does_not_catch_sync_loops).

% C180 says buffers flush "atomically" but sequential disk writes are not atomic
contradiction(c180, c327, 'Atomic flush is not truly atomic — sequential disk writes can be interrupted, leaving partial state despite rollback guarantee') :-
    claim(c180, success_flushes_all_dirty_buffers_atomically),
    claim(c327, failed_scripts_roll_back_cleanly),
    limitation(sequential_disk_writes, not_truly_atomic).

% C306 says warmup doesn't block first request, C307 says first request waits
contradiction(c306, c307, 'Conflicting warmup behavior: C306 says warmup does not block first request, C307 says first request waits if warmup incomplete') :-
    claim(c306, warmup_does_not_block_first_request),
    claim(c307, first_request_waits_if_warmup_incomplete).

% C79 says 8 read ops, C94 says 6 write ops, C106 says 15 total, but 8+6+1(diagnostics)=15 is correct
% C90 says searchText is not LSP-based, yet it's counted among the 15 "lsp.*" functions
contradiction(c90, c106, 'searchText is not LSP-based but is counted as one of the 15 lsp.* functions — naming inconsistency') :-
    claim(c90, search_text_not_lsp_based),
    claim(c106, fifteen_lsp_functions_total).

% == Implicit contradictions via domain rules ==

% Promise.race doesn't cancel — after timeout, script continues making LSP calls
contradiction(c40, c6, 'Promise.race does not cancel the timed-out script; it continues making LSP calls, potentially corrupting transactional state after timeout') :-
    claim(c40, timeout_uses_promise_race),
    claim(c6, transactional_semantics),
    limitation(promise_race, no_cancellation).

% vm sandbox claims to exclude process/globals, but prototype escape can recover them
contradiction(c206, c5, 'vm.runInNewContext prototype chain escape can recover process, require, etc., undermining sandbox isolation claims') :-
    claim(c206, no_runtime_globals_in_sandbox),
    claim(c5, code_runs_in_vm_sandbox),
    limitation(vm_run_in_new_context, prototype_chain_escape).

% No setTimeout in sandbox, but LLMs commonly write setTimeout-based retry patterns
contradiction(c204, c328, 'Removing setTimeout breaks retry patterns LLMs commonly write; LLM cannot self-correct if the alternative pattern is not documented') :-
    claim(c204, no_settimeout_in_sandbox),
    claim(c328, llm_self_corrects_from_errors),
    implies(no_settimeout_in_sandbox, breaks_retry_patterns).

% Acorn only parses JavaScript, but tool description includes TypeScript types,
% prompting LLMs to write TypeScript syntax
contradiction(c60, c46, 'Acorn parses JavaScript only, but tool accepts JS strings while showing TS type definitions — LLMs may write TypeScript syntax that acorn rejects') :-
    claim(c60, ast_parser_is_acorn),
    claim(c46, tool_accepts_javascript_string),
    limitation(acorn_parser, javascript_only).

% Bun vm is not identical to Node vm, yet the system claims Node compatibility
contradiction(c32, c39, 'Bun vm module is a compat shim with behavioral differences from Node vm — sandbox behavior may differ across runtimes despite Node-compatible claim') :-
    claim(c32, node_compatible),
    claim(c39, sandbox_uses_vm_run_in_new_context),
    limitation(bun_vm, not_identical_to_node_vm).

% tsserver lazy indexing means cold-start findReferences may miss results,
% but success criteria assumes multi-file refactor works in one call
contradiction(c326, c303, 'LLM multi-file refactor in one call may fail on cold start — tsserver lazy indexing means findReferences can miss results in unloaded files') :-
    claim(c326, llm_can_do_multi_file_refactor_in_one_call),
    claim(c303, cold_start_may_miss_references),
    limitation(tsserver, lazy_indexing).

% Diagnostics push-only with 2s wait is a heuristic; complex type changes
% can take 5-10s in tsserver
contradiction(c121, c299, 'Diagnostics 2s timeout is insufficient for complex type changes — tsserver may take 5-10s, and there is no way to know when diagnostics are complete') :-
    claim(c121, diagnostics_wait_timeout_2s),
    claim(c299, diagnostics_may_be_stale),
    limitation(lsp_diagnostics, push_only_no_pull).

% No codeAction means no auto-import; write-then-check loop detects
% missing imports but cannot fix them
contradiction(c268, c326, 'Without codeAction (deferred), LLM cannot auto-import — refactoring that introduces new type references requires manual import construction, breaking single-call workflow') :-
    claim(c268, no_code_action_in_v1),
    claim(c326, llm_can_do_multi_file_refactor_in_one_call),
    implies(no_code_action, no_auto_import).

% Sync infinite loop blocks event loop, which also blocks the MCP stdio
% transport and LSP connection — blast radius is larger than spec states
contradiction(c315, c316, 'Sync infinite loop does not just hang MCP server — it blocks LSP connection, causing tsserver to time out and potentially drop the client') :-
    claim(c315, sync_infinite_loop_blocks_event_loop),
    claim(c316, mcp_server_hangs_on_sync_loop),
    limitation(vm_run_in_new_context, shares_event_loop).

% Partial flush failure: spec says rollback LSP state, but already-written
% files on disk are not restored
contradiction(c182, c180, 'Partial flush failure leaves disk inconsistent — already-written files are not restored, contradicting the guarantee that failure leaves disk untouched') :-
    claim(c182, failure_leaves_disk_untouched),
    claim(c180, success_flushes_all_dirty_buffers_atomically),
    limitation(partial_flush_rollback, does_not_restore_disk_writes).

% Rollback of many files triggers reanalysis storm, but serialization
% means next script must wait
contradiction(c74, c183, 'Rollback via didChange triggers re-analysis for each file; next serialized execute call must wait for all re-analysis to complete or risk stale diagnostics') :-
    claim(c74, execute_calls_serialized_with_mutex),
    claim(c183, rollback_uses_did_change),
    implies(did_change_rollback, triggers_reanalysis_storm).

% Mutex has no queue depth limit — rapid calls queue unboundedly
% and each has its own 30s timeout
contradiction(c74, c65, 'Async mutex has no queue depth limit — 50 queued calls with 30s timeout each means the last call waits up to 25 minutes before starting') :-
    claim(c74, execute_calls_serialized_with_mutex),
    claim(c65, default_timeout_30_seconds),
    limitation(async_mutex, no_queue_depth_limit).

% tsserver memory grows with open files; rename can open 20+ files;
% no file count limit mentioned
contradiction(c326, c252, 'Bulk rename can open 100+ files in tsserver, risking OOM — crash recovery respawns but loses all buffered state, failing the multi-file refactor') :-
    claim(c326, llm_can_do_multi_file_refactor_in_one_call),
    claim(c252, respawn_with_full_init_on_detection),
    limitation(tsserver, memory_grows_with_open_files).

% --- QUERY HELPER ---------------------------------------------

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
