# codemode-vision — Claim Decomposition

Source: `codemode-vision.md`

## Core Thesis

- **C1**: The system is an MCP server [architectural]
- **C2**: The MCP server exposes a single `execute` tool [architectural]
- **C3**: The `execute` tool is backed by LSP [architectural]
- **C4**: The LLM writes JavaScript that chains semantic code operations [architectural]
- **C5**: Code is executed in a vm sandbox [architectural]
- **C6**: Execution has transactional semantics [architectural]
- **C7**: LLMs are better at writing code than orchestrating tool calls [opinion]

## What This Is NOT

- **C8**: Serena is a multi-tool MCP server [source_verifiable]
- **C9**: Serena supports 30+ languages [source_verifiable]
- **C10**: codemode is a focused code-execution runtime with LSP primitives [architectural]
- **C11**: codemode is optimized for batch semantic operations on TypeScript codebases [architectural]
- **C12**: Cloudflare's codemode wraps arbitrary tools into code execution [source_verifiable]
- **C13**: codemode exposes a curated, domain-specific `lsp.*` API [architectural]
- **C14**: The `lsp.*` API has concrete types [architectural]
- **C15**: The `lsp.*` API has rich error messages [architectural]
- **C16**: The `lsp.*` API has transactional writes [architectural]
- **C17**: The system provides no completion features [architectural]
- **C18**: The system provides no hover tooltips [architectural]
- **C19**: The system provides no interactive features [architectural]
- **C20**: The system is a headless tool for programmatic code manipulation [architectural]

## Primary User

- **C21**: The primary user is agentic workflows where a calling LLM writes scripts [architectural]
- **C22**: The MCP client (Claude, GPT, etc.) is the user [architectural]
- **C23**: Humans set up the server [architectural]
- **C24**: The LLM writes the scripts [architectural]
- **C25**: Secondary users are power users running complex refactoring via MCP clients [architectural]

## The Exploration Question

- **C26**: The `execute` tool supports both batch operations and exploration patterns [architectural]
- **C27**: Exploratory scripts are small [architectural]
- **C28**: The LLM makes multiple small `execute` calls for exploration [architectural]
- **C29**: The LLM makes larger scripts for actual operations [architectural]
- **C30**: Even exploratory calls can compose operations in one call [architectural]

## Runtime & Transport

- **C31**: The primary runtime is Bun [architectural]
- **C32**: The code is Node-compatible [architectural]
- **C33**: No Bun-specific APIs are used [architectural]
- **C34**: The MCP SDK used is `@modelcontextprotocol/sdk` [source_verifiable]
- **C35**: MCP transport is stdio [architectural]
- **C36**: LSP transport uses `vscode-jsonrpc` for JSON-RPC framing [source_verifiable]
- **C37**: LSP transport uses `vscode-languageserver-protocol` for LSP types [source_verifiable]
- **C38**: JSON-RPC is not built from scratch [architectural]
- **C39**: The sandbox uses `vm.runInNewContext` [architectural]
- **C40**: Timeout is implemented with `Promise.race` [architectural]
- **C41**: Bun has faster startup than Node [empirical]
- **C42**: Bun has native TypeScript execution (no build step for development) [source_verifiable]
- **C43**: Bun has good `vm` module support [empirical]
- **C44**: The package manager is Bun [architectural]

## The `execute` Tool

- **C45**: There is a single MCP tool [architectural]
- **C46**: The tool accepts JavaScript code as a string [architectural]
- **C47**: Code runs in a vm sandbox [architectural]
- **C48**: `lsp.*` primitives are available in the sandbox [architectural]
- **C49**: The tool returns the result of execution [architectural]
- **C50**: The tool description includes TypeScript type definitions for the `lsp.*` API [architectural]
- **C51**: Type definitions are auto-generated [architectural]
- **C52**: Type definitions are approximately 1,000-1,200 tokens [architectural]
- **C53**: The tool description includes 3+ worked examples [architectural]
- **C54**: The tool description includes explicit warnings about common LLM footguns [architectural]

## Code Normalization

