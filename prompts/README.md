# Pipeline Design: Micro-Agent Claim Tagging

## The Problem

Large agent sessions drift. An agent tagging 285 claims forgets what vocabulary it used by claim 50. A separate agent generating domain rules has no shared memory with the annotation agent. Result: 278 out of 322 property names end up orphaned — Prolog can't connect them to anything.

## The Solution: One Claim, One Agent

Small sessions. Each agent gets one job and a shared vocabulary list.

### Claim tagging

```
Agent 1: "Here's claim c37. Here's the vocabulary list. Tag it."
Agent 2: "Here's claim c38. Here's the vocabulary list. Tag it."
...
Agent 285: "Here's claim c285. Here's the vocabulary list. Tag it."
```

Each agent gets the same vocabulary list, tags ONE claim, done. No drift. No context window fatigue. The vocabulary list is the shared coordination mechanism — every agent reads from it, and if a concept isn't on the list they propose a new term that gets added for subsequent agents.

### Domain rules

Same pattern — instead of "generate 55 domain rules for this spec," it's:

```
Agent 1: "Here's property vm_sandbox. What does it require/imply/conflict with? Here's the vocabulary."
Agent 2: "Here's property transactional_writes. Same question, same vocabulary."
```

### Why this works

- Each agent makes ONE decision — almost impossible to mess up
- Shared vocabulary list prevents synonym drift
- The vocabulary grows as agents propose new terms — each subsequent agent sees the latest version
- Like a shared blackboard

### The tradeoff

Coordination overhead. 285 agent spawns is a lot of API calls. But each one is tiny and focused.

### Architecture

```
1. Extract claims from spec (one agent, produces numbered list)
2. Seed vocabulary (one agent, reads claims, proposes initial ~50 terms)
3. Tag claims (one micro-agent per claim, reads vocabulary, proposes additions)
4. Generate domain rules (one micro-agent per property, reads vocabulary)
5. Load into Prolog (lib/contradiction-engine.pl does the reasoning)
```

Steps 3 and 4 are massively parallel — limited only by API rate limits.
Prolog does the combinatorial search. LLMs just tag.
