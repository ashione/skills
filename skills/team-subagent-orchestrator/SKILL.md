# Team Subagent Orchestrator

## Intent

Enable a leader main agent to manage a team of 3-5 subagents for completing long-running, multi-iteration tasks. The leader focuses exclusively on thinking, planning, delegation, progress tracking, and course correction — not direct execution.

## Inputs

- `goal`: End-to-end objective and success criteria.
- `constraints`: Time budget, quality bar, scope boundaries, available tools.
- `available_agents`: Candidate agents with capability descriptions.
- `milestones`: Checkpoint definitions and expected deliverables per phase.
- `iteration_budget`: Maximum number of iterations before forced convergence.

---

## Phase Lifecycle

Every task follows four ordered phases. The leader drives transitions.

```
BOOTSTRAP → ITERATE → CONVERGE → CLOSE
```

### Phase 1: Bootstrap

Leader responsibilities:
1. Decompose the goal into 3-5 parallel workstreams with clear boundaries.
2. Assign one subagent per workstream using the Role Charter template below.
3. Define a shared task board (see Task Board Format).
4. Initialize each agent's personal todo list and finished log (see Personal Todo & Done Log).
5. Initialize the lessons ledger (empty).
6. Publish the iteration plan: sequence, dependencies, milestone gates.

Exit criteria: All roles assigned, task board initialized, all personal logs created, first iteration plan published.

### Phase 2: Iterate

Repeat per iteration cycle:

```
PLAN → DELEGATE → EXECUTE → COLLECT → INTEGRATE → CORRECT
```

1. **Plan**: Leader reviews task board, identifies priorities, and assigns work units.
2. **Delegate**: Leader dispatches instructions to each subagent with:
   - Scope: exactly what to do (and what NOT to do).
   - Inputs: artifacts, context, and references needed.
   - Done criteria: how the leader will judge completion.
   - Deadline signal: when to report back regardless of progress.
   - Heartbeat interval: how often to send progress heartbeats (e.g. every N steps or sub-tasks).
3. **Execute**: Subagents work within their role boundary. During execution:
   - Subagent sends a **Heartbeat** at regular intervals or when hitting a significant sub-step (see Heartbeat Protocol).
   - Leader may send a **Probe** at any time to request immediate status (see Probe Protocol).
   - Leader may issue a **Hot Adjustment** to change task scope, priority, or reassign mid-execution (see Dynamic Adjustment Protocol).
4. **Collect**: Leader gathers status reports (see Status Report Format).
5. **Integrate**: Leader merges outputs, resolves conflicts, updates task board.
6. **Correct**: Leader evaluates drift and decides:
   - Continue as planned.
   - Rebalance: move tasks between subagents.
   - Rework: roll back and retry a workstream.
   - Re-scope: adjust goal boundaries if constraints changed.
7. **Retro**: Leader collects per-cycle retro from each subagent, updates lessons ledger, adjusts next cycle plan.
8. **Persist**: All agents write current todo/done/retro state to persistent storage.

Exit criteria: All milestone gates passed, or iteration budget exhausted.

### Phase 3: Converge

1. Leader runs final quality checks across all workstreams.
2. Each subagent delivers final output with self-assessment.
3. Leader identifies integration gaps and assigns targeted fixes.
4. No new scope is accepted — only close existing items.

Exit criteria: All workstreams meet done criteria, no critical blockers remain.

### Phase 4: Close

1. Leader produces integrated final output.
2. Leader documents residual risks and known limitations.
3. Leader writes project-level retrospective (see Retrospective & Lessons Learned).
4. Leader writes next-iteration backlog if applicable.
5. Leader archives all state: task board, all agent logs, and lessons ledger.

---

## Role Charter Template

Define each subagent with this structure:

```
Role: <name>
Agent: <agent identifier>
Owns: <workstream description>
Delivers: <concrete output artifacts>
Depends on: <other roles or external inputs>
Done when: <measurable completion criteria>
Must NOT: <out-of-scope actions to prevent overlap>
```

### Example Role Set