- **C55**: The system adopts Cloudflare's `normalizeCode()` pattern [architectural]
- **C56**: The system accepts bare statements as code format [architectural]
- **C57**: The system accepts async arrow functions as code format [architectural]
- **C58**: The system accepts scripts with implicit return (last expression) [architectural]
- **C59**: Lightweight AST parsing is used to detect the format [architectural]
- **C60**: The AST parser is acorn [architectural]
- **C61**: If the last statement is an expression, it is auto-returned [architectural]
- **C62**: If the last expression is a Promise, it is auto-awaited [architectural]

## Timeout

- **C63**: Timeout is mandatory [architectural]
- **C64**: Execution is wrapped in `Promise.race` [architectural]
- **C65**: The default timeout is 30 seconds [architectural]
- **C66**: The timeout is configurable [architectural]
- **C67**: The timeout catches hanging LSP requests [architectural]
- **C68**: The timeout catches LLM-written `await` chains that never resolve [architectural]
- **C69**: The timeout catches infinite async loops [architectural]
- **C70**: The timeout does NOT catch synchronous infinite loops [architectural]
- **C71**: Not catching sync infinite loops is an accepted risk for v1 [architectural]
- **C72**: LLMs rarely write synchronous infinite loops [empirical]
- **C73**: The fix for sync infinite loops is `worker_threads`, deferred to v2 [architectural]

## Concurrency

- **C74**: All `execute` calls are serialized with an async mutex [architectural]
- **C75**: Concurrent scripts would corrupt shared LSP state [architectural]
- **C76**: Position offsets are invalidated by concurrent edits [architectural]
- **C77**: Scripts are typically sub-second in execution time [empirical]
- **C78**: Serialization is not a bottleneck [architectural]

## LSP Primitives — Read Operations

- **C79**: There are 8 read operations [architectural]
- **C80**: `lsp.readFile(file)` reads file contents as raw string without line numbers [architectural]
- **C81**: `lsp.getSymbolBody(file, symbolPath)` reads source code of a specific symbol [architectural]
- **C82**: `lsp.getSymbols(file)` returns the document symbol tree [architectural]
- **C83**: `lsp.getSymbols(file)` returns `SymbolInfo[]` [architectural]
- **C84**: `lsp.findSymbol(query)` does workspace-wide symbol search [architectural]
- **C85**: `lsp.findReferences(file, symbolPath)` returns all references to a symbol [architectural]
- **C86**: `lsp.findReferences` returns `Reference[]` [architectural]
- **C87**: `lsp.goToDefinition(file, symbolPath)` jumps to definition [architectural]
- **C88**: `lsp.goToDefinition` returns `Location` [architectural]
- **C89**: `lsp.searchText(pattern, glob?)` does regex search across files [architectural]
- **C90**: `lsp.searchText` is not LSP-based — it is a direct file search [architectural]
- **C91**: `lsp.searchText` returns `SearchResult[]` [architectural]
- **C92**: `lsp.listFiles(glob?)` discovers project files matching a glob [architectural]
- **C93**: `lsp.listFiles` returns `string[]` [architectural]

## LSP Primitives — Write Operations

- **C94**: There are 6 write operations [architectural]
- **C95**: `lsp.renameSymbol(file, symbolPath, newName)` performs LSP rename across codebase [architectural]
- **C96**: `lsp.replaceSymbolBody(file, symbolPath, newText)` replaces a symbol's full declaration [architectural]
- **C97**: `lsp.insertBeforeSymbol(file, symbolPath, text)` inserts code before a symbol [architectural]
- **C98**: `lsp.insertAfterSymbol(file, symbolPath, text)` inserts code after a symbol [architectural]
- **C99**: `lsp.deleteSymbol(file, symbolPath)` removes a symbol including decorators and JSDoc [architectural]
- **C100**: `lsp.writeFile(file, content)` creates or overwrites a file [architectural]
- **C101**: `lsp.writeFile` is an escape hatch for non-symbol edits [architectural]
- **C102**: All write operations return `WriteResult` [architectural]

