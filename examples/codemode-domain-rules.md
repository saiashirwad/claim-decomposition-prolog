# codemode-vision — Domain Rules

Source: `codemode-vision.md`

## VM Sandboxing & Isolation

### vm_shares_event_loop
- **Type**: limitation
- **Statement**: `vm.runInNewContext` runs in the same thread and event loop as the host process. Synchronous CPU-bound code in the sandbox blocks the entire MCP server, including stdio transport reads and LSP message processing.
- **Relevance**: Spec acknowledges sync infinite loops are uncatchable but understates the blast radius — it's not just "MCP server hangs," it's "LSP connection times out and tsserver may drop the client."
- **Provenance**: llm_generated

### vm_context_prototype_escape
- **Type**: limitation
- **Statement**: `vm.runInNewContext` does not provide true isolation. Sandbox code can escape via prototype chain traversal (e.g., `this.constructor.constructor('return process')()`) unless the context object's prototype chain is explicitly severed.
- **Relevance**: Spec lists what's "not available" in the sandbox (fetch, fs, process) but doesn't mention how to enforce this. Simply omitting globals from the context object is insufficient — prototype escapes can recover `process`, `require`, etc.
- **Provenance**: llm_generated

### promise_race_does_not_cancel
- **Type**: limitation
- **Statement**: `Promise.race` does not cancel or abort the losing promise. The timed-out script continues executing (including making LSP calls) until it resolves or the process dies.
- **Relevance**: The spec's timeout mechanism gives the illusion of cancellation. After timeout, the script's pending LSP calls will still fire, potentially mutating buffers after the "timed out" error was returned to the MCP client. The transactional rollback runs, but a late-arriving LSP response could corrupt state.
- **Provenance**: llm_generated

### vm_no_async_hooks
- **Type**: limitation
- **Statement**: Code running inside `vm.runInNewContext` does not participate in Node's `async_hooks` tracking in a straightforward way. Tracing async operations spawned by sandbox code is unreliable.
- **Relevance**: Makes it difficult to implement future observability (which LSP calls a script made, how long each took) without explicit instrumentation in the `lsp.*` wrapper functions.
- **Provenance**: llm_generated

### settimeout_removed_breaks_async_patterns
- **Type**: implies
- **Statement**: Removing `setTimeout`/`setInterval` from the sandbox also removes the ability to use common debounce/retry patterns. Any retry logic the LLM writes (`await new Promise(r => setTimeout(r, 100))`) will throw a ReferenceError at runtime.
- **Relevance**: Spec removes timers for safety but doesn't provide an alternative. LLMs frequently write `setTimeout`-based retry loops. The error message needs to guide toward the correct pattern (just re-call the `lsp.*` function).
- **Provenance**: llm_generated

## LSP Protocol

### stdio_transport_is_one_to_one
- **Type**: limitation
- **Statement**: stdio transport is 1:1 — one server process per client connection. There is no multiplexing. If two MCP server instances try to share one tsserver process, message framing will corrupt.
- **Relevance**: If the MCP server is spawned multiple times (e.g., multiple Claude Desktop windows), each gets its own tsserver. This is correct but means memory scales linearly with instances.
- **Provenance**: llm_generated