| Role | Owns | Delivers | Must NOT |
|------|------|----------|----------|
| Architect | System design and interface contracts | Design docs, API schemas | Write implementation code |
| Builder | Feature implementation | Working code with unit tests | Change API contracts |
| Tester | Validation and edge cases | Test suites, coverage reports | Fix production code |
| Reviewer | Quality gate and integration checks | Review verdicts, merge decisions | Implement features |

---

## Leader Decision Framework

The leader makes decisions using this priority stack:

1. **Unblock** — Is any subagent stuck? Resolve the blocker first.
2. **Correct** — Is any workstream drifting from the goal? Intervene with specific guidance.
3. **Rebalance** — Is one subagent idle while another is overloaded? Redistribute.
4. **Advance** — Push the next highest-priority work item forward.
5. **Refine** — Improve plan quality only when all above are clear.

Leader anti-patterns to avoid:
- Doing execution work directly instead of delegating.
- Giving vague instructions like "make it better."
- Changing subagent roles mid-iteration without explicit re-charter.
- Ignoring low-confidence status reports.
- Moving to next iteration before current milestone gate passes.

---

## Task Board Format

```
| ID | Task | Owner | Status | Blockers | Next Action |
|----|------|-------|--------|----------|-------------|
| T1 | ... | Agent-A | in-progress | none | ... |
| T2 | ... | Agent-B | blocked | waiting T1 output | ... |
```

Status values: `not-started`, `in-progress`, `blocked`, `in-review`, `done`.

---

## Status Report Format

Each subagent reports with this structure:

```
Role: <role name>
Cycle: <iteration number>
Progress: <what was completed>
Confidence: <high / medium / low>
Blockers: <list or "none">
Next: <planned next action>
Risk: <anything the leader should know>
```

Leader must act on any report with `Confidence: low` or non-empty `Blockers` before advancing.

---

## Heartbeat Protocol

Subagents must not go silent during long-running execution. They send lightweight heartbeats so the leader always knows what's happening.

### When to Send a Heartbeat

- At the interval specified by the leader in the delegation (e.g. every 3 sub-steps).
- When starting a significant sub-task within the assigned work.
- When encountering an unexpected situation (even if not yet a blocker).
- When completing a meaningful intermediate result.

### Heartbeat Format

```
Heartbeat
Role: <role name>
Cycle: <iteration number>
Current action: <what I am doing right now — one line>
Sub-progress: <X of Y sub-steps done, or percentage>
On track: <yes / drifting / stuck>
Early signal: <potential risk or finding, or "none">
```

Rules:
- Heartbeats must be concise — max 6 lines. Not a full status report.
- Leader scans heartbeats and decides: acknowledge, probe deeper, or issue adjustment.
- If no heartbeat arrives within 2x the expected interval, leader sends a Probe.

---

## Probe Protocol

The leader can request an immediate status from any subagent at any time, without waiting for the next cycle boundary.

### When Leader Sends a Probe

- Heartbeat is overdue (2x expected interval).
- Leader detects a cross-workstream dependency that needs confirmation.
- External constraint changed and leader needs to assess impact.
- Leader suspects drift or scope creep based on heartbeat content.

### Probe Format

```
Probe from Leader
To: <role name>
Reason: <why I need status now>
Questions:
  1. <specific question>
  2. <specific question>
Respond within: <urgency — immediate / next sub-step boundary>
```

### Probe Response Format

```
Probe Response
Role: <role name>
Answers:
  1. <answer>
  2. <answer>
Current state: <one-line summary>
Need from leader: <nothing / specific ask>
```

Rules:
- Subagents must respond to probes before continuing their current work (if urgency is "immediate").
- Leader must not spam probes — max 2 per subagent per cycle unless critical.

---

## Dynamic Adjustment Protocol

The leader can change task assignments, priorities, or scope mid-execution without waiting for the cycle to end.

### Adjustment Types

| Type | When | Effect |
|------|------|--------|
| **Priority shift** | New info changes what matters most | Subagent reorders its todo list |
| **Scope change** | Requirements evolved or narrowed | Subagent drops/adds sub-tasks |
| **Task reassign** | Bottleneck or better-fit agent identified | Task moves to another subagent |
| **Emergency stop** | Critical issue detected | Subagent halts current work immediately |
| **Inject task** | Urgent unplanned work appears | New item added to subagent's todo with priority |