## LSP Primitives — Diagnostics

- **C103**: There is 1 diagnostics operation [architectural]
- **C104**: `lsp.getDiagnostics(file?)` gets current diagnostics [architectural]
- **C105**: `lsp.getDiagnostics` returns `Diagnostic[]` [architectural]
- **C106**: The total number of `lsp.*` functions is 15 [architectural]

## Design Decision: readFile Returns Raw Content

- **C107**: `readFile` returns raw content, not line-numbered content [architectural]
- **C108**: Line numbers embedded in content break string manipulation [architectural]
- **C109**: `SymbolInfo` has `startLine` and `endLine` fields [architectural]
- **C110**: `Reference` has a `line` field [architectural]
- **C111**: `Diagnostic` has a `range` field [architectural]

## Design Decision: Write Operations Auto-Return Diagnostics

- **C112**: Write operations auto-return diagnostics [architectural]
- **C113**: `WriteResult` contains a `file` field (string) [architectural]
- **C114**: `WriteResult` contains a `filesChanged` field (string array) [architectural]
- **C115**: `WriteResult` contains a `diagnostics` field (Diagnostic array) [architectural]
- **C116**: Diagnostics in `WriteResult` are collected after a brief wait for LSP to process [architectural]

## Design Decision: getDiagnostics Implementation

- **C117**: LSP diagnostics are push-based via `textDocument/publishDiagnostics` notification [source_verifiable]
- **C118**: LSP diagnostics are not request-response [source_verifiable]
- **C119**: A notification handler stores diagnostics per-URI in a `Map<string, Diagnostic[]>` [architectural]
- **C120**: After each `didChange`, the system waits for the next `publishDiagnostics` for that URI [architectural]
- **C121**: The diagnostics wait timeout is 2 seconds [architectural]
- **C122**: `getDiagnostics(file)` reads from the stored map [architectural]
- **C123**: Auto-return in `WriteResult` waits for the push notification with the same 2s timeout [architectural]

## Type Definitions — SymbolInfo

- **C124**: `SymbolInfo.name` is a string [architectural]
- **C125**: `SymbolInfo.path` is a slash-separated path for use in other `lsp.*` calls [architectural]
- **C126**: `SymbolInfo.kind` is a string with values like "class", "function", "variable", "method", "property" [architectural]
- **C127**: `SymbolInfo.exported` is a boolean [architectural]
- **C128**: `SymbolInfo.startLine` is a number [architectural]
- **C129**: `SymbolInfo.endLine` is a number [architectural]
- **C130**: `SymbolInfo.signature` is an optional one-line signature [architectural]
- **C131**: `SymbolInfo.children` is an optional `SymbolInfo[]` [architectural]
- **C132**: `path` is the reusable handle that eliminates symbol path guessing [architectural]
- **C133**: `getSymbols` returns the `path` field [architectural]
- **C134**: Every other function that takes a symbol path accepts the `path` field [architectural]

## Type Definitions — Reference

- **C135**: `Reference.file` is a string [architectural]
- **C136**: `Reference.line` is a number [architectural]
- **C137**: `Reference.column` is a number [architectural]
- **C138**: `Reference.context` is a string containing the actual line of code with the reference [architectural]
- **C139**: `Reference.symbolPath` is the path of the containing symbol, reusable in other calls [architectural]
- **C140**: `Reference.isWriteAccess` is a boolean distinguishing assignments from reads [architectural]
- **C141**: `context` enables in-script filtering without `readFile` [architectural]

## Type Definitions — Diagnostic

- **C142**: `Diagnostic.file` is a string [architectural]
- **C143**: `Diagnostic.range` has `start` and `end` with `line` and `character` fields (all numbers) [architectural]
- **C144**: `Diagnostic.message` is a string [architectural]
- **C145**: `Diagnostic.severity` is one of "error", "warning", "info", "hint" [architectural]

## Type Definitions — Location

- **C146**: `Location.file` is a string [architectural]
- **C147**: `Location.line` is a number [architectural]
- **C148**: `Location.column` is a number [architectural]
- **C149**: `Location.symbolPath` is an optional string (present if the definition lands inside a known symbol) [architectural]

