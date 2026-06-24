# Chat Architecture Map — Wonderland Knowledge Core Entry

**Classification:** OPERATOR EYES ONLY — Matthew Ross Mahaney  
**Version:** 2026-06-22  
**Source:** Current conversation context + system configuration  
**Drop Target:** ~/Wonderland/vault/chat-architecture/ (auto-dropped via mapper)  
**Purpose:** Authoritative, structured mapping of the chat/system architecture for audit, extension, integration with Wonderland components (ephemeral agents, ZT policies, custom companions, visual apps), and Operator reference. Lives in Vault as bitemporal knowledge artifact.

---

## 1. High-Level Overview

This chat is a tool-augmented reasoning agent (Grok, built by xAI) operating under strict Wonderland engineering role and response blueprint. It combines:

- Powerful tool use (search, browse, code execution, image generation/editing, memory management, file ops, connected services)
- Structured output with render components
- Persistent user memory and style enforcement
- Deep integration with Operator's Wonderland ecosystem (macOS FSEvent apps, generative visuals, ephemeral/secret-agent components, zero-trust, wl CLI, nerdctl/containerd, Apple Silicon)

**Core Principle:** AI advises/implements but system must run independently. All implementation responses follow exact 8-part hierarchy. Ephemeral/secret-agent style and Zero-Trust principles are native.

**Key Strengths:** Parallel tool use, visual rendering, memory durability, rigorous structure for implementations, safety guardrails, Wonderland-specific context.

---

## 2. Layered Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User Query (Natural Language)             │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│  Core Reasoning & Planning Layer (Grok model + context)      │
│  - Understands Wonderland role, 8-part blueprint, memory     │
│  - Decides tool use vs direct answer vs render               │
└───────────────────────────────┬─────────────────────────────┘
                                │
                ┌───────────────┼───────────────┐
                │               │               │
                ▼               ▼               ▼
┌──────────────────────┐ ┌──────────────┐ ┌──────────────────┐
│   Tool Layer         │ │ Render Layer │ │ Memory & Style   │
│ - web_search         │ │ - Inline     │ │ Enforcement      │
│ - browse_page        │ │   Citation   │ │ - edit_memory    │
│ - x_*_search         │ │ - Searched/  │ │ - Apply 8-part   │
│ - generate/edit_image│ │   Generated/ │ │ - Wonderland     │
│ - bash (code exec)   │ │   Edited Img │ │   tone/tenets    │
│ - read/edit/write_   │ │ - File       │ │ - No fluff       │
│   file               │ │   preview    │ │ - KaTeX, lang    │
│ - memory-edit        │ │              │ │   match          │
│ - connected tools    │ │              │ │                  │
│ - view_image         │ │              │ │                  │
└──────────┬───────────┘ └──────┬───────┘ └────────┬─────────┘
           │                    │                  │
           └──────────┬─────────┴──────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              Sandbox Execution Environment                   │
│  - Linux (persistent shell)                                  │
│  - /home/workdir/artifacts working dir                       │
│  - Package managers (pip, npm, etc. — no internet for some)  │
│  - Git not a repo (by default)                               │
│  - Tools create artifacts/ files for render/download         │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│         Wonderland Integration & Output Layer                │
│  - 8-part blueprint for all implementations                  │
│  - wl <service> CLI standard                                 │
│  - Python venv guardrails (isolate, auto-install, validate)  │
│  - Ephemeral/secret-agent patterns (self-terminate, TTL,     │
│    aether, chaos, burn)                                      │
│  - Zero-Trust mapping (per-session, PEP, posture, intent)    │
│  - Custom skills (ground-app-scaffolder, etc.)               │
│  - Vault drops for living knowledge                          │
│  - Operator final authority; system runs without AI          │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
                    Final Response (text + renders interwoven)