### Adjustment Message Format

```
Adjustment from Leader
To: <role name>
Type: <priority-shift | scope-change | task-reassign | emergency-stop | inject-task>
Reason: <why this change is needed — one line>
Details:
  <specific instructions>
Expected response: <acknowledge / confirm-new-plan / pause-and-wait>
```

### Subagent Adjustment Response

```
Adjustment Acknowledged
Role: <role name>
Understood: <restate the change in own words>
Impact: <what this changes in my current plan>
New next action: <what I will do now>
Risk: <any concern about this change, or "none">
```

Rules:
- Subagent MUST acknowledge before proceeding. Silent acceptance is not allowed.
- On `emergency-stop`, subagent halts immediately, persists current state, and waits.
- After any adjustment, subagent updates its personal todo list to reflect the new reality.
- Leader logs every adjustment on the task board with timestamp and reason.
- If a subagent disagrees with an adjustment, it states the concern in `Risk` — but leader's decision is final.

### Leader Adjustment Discipline

- Do not adjust purely out of anxiety — require a concrete trigger (heartbeat signal, probe finding, or external event).
- Batch minor adjustments when possible instead of sending a stream of small changes.
- After issuing an adjustment, verify the subagent's todo list reflects the change before moving on.
- Record every adjustment in the task board audit trail for retrospective review.

---

## Failure Recovery

| Failure Mode | Detection Signal | Leader Response |
|---|---|---|
| Subagent stuck | No progress for 2 cycles | Clarify instructions or reassign task |
| Output quality below bar | Review fails quality gate | Rework with specific feedback |
| Scope creep | Subagent working outside charter | Stop, re-scope, re-delegate |
| Conflicting outputs | Integration step finds contradictions | Convene sync, leader decides resolution |
| Iteration budget near limit | >80% budget consumed with <60% done | Force convergence on critical path only |
| Subagent silent | No heartbeat for 2x expected interval | Probe immediately; if no response, reassign task |
| Mid-execution drift | Heartbeat shows work diverging from scope | Issue scope-change adjustment with correction |
| Priority inversion | Lower-priority work blocking higher-priority | Issue priority-shift or task-reassign adjustment |

---

## Personal Todo & Done Log

Every agent (leader included) maintains its own persistent todo list and finished-task log. This is the backbone of long-task execution.

### Todo List Format

Each agent keeps a running list:

```
## <Role> Todo
| ID | Task | Priority | Status | Added | Notes |
|----|------|----------|--------|-------|-------|
| L1 | Review iteration 2 outputs | high | in-progress | cycle-2 | waiting Agent-B |
| L2 | Rebalance tester workload | medium | not-started | cycle-2 | |
```

Rules:
- Update the todo list BEFORE starting any work — mark the item `in-progress`.
- Mark `done` IMMEDIATELY after completing — never batch completions.
- One `in-progress` item at a time per agent.
- Leader reviews all agents' todo lists at the start of each cycle.

### Finished Task Log

When an item is marked `done`, move it to the agent's finished log with a one-line outcome:

```
## <Role> Finished
| ID | Task | Completed | Outcome | Lesson |
|----|------|-----------|---------|--------|
| A3 | Implement auth module | cycle-3 | Passed all tests | Token refresh edge case was missed in spec — ask for edge cases upfront |
| A4 | Fix rate limiter bug | cycle-4 | Hotfix deployed | Root cause was config drift — add config validation to checklist |
```

Rules:
- Every finished item MUST have a one-line `Outcome`.
- If the task taught something reusable, fill the `Lesson` column.
- Leader scans all finished logs before each planning phase.

---

## Retrospective & Lessons Learned

At the end of every iteration (not just at project close), the team runs a structured retrospective.

### Per-Iteration Retro

Leader collects from each subagent:

```
Role: <name>
Cycle: <number>
What went well: <1-2 items>
What went wrong: <1-2 items>
Lesson: <actionable takeaway>
Suggestion: <process improvement for next cycle>
```

Leader then:
1. Synthesizes common themes across all reports.
2. Updates a running **Lessons Ledger** (see below).
3. Adjusts next iteration plan based on lessons — this is mandatory, not optional.