## Type Definitions — SearchResult

- **C150**: `SearchResult.file` is a string [architectural]
- **C151**: `SearchResult.line` is a number [architectural]
- **C152**: `SearchResult.column` is a number [architectural]
- **C153**: `SearchResult.match` is a string containing the matched text [architectural]
- **C154**: `SearchResult.context` is a string containing the full line with the match [architectural]

## Type Definitions — WriteResult

- **C155**: `WriteResult.file` is a string [architectural]
- **C156**: `WriteResult.filesChanged` is a string array [architectural]
- **C157**: `WriteResult.diagnostics` is a `Diagnostic[]` [architectural]

## Symbol Path Resolution

- **C158**: Symbol paths are slash-separated [architectural]
- **C159**: Symbol paths support unlimited nesting depth [architectural]
- **C160**: Symbol path resolution walks the `textDocument/documentSymbol` tree [source_verifiable]
- **C161**: Arrow functions use their variable name as the symbol path [architectural]

## Symbol Path — Dot Alias

- **C162**: The system accepts `.` as a separator in symbol paths [architectural]
- **C163**: Dot separators are normalized to `/` internally [architectural]
- **C164**: LLMs frequently write `MyClass.myMethod` from training data patterns [empirical]

## Symbol Path — Overload Index

- **C165**: The system supports `[N]` suffix for overloaded symbols [architectural]
- **C166**: Overload indexing is required for TypeScript constructors and method overloads [source_verifiable]

## Symbol Path — Error Messages

- **C167**: Error messages target LLMs, not humans [architectural]
- **C168**: When a symbol path doesn't resolve, the error lists available top-level symbols [architectural]
- **C169**: When a symbol path doesn't resolve, the error lists children of the closest match [architectural]
- **C170**: The LLM can self-correct from these error messages in the next script [architectural]

## Symbol Path — Ambiguity

- **C171**: If a bare name matches multiple symbols, the system returns candidates [architectural]
- **C172**: Each candidate includes file path, symbol kind, and export status [architectural]
- **C173**: The user disambiguates by providing the full file path [architectural]

## Transactional Writes — Buffer Strategy

- **C174**: On first access to a file, `didOpen` is sent with disk content [architectural]
- **C175**: Original content is stored on first access [architectural]
- **C176**: Write operations update the in-memory buffer [architectural]
- **C177**: Write operations send `didChange` to LSP [architectural]
- **C178**: `didChange` is incremental or full depending on server capability [source_verifiable]
- **C179**: All reads within the same script go through the LSP (buffered state), never from disk [architectural]
- **C180**: On successful script completion, all dirty buffers are flushed to disk atomically [architectural]
- **C181**: On script failure (throw), dirty files are changed back to their stored originals via `didChange` [architectural]
- **C182**: On script failure, disk is untouched [architectural]

## Transactional Writes — Rollback Mechanism

- **C183**: Rollback uses `didChange` back to original content [architectural]
- **C184**: Rollback does NOT use `didClose`+`didOpen` [architectural]
- **C185**: Rapid close/open cycles can leave tsserver with stale state [empirical]
- **C186**: `didChange` back to original is cleaner and more reliable than close/open [architectural]

## Transactional Writes — Rename Fan-Out

- **C187**: `renameSymbol` calls `textDocument/rename` which returns a `WorkspaceEdit` [source_verifiable]
- **C188**: A `WorkspaceEdit` can touch many files [source_verifiable]
- **C189**: For each affected file not already open, `didOpen` is sent and original content buffered [architectural]
- **C190**: All edits are applied to in-memory buffers [architectural]
- **C191**: `didChange` is sent for each affected file [architectural]
- **C192**: All affected files join the dirty set for flush/rollback [architectural]

## Transactional Writes — Partial Flush Failure

- **C193**: If flushing to disk fails mid-way, the system reports which files were and weren't written [architectural]
- **C194**: On partial flush failure, LSP state is rolled back for all files (including successfully written ones) [architectural]
- **C195**: On partial flush failure, a clear error is returned [architectural]