### tsserver_wraps_typescript_language_server
- **Type**: requires
- **Statement**: `typescript-language-server` wraps `tsserver` (TypeScript's own language service). Crashes in tsserver kill the language server. OOM in tsserver (large projects) is the most common crash mode, not bugs in `typescript-language-server` itself.
- **Relevance**: Crash recovery (Risk 5 in spec) should anticipate OOM as the primary failure — tsserver on a 500-file project can use 1-2GB RAM. The spec doesn't mention memory limits or monitoring.
- **Provenance**: llm_generated

### lsp_rename_may_return_edits_to_unopened_files
- **Type**: implies
- **Statement**: `textDocument/rename` may return a `WorkspaceEdit` containing edits to files the client has never opened via `didOpen`. The client must open these files before applying edits.
- **Relevance**: Spec's rename fan-out section handles this correctly (step 2: "didOpen if not already open"), but note that the tsserver may not have full type information for unopened files, so rename results could be incomplete if the project isn't fully indexed.
- **Provenance**: llm_generated

### incremental_sync_requires_version_tracking
- **Type**: requires
- **Statement**: Incremental `textDocumentSync` (mode 2) requires the client to send monotonically increasing version numbers with each `didChange`. Sending the same version twice or going backwards causes undefined behavior in most language servers — tsserver silently drops the update.
- **Relevance**: The rollback mechanism sends `didChange` back to original content. The version number must still increment even though the content is reverting. Spec mentions this ("version still increments") but it's a subtle, critical invariant.
- **Provenance**: llm_generated

### did_close_then_did_open_race
- **Type**: limitation
- **Statement**: Rapid `didClose` followed by `didOpen` for the same URI can cause tsserver to process them out of order or lose state. tsserver's internal file watcher may re-read from disk between close and open, seeing stale content.
- **Relevance**: Spec correctly chose `didChange` for rollback instead of `didClose`+`didOpen`. This rule documents why — validates that design decision.
- **Provenance**: llm_generated

### publish_diagnostics_is_push_only
- **Type**: limitation
- **Statement**: There is no LSP request to pull diagnostics on demand. `textDocument/publishDiagnostics` is a server-to-client notification pushed whenever the server finishes analysis. The client cannot ask "give me diagnostics for this file right now."
- **Relevance**: The 2-second wait after `didChange` is a heuristic. For complex type changes (generic inference chains, conditional types), tsserver may take 5-10 seconds. There's no way to know if diagnostics are "done" without a quiescent signal, which tsserver doesn't provide per-file.
- **Provenance**: llm_generated

### workspace_symbol_is_fuzzy
- **Type**: limitation
- **Statement**: `workspace/symbol` performs fuzzy matching, not exact matching. Searching for "Config" may return "ConfigManager", "AppConfiguration", "configureRoutes", etc. Results are ranked by relevance but the ranking varies between language servers.
- **Relevance**: `lsp.findSymbol(query)` may return unexpected results. The spec doesn't mention whether this is exact or fuzzy, or how results are filtered/limited. LLMs may assume exact match semantics.
- **Provenance**: llm_generated

### prepare_rename_can_reject
- **Type**: limitation
- **Statement**: `textDocument/prepareRename` can return an error indicating the symbol at the given position cannot be renamed (e.g., built-in types, imported names from node_modules). The rename must be aborted gracefully.
- **Relevance**: Spec lists `prepareRename` in the capabilities table but doesn't discuss handling rejection. An LLM trying to rename `Promise` or `Array` should get a clear error, not a crash.
- **Provenance**: llm_generated

### document_symbol_returns_ranges_not_content
- **Type**: limitation
- **Statement**: `textDocument/documentSymbol` returns symbol names, kinds, and ranges (line/column spans) but NOT the source text. Getting the actual code of a symbol requires reading the file content and extracting by range.
- **Relevance**: `lsp.getSymbolBody` must combine `documentSymbol` (for the range) with the buffered file content (for the text). This is an internal implementation detail but means getSymbolBody is a composite operation that can fail if ranges are stale.
- **Provenance**: llm_generated

## TypeScript / tsserver Specifics

### tsserver_indexing_is_lazy
- **Type**: limitation
- **Statement**: tsserver does not eagerly index the entire project on startup. It indexes files as they are opened or referenced. `experimental/serverStatus { quiescent: true }` signals the initial project load is done, but full cross-file reference data may not be available until relevant files are touched.
- **Relevance**: The 3-second fallback timeout after `initialized` may be too short for large projects. More importantly, `findReferences` after cold start may miss references in files that tsserver hasn't loaded yet, even after quiescent.
- **Provenance**: llm_generated

### tsserver_memory_grows_with_open_files
- **Type**: limitation
- **Statement**: Each `didOpen` file consumes memory in tsserver's project graph. Opening 100+ files in a single script (e.g., a bulk rename that touches many files) can push tsserver to 2GB+ and trigger OOM or severe GC pauses.
- **Relevance**: No file count limit is mentioned in the spec. A rename in a widely-used utility could open hundreds of files. Need either an LRU eviction strategy or a hard limit with a clear error.
- **Provenance**: llm_generated

### tsserver_position_encoding
- **Type**: requires
- **Statement**: tsserver uses UTF-16 offset encoding for character positions (matching the LSP spec default). JavaScript string indexing uses UTF-16 code units, so `string.length` matches LSP positions for BMP characters, but supplementary plane characters (emoji, CJK extensions) require careful handling.
- **Relevance**: Symbol path resolution converts between LSP positions and buffer content. If `getSymbolBody` extracts text using string slicing and the file contains emoji in comments, ranges will be off.
- **Provenance**: llm_generated

### tsserver_project_references_complicate_symbols
- **Type**: limitation
- **Statement**: In monorepo setups with TypeScript project references (`references` in tsconfig.json), tsserver may return symbols from declaration files (`.d.ts`) rather than the source (`.ts`) files. `goToDefinition` jumps to the `.d.ts`, not the implementation.
- **Relevance**: `lsp.goToDefinition` may return locations in `node_modules` or `dist/` rather than source. LLMs working with monorepos will be confused by this. May need `textDocument/implementation` (deferred to v2) to get the real source.
- **Provenance**: llm_generated

### auto_import_not_available
- **Type**: implies
- **Statement**: Without `textDocument/codeAction` (deferred to v2), there is no programmatic way to add missing imports. If a script replaces a symbol body with code that references a new type, the diagnostics will report "Cannot find name 'X'" but the script cannot auto-fix it.
- **Relevance**: The write-then-check loop can detect the problem but cannot resolve it within the same operation. The LLM must manually construct the import statement and use `writeFile` or a second script to add it. This is a significant ergonomic gap for refactoring workflows.
- **Provenance**: llm_generated

## Bun / Node Compatibility

### bun_vm_module_divergence
- **Type**: limitation
- **Statement**: Bun's `vm` module is a compatibility shim, not a 1:1 reimplementation of Node's `vm`. Differences include: `vm.runInNewContext` error stack traces may differ, `vm.Script` caching behavior differs, and `vm.createContext` may not fully isolate Symbol.
- **Relevance**: Spec says "Bun (primary), Node-compatible" but `vm` is the core execution mechanism. Subtle behavioral differences in the sandbox between Bun and Node could cause scripts to work on one runtime and fail on the other. Needs integration tests on both.
- **Provenance**: llm_generated

### bun_stdio_buffering
- **Type**: limitation
- **Statement**: Bun's stdio handling buffers differently from Node's. When using stdio for both MCP transport (JSON-RPC to the MCP client) and LSP transport (JSON-RPC to tsserver), buffer flushing behavior matters. Bun may batch small writes differently.
- **Relevance**: Both MCP and LSP use stdio-based JSON-RPC. If Bun batches a partial JSON-RPC message, the receiving end may stall waiting for the Content-Length header's worth of bytes. This is more likely under load (many rapid LSP calls).
- **Provenance**: llm_generated

### bun_spawn_vs_node_spawn
- **Type**: limitation
- **Statement**: Bun's `child_process.spawn` has subtle differences from Node's, particularly around stdio pipe setup and signal handling. `SIGTERM` behavior and graceful shutdown of the spawned tsserver may differ.
- **Relevance**: `lsp-client.ts` spawns tsserver as a child process. Crash recovery relies on detecting the child process death and respawning. Different signal semantics between Bun and Node could affect recovery reliability.
- **Provenance**: llm_generated

## Transactional Semantics

### atomic_flush_is_not_truly_atomic
- **Type**: limitation
- **Statement**: Writing multiple files to disk sequentially is not atomic. There is no OS-level multi-file atomic write. If the process is killed mid-flush (SIGKILL, OOM), some files will be written and others won't.
- **Relevance**: Spec says "flush all dirty buffers to disk atomically" but this is aspirational, not actual. True atomicity would require writing to temp files and then renaming (rename is atomic on most filesystems). The spec doesn't describe this strategy.
- **Provenance**: llm_generated

### rollback_does_not_undo_disk_writes_on_partial_flush
- **Type**: limitation
- **Statement**: If flush fails partway through (3 of 5 files written), the spec says to roll back LSP state for all files. But the 3 files already written to disk are now in a modified state. The rollback only restores LSP's view — disk is inconsistent.
- **Relevance**: Spec mentions "report which files were/weren't written" but doesn't address restoring the already-written files to their originals. The user's working directory is in a partial state that doesn't match LSP's rolled-back view.
- **Provenance**: llm_generated

### concurrent_external_edits_invalidate_originals
- **Type**: limitation
- **Statement**: If a user (or another tool) modifies a file on disk while a script has it buffered, the stored "original content" for rollback is stale. Rolling back would overwrite the external edit.
- **Relevance**: The transactional model assumes exclusive access to the files being edited. In an agentic workflow where multiple tools operate concurrently (e.g., shell tool + codemode), this assumption breaks. No file locking is described.
- **Provenance**: llm_generated

### didchange_rollback_triggers_reanalysis
- **Type**: implies
- **Statement**: Sending `didChange` with original content on rollback triggers a full re-analysis by tsserver for each rolled-back file. Rolling back 20 files means 20 re-analysis cycles, which can take seconds and generate a storm of `publishDiagnostics` notifications.
- **Relevance**: The async mutex serializes `execute` calls, so the next script must wait for the previous rollback's re-analysis to complete. Otherwise, the next script reads stale diagnostics from the map.
- **Provenance**: llm_generated

## MCP Protocol

### mcp_stdio_shares_stdout_with_lsp
- **Type**: incompatible
- **Statement**: If both MCP transport (server-to-client) and LSP transport (server-to-tsserver) use stdio, they cannot share the same stdout/stdin. The MCP server's stdout sends JSON-RPC to the MCP client; the LSP client's stdin/stdout communicates with tsserver via the child process's piped stdio. These are separate pipes.
- **Relevance**: Not actually a conflict since tsserver is a child process with its own piped stdio, but `console.log` in the MCP server process would corrupt the MCP JSON-RPC stream. The sandbox captures `console.log` to an array — this is critical, not just convenient.
- **Provenance**: llm_generated

### mcp_tool_result_size_limits
- **Type**: limitation
- **Statement**: MCP clients may impose limits on tool result size. Claude Desktop truncates tool results beyond ~100KB. A script that returns the content of many files or a large `findReferences` result may be silently truncated.
- **Relevance**: No result size limit or pagination is mentioned in the spec. An LLM script like `lsp.readFile("large-generated-file.ts")` could exceed client limits. Need either explicit size limits or a way to paginate results.
- **Provenance**: llm_generated

### mcp_no_streaming_tool_results
- **Type**: limitation
- **Statement**: MCP's `tools/call` returns a single result. There is no streaming of partial results. The entire script must complete (or timeout) before any output reaches the MCP client.
- **Relevance**: For long-running scripts (multiple rename operations, large batch refactoring), the calling LLM gets no progress feedback. Combined with the 30-second timeout, this means scripts must be fast or they fail opaquely.
- **Provenance**: llm_generated

## Code Normalization & Execution

### acorn_parser_version_sensitivity
- **Type**: limitation
- **Statement**: Acorn parses JavaScript, not TypeScript. If the LLM writes TypeScript syntax in the script (type annotations, `as` casts, angle-bracket generics), acorn will throw a parse error. A separate TypeScript-aware parser or transpiler would be needed to support TS syntax.
- **Relevance**: Spec says "Accepts JavaScript code as a string" but the tool description includes TypeScript type definitions. LLMs may try to use TypeScript syntax in scripts, especially type assertions. The normalization step will fail with a confusing acorn parse error.
- **Provenance**: llm_generated

### implicit_return_ambiguity
- **Type**: limitation
- **Statement**: Auto-returning the last expression is ambiguous when the last statement is an assignment (`const x = await lsp.getSymbols("a.ts")`). An assignment is a statement, not an expression — it should not be auto-returned. The normalizer must distinguish `x;` (expression statement, return x) from `const x = ...;` (declaration, don't return).
- **Relevance**: If the normalizer gets this wrong, the LLM sees `undefined` as the result and may think the operation failed. The spec mentions "last expression is the return value" but doesn't address this edge case.
- **Provenance**: llm_generated

### console_log_capture_ordering
- **Type**: limitation
- **Statement**: `console.log` captured inside the vm sandbox and returned alongside the result will interleave with async operations unpredictably. If a script logs before and after an `await`, the log array order is correct, but if it uses `Promise.all`, log ordering depends on resolution order.
- **Relevance**: LLMs use `console.log` for debugging their own scripts. If log ordering doesn't match execution intuition, debugging becomes harder. Minor but worth knowing.
- **Provenance**: llm_generated

## Concurrency & Mutex

### mutex_starvation_under_rapid_calls
- **Type**: limitation
- **Statement**: The simple async mutex (`let pending = Promise.resolve(); function serialize(fn) { ... }`) has no queue depth limit or backpressure. If an MCP client fires 50 rapid `execute` calls, they all queue up. The 30-second timeout applies per-call, so the 50th call may wait 49 * timeout before even starting.
- **Relevance**: Agentic workflows may issue many calls in sequence. Without queue depth limits, the server degrades silently. Need either a max queue depth with rejection or at least logging when queue depth exceeds a threshold.
- **Provenance**: llm_generated

### mutex_catch_all_error_handling
- **Type**: limitation
- **Statement**: The mutex pattern `pending.then(fn, fn)` calls `fn` regardless of whether the previous operation succeeded or failed. This is correct for serialization but means the mutex never "breaks" — even if every call fails, the next one still runs. There's no circuit breaker.
- **Relevance**: If tsserver crashes and crash recovery also fails, every queued call will attempt execution, fail, attempt crash recovery, fail again. Could amplify a transient failure into a cascade.
- **Provenance**: llm_generated

## Symbol Path Resolution

### overloaded_methods_index_instability
- **Type**: limitation
- **Statement**: The `[N]` index for overloaded symbols is based on declaration order in the source file. If a script adds or removes an overload, the indices shift. A subsequent script using the old index will target the wrong overload.
- **Relevance**: Within a single script this is manageable (indices don't change mid-script since documentSymbol is queried once). Across scripts, the LLM must re-query symbols after any edit that changes overloads. No caching invalidation mechanism is described.
- **Provenance**: llm_generated

### symbol_path_does_not_cover_all_constructs
- **Type**: limitation
- **Statement**: `textDocument/documentSymbol` does not report all code constructs. Standalone statements, top-level `if` blocks, `try/catch` blocks, and IIFE patterns don't produce symbols. Only declarations (functions, classes, variables, interfaces, enums, type aliases) appear.
- **Relevance**: `lsp.getSymbolBody` cannot target arbitrary code regions. If an LLM needs to modify a top-level `if` block or a `try/catch` wrapper, it must fall back to `readFile` + string manipulation + `writeFile`. This limitation isn't documented in the spec's API surface.
- **Provenance**: llm_generated