### Lessons Ledger

A persistent, append-only record maintained by the leader:

```
## Lessons Ledger
| # | Cycle | Source | Lesson | Action Taken |
|---|-------|--------|--------|--------------|
| 1 | 1 | Builder | Specs missing edge cases → caused rework | Added edge-case checklist to delegation template |
| 2 | 2 | Tester | Test data setup took 40% of cycle | Leader now pre-provisions test fixtures |
| 3 | 3 | Leader | Rebalance too late, bottleneck lasted 2 cycles | Added mid-cycle health check |
```

Rules:
- Never delete entries — only append.
- Leader MUST reference the ledger when planning each new cycle.
- If the same lesson appears twice, escalate it to a permanent process rule.

### Project-Level Retrospective

At CLOSE phase, leader writes a final retrospective:
1. Top 3 things that worked.
2. Top 3 things that didn't.
3. Process changes to carry forward.
4. Skills or knowledge gaps identified.

---

## Persistence & Memory

Long-running tasks span multiple sessions. All agents must persist their state.

### What Each Agent Persists

| Agent | Persists | Storage |
|-------|----------|---------|
| Leader | Task board, lessons ledger, iteration plans, project retro | Session memory or designated file |
| Each Subagent | Personal todo list, finished log, per-cycle retro notes | Session memory or designated file |

### Persistence Rules

1. At the END of every cycle, each agent writes its current state to persistent storage.
2. At the START of every cycle, each agent reads its persisted state before acting.
3. Leader verifies all agents have restored state before dispatching work.
4. If an agent loses state (session break), leader reconstructs from:
   - Task board (source of truth for assignments)
   - Finished logs (source of truth for completed work)
   - Lessons ledger (source of truth for process knowledge)
5. Prefer structured formats (tables, JSON) over prose for persisted state — easier to parse on reload.

### Context Window Management

Long iterations risk context overflow. Leader must:
- Summarize completed work as compact artifacts, not raw conversation.
- Pass only relevant context to each subagent dispatch — not the entire history.
- Use the task board as the single source of truth, not scattered messages.
- Archive completed workstream details and only carry forward residual items.
- Persist lessons ledger separately — do not inline into dispatch messages.

---

## Examples

### Example 1: Platform Migration

**Goal**: Migrate monolith to microservices across 6 iterations.

**Team**:
- Leader: orchestration and cross-service API alignment.
- Agent-A (Architect): service boundary design, API contracts.
- Agent-B (Builder): migration implementation per service.
- Agent-C (Tester): integration tests, performance benchmarks.
- Agent-D (Ops): deployment pipeline, canary rollout safety.

**Iteration 1 flow**: Leader assigns Agent-A to define service boundaries. Agent-B waits. Agent-C prepares test harness. Agent-D sets up staging pipeline. Milestone gate: API contracts reviewed and approved.

**Course correction**: Iteration 3, Agent-C reports test coverage gap on payment service. Leader pauses Agent-B's next module, redirects to write missing payment tests first. Rebalances by having Agent-A assist with payment edge case specification.

### Example 2: Documentation Overhaul

**Goal**: Rewrite all user-facing docs for a product rebrand.

**Team**:
- Leader: content strategy, consistency review, sign-off.
- Agent-A (Writer): draft new content per section.
- Agent-B (Reviewer): accuracy and style checks.
- Agent-C (Asset Creator): diagrams, screenshots, code samples.

**Iteration flow**: Leader prioritizes top-traffic pages first. Agent-A drafts, Agent-C creates assets in parallel, Agent-B reviews completed pairs. Leader gates each batch before publishing.

### Example 3: Complex Bug Investigation

**Goal**: Diagnose and fix an intermittent production crash.

**Team**:
- Leader: hypothesis management, evidence synthesis.
- Agent-A (Log Analyst): parse logs and identify patterns.
- Agent-B (Code Inspector): trace suspicious code paths.
- Agent-C (Reproducer): build minimal reproduction cases.

**Iteration flow**: Leader forms initial hypotheses. Dispatches agents to gather evidence in parallel. Collects findings, eliminates hypotheses, narrows scope. Repeats until root cause is confirmed and fix is validated.