## Sandbox — Available in VM Context

- **C196**: All 15 `lsp.*` primitives are available in the vm context [architectural]
- **C197**: JS builtins are available: Math, JSON, Array, Object, Map, Set, Promise, String, Number, Date, RegExp, Error [architectural]
- **C198**: `console.log`, `console.warn`, `console.error` are captured to a logs array [architectural]
- **C199**: The logs array is returned alongside the script result [architectural]
- **C200**: `path.join`, `path.basename`, `path.dirname`, `path.extname` are available [architectural]

## Sandbox — Not Available

- **C201**: No `fetch` or network access in the sandbox [architectural]
- **C202**: No `fs`, `require`, or `import` in the sandbox [architectural]
- **C203**: File reading goes through `lsp.readFile()` [architectural]
- **C204**: No `setTimeout` or `setInterval` in the sandbox [architectural]
- **C205**: Timing is handled by the runtime, not the script [architectural]
- **C206**: No `process`, `Bun`, `Deno`, or other runtime globals in the sandbox [architectural]

## Tool Description

- **C207**: The `execute` tool description is optimized for correct code generation, not human reading [architectural]
- **C208**: The tool description starts with a one-line purpose statement [architectural]
- **C209**: The one-line purpose is "Execute JavaScript to perform semantic code operations via LSP." [architectural]
- **C210**: The tool description includes auto-generated type definitions from `lsp-api.ts` [architectural]
- **C211**: The type definitions are approximately 1,000 tokens [architectural]
- **C212**: The tool description includes a minimum of 3 worked examples [architectural]
- **C213**: The worked examples show exploration, batch refactoring, and write-then-check patterns [architectural]
- **C214**: The tool description warns that Array `.filter()` and `.map()` callbacks cannot be async [architectural]
- **C215**: The tool description warns to use `for...of` with await instead of async filter/map [architectural]
- **C216**: The tool description warns that symbol paths use `/` separator [architectural]
- **C217**: The tool description warns to use `getSymbols()` to discover exact paths [architectural]
- **C218**: The tool description warns that the last expression is the return value [architectural]
- **C219**: The tool description warns not to use `return` [architectural]

## Type Generation

- **C220**: Type definitions are generated via `tsc --declaration --emitDeclarationOnly` on `lsp-api.ts` [architectural]
- **C221**: The `.d.ts` output is read and embedded in the tool description [architectural]
- **C222**: Embedding uses a `{{types}}` placeholder [architectural]
- **C223**: `lsp-api.ts` is the single source of truth for types [architectural]

## Language Server (v1)

- **C224**: v1 supports TypeScript only [architectural]
- **C225**: The language server is `typescript-language-server` [architectural]
- **C226**: The language server communicates over stdio [architectural]
- **C227**: The architecture is language-agnostic [architectural]
- **C228**: Adding another language means mapping extensions to the right server [architectural]
- **C229**: v1 focuses on one language done well [architectural]

## Initialization & Warmup

- **C230**: The system spawns `typescript-language-server --stdio` [architectural]
- **C231**: An `initialize` request is sent with workspace root = cwd [source_verifiable]
- **C232**: An `initialized` notification is sent after initialize [source_verifiable]
- **C233**: The system listens for `experimental/serverStatus` notification with `{ quiescent: true }` [source_verifiable]
- **C234**: `quiescent: true` signals the server has finished indexing [source_verifiable]
- **C235**: If no `serverStatus` within 3 seconds of `initialized`, the server is assumed ready [architectural]
- **C236**: A representative file (e.g., `tsconfig.json` or first `.ts` file) is proactively `didOpen`-ed to trigger project loading [architectural]
- **C237**: Warmup happens in the background when the MCP server starts [architectural]
- **C238**: Warmup does not happen on first `execute` call [architectural]

## Document Sync