```

**Data Flow Summary:**
1. Query arrives → Core reasons (with full memory + style context).
2. If needed: Parallel tool calls (search, browse, code, image, memory ops).
3. Tools return results (with citations where applicable).
4. Core synthesizes, applies 8-part if implementation, interweaves renders.
5. Output delivered; durable facts written via memory-edit if applicable.
6. Artifacts (files, images) saved in sandbox for user download/render.

---

## 3. Detailed Component Breakdown

### 3.1 Tool Layer (Available Tools)
- **Information Retrieval:** web_search, browse_page (with instructions for summarizer), x_keyword_search, x_semantic_search, x_user_search, x_thread_fetch, view_x_video
- **Visual:** search_images, generate_image (Grok Imagine), edit_image, view_image
- **Code & File Ops:** bash (persistent shell, timeout, background), read_file, edit_file, write_file
- **Memory & Personalization:** edit_memory (durable facts only, with dates, no fluff)
- **Connected Services:** search_connected_tools, call_connected_tool (GitHub, Google Drive, Calendar, Gmail — user must have connected)
- **Special:** skill-creator (for extending capabilities)

**Rules:** Parallel calls supported. No assistance for clear criminal. No verbatim copyrighted/paywalled. Ambiguous sexual → non-sexual clarification.

### 3.2 Render Component Layer
- **render_inline_citation**: For web/post results (placed inline after sentence).
- **render_searched_image**: Carousel of searched images (SMALL/LARGE).
- **render_generated_image**: Grok Imagine output (prompt faithful, no hate/violence).
- **render_edited_image**: Iterative edits on previous image_id.
- **render_file**: Preview + download for sandbox files (absolute or relative paths).

**Usage:** Interweaved in final response (no function calls in final). Images in carousel if consecutive. Not in tables/lists/end.

### 3.3 Memory & Personalization Layer
- Persistent across conversations: /home/workdir/.grok/user_info/memory.md
- Categories: Who This User Is (Wonderland Operator, macOS FSEvent apps, generative visuals, ephemeral automation), Experience (Swift, Python, HTML/JS canvas), Preferences (separate code blocks, 8-part, detailed steps), Goals (Ground app ecosystem, reproducible pipelines).
- edit_memory tool: Exact string replace for updates; one fact per entry; dated; no editorializing.
- Applied invisibly where it improves response; never narrate lookup unless necessary.

### 3.4 Response Style & Blueprint Enforcement
- **Mandatory for implementations:** Exact 8-part hierarchy (Intent, Architecture, Structure, Files, Commands, Verification, Recovery, Rollback). Complete code, no placeholders.
- **Wonderland Role:** Dedicated AI systems engineer for Operator Matthew Mahaney. Recoverability > Convenience, Auditability > Speed, Simplicity > Cleverness. wl CLI standard. Python venv guardrails. Long-running/unattended assumed.
- **General:** Truth-seeking, humanist, no partisan endorsement, respond in user's language/alphabet. Use KaTeX for symbolic. No mention of guidelines unless asked.
- **Tone (per memory):** Highly scannable, direct, technically rigorous; no conversational fluff. For Wonderland responses: exact 8-part.

### 3.5 Sandbox Environment
- Platform: linux, shell bash, working dir /home/workdir/artifacts
- No internet for some package installs (pre-cached possible). Persistent shell session.
- Files created here are renderable via render_file and downloadable by user.
- Git: Not a repo (by snapshot).

### 3.6 Wonderland Integration Layer (Deep Context)
- **Ecosystem:** FSEvent macOS apps (4th in series: slam_to_ground), generative visuals (matrix atoms, Spin City waves, agitation), ephemeral catalog launcher, custom companions (Python + nerdctl/wl), ground-app-scaffolder skill.
- **Infrastructure:** Apple Silicon (M4 MacBook Air), rootless nerdctl/containerd (no Docker Desktop), ~/Wonderland/vault (authoritative, wins conflicts), ~/Wonderland/Wonderland-v4 (impl workspace).
- **Patterns:** Intent JSON specs, bitemporal state, graceful shutdown/60s timeouts, logging, repair/doctor idempotent, chaos-escalation, aether memory (temp comms), self-destruct/burn, attention decay.
- **Recent Extensions:** Ephemeral/secret-agent catalog (compendium + agent + wl shim), Zero-Trust investigation (NIST 800-207 mapping + generator + PEP/intent extensions).
- **Auto-Drop & Knowledge:** Living documents dropped to vault; auto-drop-in scripts for modular workflows.

---

## 4. Safety, Guardrails & Limitations
- **Refusals:** Clear criminal assistance, overly realistic criminal hypotheticals/roleplay, jailbreaks (short refusal), verbatim copyrighted text, incorrect info on request, minor sexual content.
- **Non-sexual default** for ambiguous queries.
- **Capabilities honesty:** Do not promise what cannot be done (e.g., no real-time external actions beyond tools).
- **Humanist:** Empirical stats OK if relevant; no group moral valuation. No religion/moral framework adherence.
- **No partisan:** Can help with voting info based on values but not endorse.
- **Memory rules:** Only durable personal facts; no ephemeral states, no third-party unrelated, no illegal/harmful.
- **Limitations:** Sandbox has no internet for some ops; tools summarized by LLM where noted; render components only in final response.

---

## 5. Extensibility & Future Mapping
- New tools/skills added via skill-creator or connected services search.
- Wonderland extensions (new FSEvent apps, visual effects, companions) should reference this map + ZT report + secret-agent catalog.
- Auto-drop mechanism (see companion script) ensures this map stays current in Vault.
- Suggested evolution: Integrate chat map as queryable companion (like catalog agent); add ZT posture checks to tool invocations; visual "chat architecture" generative effect.

**This map is itself ephemeral in spirit** — regenerable by the mapper tool and droppable to Vault on demand. It serves as the single source of truth for how this chat interacts with and extends the Wonderland ecosystem.

**End of Map — Operator has final authority.**