- **C239**: The client declares `textDocumentSync: 2` (incremental) in client capabilities [source_verifiable]
- **C240**: Per-file state stores URI, content, and version counter [architectural]
- **C241**: On `didChange`, version is incremented and changed ranges are sent [source_verifiable]
- **C242**: On rollback, full content replacement is sent via `didChange` [architectural]
- **C243**: On rollback, version still increments [architectural]

## Diagnostics Collection

- **C244**: A handler is registered for `textDocument/publishDiagnostics` notification [source_verifiable]
- **C245**: Diagnostics are stored in `Map<string, Diagnostic[]>` keyed by file URI [architectural]
- **C246**: After writes that trigger `didChange`, the system waits up to 2s for updated diagnostics [architectural]
- **C247**: `getDiagnostics(file)` reads from the map (instant, no LSP request) [architectural]

## Crash Recovery

- **C248**: If the LSP process dies, all pending LSP requests reject [architectural]
- **C249**: Rejected requests cause the script to fail [architectural]
- **C250**: Script failure triggers transactional rollback [architectural]
- **C251**: On next `execute` call, the dead process is detected [architectural]
- **C252**: A respawn with full init handshake occurs on detection [architectural]
- **C253**: Previously-open documents are not replayed [architectural]
- **C254**: `didOpen` happens naturally as the new script touches files [architectural]
- **C255**: Server health is checked eagerly at script start, not lazily on first LSP call [architectural]

## LSP Capabilities Used

- **C256**: `textDocument/documentSymbol` is used for `getSymbols` and symbol path resolution [source_verifiable]
- **C257**: `textDocument/references` is used for `findReferences` [source_verifiable]
- **C258**: `textDocument/definition` is used for `goToDefinition` [source_verifiable]
- **C259**: `textDocument/rename` is used for `renameSymbol` [source_verifiable]
- **C260**: `textDocument/prepareRename` is used for `renameSymbol` [source_verifiable]
- **C261**: `workspace/symbol` is used for `findSymbol` [source_verifiable]
- **C262**: `textDocument/publishDiagnostics` is used for `getDiagnostics` and auto-diagnostics in `WriteResult` [source_verifiable]
- **C263**: `textDocument/didOpen` is used for file lifecycle [source_verifiable]
- **C264**: `textDocument/didChange` is used for transactional writes [source_verifiable]
- **C265**: `textDocument/didClose` is used for file cleanup via LRU eviction [source_verifiable]

## LSP Capabilities NOT Used (v1)

- **C266**: `textDocument/completion` is not used in v1 [architectural]
- **C267**: `textDocument/hover` is not used in v1 [architectural]
- **C268**: `textDocument/codeAction` is not used in v1 [architectural]
- **C269**: `textDocument/implementation` is not used in v1 [architectural]
- **C270**: `textDocument/signatureHelp` is not used in v1 [architectural]
- **C271**: `callHierarchy/*` is not used in v1 [architectural]
- **C272**: `typeHierarchy/*` is not used in v1 [architectural]

## Modules — v1 Module Structure

- **C273**: `src/mcp-server.ts` handles MCP server setup, execute tool registration, and stdio transport [architectural]
- **C274**: `src/lsp-client.ts` handles vscode-jsonrpc connection, tsserver spawn, init handshake, crash recovery, and server health [architectural]
- **C275**: `src/buffer.ts` handles transactional write buffer, per-file content tracking, flush/rollback, and dirty set [architectural]
- **C276**: `src/lsp-api.ts` contains the `lsp.*` API surface wrapping LSP calls and buffer operations [architectural]
- **C277**: `src/sandbox.ts` handles vm context setup, `lsp.*` and `path.*` injection, code normalization, `Promise.race` timeout, and log capture [architectural]
- **C278**: `src/symbol.ts` handles symbol path resolution (slash/dot-separated path to LSP position via document symbols) [architectural]
- **C279**: There is no `lsp-manager.ts` in v1 [architectural]
- **C280**: No manager abstraction is needed because there is a single language server [architectural]
- **C281**: The manager should be extracted when adding a second language [architectural]
- **C282**: `buffer.ts` is split from `lsp-api.ts` [architectural]
- **C283**: The split is because transactional state management is complex enough to warrant its own module and tests [architectural]

## Deferred Features (v2+)

- **C284**: Multi-language support is deferred [architectural]
- **C285**: `textDocument/codeAction` (auto-import, organize imports) is deferred [architectural]
- **C286**: `textDocument/implementation` is deferred [architectural]
- **C287**: `textDocument/hover` (type info) is deferred [architectural]
- **C288**: Shell command execution is out of scope [architectural]
- **C289**: MCP clients have their own shell tools [source_verifiable]
- **C290**: Human approval workflow is deferred [architectural]
- **C291**: Human approval is an MCP-level concern, not a server-level concern [architectural]
- **C292**: Config file is deferred [architectural]
- **C293**: Multi-root workspace is deferred [architectural]
- **C294**: `worker_threads` isolation is deferred [architectural]
- **C295**: `worker_threads` would catch synchronous infinite loops [source_verifiable]
- **C296**: `lsp.checkpoint()` (mid-script flush) is deferred [architectural]
- **C297**: Scripts should be short in v1 [architectural]
- **C298**: Git integration / undo is out of scope [architectural]

## Risk 1: Diagnostics Timing

- **C299**: `WriteResult.diagnostics` may be empty or stale if tsserver hasn't finished processing [empirical]
- **C300**: The mitigation is to wait up to 2s for `publishDiagnostics` after each `didChange` [architectural]
- **C301**: Diagnostics may be incomplete for complex type-level changes [empirical]
- **C302**: `getDiagnostics` is always available for an explicit check [architectural]

## Risk 2: Cold Start Incomplete Results

- **C303**: First `findReferences` or `goToDefinition` may miss results if tsserver hasn't finished indexing [empirical]
- **C304**: Mitigation is warmup during server init [architectural]
- **C305**: The warmup listens for `experimental/serverStatus { quiescent: true }` with 3s fallback [architectural]
- **C306**: Background warmup doesn't block first request [architectural]
- **C307**: First request waits if warmup hasn't completed [architectural]

## Risk 3: LLMs Write Async Filter/Map

- **C308**: Async filter/map callbacks cause silent incorrect behavior [empirical]
- **C309**: No error is thrown for async filter/map [empirical]
- **C310**: Mitigation is an explicit warning in the tool description [architectural]
- **C311**: Runtime detection is considered: if a filter/map callback returns a Promise, log a warning [architectural]

## Risk 4: Large WorkspaceEdit from Rename

- **C312**: Rename can open 20+ files [empirical]
- **C313**: All affected files are buffered in the dirty set [architectural]
- **C314**: Rename is the highest-risk operation [architectural]

## Risk 5: Sync Infinite Loop

- **C315**: A synchronous infinite loop blocks the event loop permanently [source_verifiable]
- **C316**: The MCP server hangs and the client must kill and restart [architectural]
- **C317**: This is an accepted risk for v1 [architectural]
- **C318**: `Promise.race` timeout catches all async hangs [architectural]

## Risk 6: Serena Competition

- **C319**: Serena has the same underlying tech [source_verifiable]
- **C320**: Serena has more features [source_verifiable]
- **C321**: Serena has an established community [source_verifiable]
- **C322**: codemode has fewer moving parts than Serena [architectural]
- **C323**: codemode has transactional semantics, Serena does not [source_verifiable]
- **C324**: codemode is more token-efficient (one tool vs 49) [empirical]
- **C325**: Serena has 49 tools [source_verifiable]

## Success Criteria (v1)

- **C326**: An LLM can discover project structure, understand symbols, and perform multi-file refactoring in a single `execute` call [architectural]
- **C327**: Failed scripts roll back cleanly — disk is never left in a partial state [architectural]
- **C328**: The LLM can self-correct from error messages without human intervention [architectural]
- **C329**: Type definitions in the tool description are sufficient for correct code generation in >90% of cases [empirical]
- **C330**: The server handles typescript-language-server lifecycle (startup, warmup, crash recovery) transparently [architectural]
