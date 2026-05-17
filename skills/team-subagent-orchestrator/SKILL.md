---
name: team-subagent-orchestrator
description: Use when the user explicitly asks for 2-5 subagents, delegation, parallel agents, or team-style execution for bounded workstreams with distinct ownership.
---

# Team Subagent Orchestrator

## Intent

Coordinate 2-5 specialized subagents for long-running, multi-iteration tasks when delegation is explicitly requested. Prefer reusing agents that already own the relevant context. The leader stays in orchestration mode: plan, assign, monitor, integrate, and correct. The leader should not absorb specialist work except for the smallest possible unblock step when platform constraints make delegation impossible.

## When to Use

- The user explicitly asks for subagents, delegation, parallel agents, multiple workers, or team-style execution.
- The work can be split into independent, bounded workstreams with separate owners.
- Do not use because a task is merely large, complex, or urgent; explicit delegation authorization is required.

## Inputs

- `goal`: End-to-end objective and success criteria.
- `constraints`: Time budget, quality bar, scope boundaries, available tools.
- `delegation_authorized`: True only if the user explicitly asked for subagents, delegation, or parallel agent work.
- `available_agents`: Candidate agents with capability descriptions.
- `available_models`: Candidate models with strengths, speed/cost profile, and known best-fit task types.
- `milestones`: Checkpoint definitions and expected deliverables per phase.
- `iteration_budget`: Maximum number of iterations before forced convergence.

---

## Instructions

Use this skill in the following order:

1. Pass the activation gate before spawning any subagent.
2. Build the owner map, choose per-workstream models, and publish the first milestone brief.
3. Delegate with explicit dispatch packets and require assignment acks before counting work as active.
4. Track each delegated task through the dispatch state machine, not by message volume.
5. Use probes, adjustments, reassignment, and scope freeze through the escalation policy when signals require it.
6. Run iteration review before advancing, then persist lessons and state.

The detailed protocols below are the source of truth for each step.

## Output Standard

- Before delegation, publish the owner map, model choice per owner, write scope, read scope, dependencies, and done condition.
- During execution, report state by workstream status, blockers, evidence, and next decision, not by raw message volume.
- At convergence, integrate results into one final recommendation or patch set and identify any unresolved ownership conflicts.
- Do not spawn agents without a bounded assignment and distinct ownership.
- Do not let the leader take over specialist implementation while an assigned owner is active unless it is the smallest platform-required unblock step.

---

## Activation Gate

Before spawning any subagent, the leader must pass all of these checks:

1. The user explicitly asked for subagents, delegation, or parallel agent work.
2. The leader already formed a local plan and mapped workstreams to specialized owners.
3. Existing agents with relevant context are reused before creating new ones.
4. Each delegated workstream is bounded, self-contained, and materially useful in parallel.
5. Each delegated workstream has distinct ownership, especially for files or artifacts that may be edited.
6. Team size is justified. Prefer 2-3 subagents. Expand to 4-5 only when ownership is clearly split.
7. The leader selects a model per subagent based on the task's difficulty, latency needs, and expected output type.
8. The leader remains focused on orchestration artifacts and does not take specialist tasks away from an active owner.
9. If platform rules force local unblock work, that work is minimal and ownership returns to the best specialist agent immediately afterward.

If any check fails, do the work locally instead of forcing team orchestration.

---

## Phase Lifecycle

Every task follows four ordered phases. The leader drives transitions.

```
BOOTSTRAP → ITERATE → CONVERGE → CLOSE
```

### Phase 1: Bootstrap

Leader responsibilities:
1. Confirm delegation is explicitly authorized and worth the overhead.
2. Build a local plan first and map each workstream to the best specialized owner.
3. Reuse existing agents where context continuity is valuable. Spawn new agents only for clearly new workstreams.
4. Decompose the remaining work into 2-5 parallel workstreams with clear boundaries.
5. Choose the best-fit model for each workstream before dispatch.
6. Assign one subagent per workstream using the Role Charter template below.
7. Define a shared task board (see Task Board Format).
8. Initialize each agent's personal todo list and finished log (see Personal Todo & Done Log).
9. Initialize the lessons ledger (empty).
10. Publish the iteration plan: sequence, dependencies, milestone gates, active owners, model choices, and reuse decisions.

Exit criteria: Delegation gate passed, owners chosen, model choices made, reuse decisions made, roles assigned, task board initialized, all personal logs created, first iteration plan published.

### Phase 2: Iterate

Repeat per iteration cycle:

```
PLAN → DELEGATE → EXECUTE → COLLECT → INTEGRATE → CORRECT
```

1. **Plan**: Leader reviews task board, identifies priorities, keeps orchestration local, and routes each work item to the agent with the strongest context and narrowest fit.
2. **Delegate**: Leader dispatches instructions to each subagent with:
   - Shared milestone brief: one concise summary of current milestone, project status, and why this cycle matters.
   - Scope: exactly what to do (and what NOT to do).
   - Team snapshot: brief list of who owns what, so every subagent knows the current division of labor.
   - Model choice: which model this subagent should use and why.
   - Inputs: artifacts, context, and references needed.
   - Read scope: what the subagent may inspect.
   - Write scope: exact files, modules, or artifacts it owns.
   - Done criteria: how the leader will judge completion.
   - Handoff format: the exact output expected back.
   - Deadline signal: when to report back regardless of progress.
   - Heartbeat interval: how often to send progress heartbeats (e.g. every N steps or sub-tasks).
3. **Execute**: Subagents work within their role boundary. During execution:
   - Subagent sends a **Heartbeat** at regular intervals or when hitting a significant sub-step (see Heartbeat Protocol).
   - Leader may send a **Probe** at any time to request immediate status (see Probe Protocol).
   - Leader may issue a **Hot Adjustment** to change task scope, priority, or reassign mid-execution (see Dynamic Adjustment Protocol).
   - Leader stays on orchestration work: monitor progress, integrate outputs, rebalance load, and protect ownership boundaries.
4. **Collect**: Leader gathers status reports when the next decision depends on them (see Status Report Format).
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
Context advantage: <why this agent should own this area now>
Model: <chosen model>
Model rationale: <why this model fits this workstream>
Reads: <files, artifacts, or context this role may inspect>
Writes: <owned files, modules, or artifacts; use "none" for read-only roles>
Delivers: <concrete output artifacts>
Handoff: <exact report, patch, artifact, or verdict expected back>
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

## Dispatch Packet Template

Use one packet per delegated task:

```
Role: <role name>
Task: <concrete assignment>
Why now: <why this task matters in this cycle>
Milestone brief: <short shared summary of current milestone and project state>
Team snapshot: <1-3 lines on which agent owns which surfaces>
Why this owner: <why this agent is the best current owner>
Model: <chosen model>
Why this model: <why this model fits the task>
Inputs: <artifacts, references, or context to use>
Read scope: <what may be inspected>
Write scope: <owned files/modules/artifacts, or "none">
Do not touch: <explicit exclusions to avoid overlap>
Done when: <measurable completion bar>
Report back with: <patch, summary, verdict, test result, etc.>
Heartbeat interval: <every N steps or checkpoints>
Deadline signal: <when to report back even if unfinished>
```

---

## Milestone Brief Template

Leader uses one concise shared brief per cycle:

```
Milestone Brief
Cycle: <iteration number>
Current milestone: <name or checkpoint>
Goal of this cycle: <what must move forward now>
What changed since last cycle: <new facts, blockers removed, or scope changes>
Critical path: <the one dependency chain the team must protect>
Team snapshot:
  - <agent/role> owns <surface>
  - <agent/role> owns <surface>
Success signal: <what tells the team this cycle worked>
```

Rules:
- Keep this brief short. It is orientation, not a full replay of history.
- Every subagent gets the same milestone brief for the current cycle.
- If the milestone changes mid-cycle, leader sends an updated brief before issuing new work.

---

## Model Selection Rules

Leader chooses a model per subagent based on the work, not by defaulting the whole team to one model.

1. Match deeper reasoning models to ambiguous, high-stakes, or integration-heavy work.
2. Match faster/smaller models to bounded sidecar tasks, focused inspections, and routine drafting.
3. Reuse the current agent and model when the task remains in the same specialty and the model is still a good fit.
4. Change models when task shape changes materially: for example from exploration to implementation, or from drafting to critical review.
5. Record the model choice and rationale in the role charter or dispatch packet so later reassignment decisions stay explainable.
6. Do not up-model out of habit. Use the cheapest/fastest model that can reliably clear the quality bar.
7. If a subagent reports that the current model is a poor fit, route that concern through the leader and adjust explicitly.

### Example Model Mapping

| Task shape | Preferred model behavior |
|------------|--------------------------|
| Critical architecture or integration reasoning | Higher reasoning depth, slower is acceptable |
| Bounded code edit in owned files | Balanced implementation model |
| Repo exploration or narrow factual lookup | Fast smaller model |
| Independent review or quality gate | Strong reasoning / review-oriented model |
| Repetitive drafting or formatting | Faster lower-cost model |

### Role-Oriented Model Matrix

| Role archetype | Default model posture | Escalate when | Downshift when |
|----------------|-----------------------|---------------|----------------|
| Architect / Planner | Strong reasoning model | Cross-system ambiguity, risky interfaces, unclear tradeoffs | Scope narrows to a bounded rewrite |
| Builder / Worker | Balanced coding model | Integration risk rises or debugging gets hypothesis-heavy | Task becomes a mechanical patch in an owned surface |
| Explorer / Analyst | Fast smaller model | Findings are ambiguous or need deeper synthesis | The task is a narrow lookup or code search pass |
| Reviewer / Tester | Strong review-oriented model | Release risk is high or failures are subtle | The check is routine and deterministic |
| Writer / Formatter | Faster lower-cost model | Accuracy or policy sensitivity becomes important | Work remains repetitive formatting or cleanup |

### Selection Heuristics

- Prefer one model tier below your first instinct unless quality evidence says otherwise.
- Escalate model capability for ambiguity, integration risk, hidden state, or expensive mistakes.
- Downshift model capability for repetitive, narrow, or easily verifiable work.
- When reusing an existing agent, keep both owner and model stable unless there is a clear reason to change one of them.

## Model Change Suggestion Protocol

Subagents may suggest changing their assigned model when the current fit is clearly wrong for the task.

### When to Suggest a Model Change

- The work requires materially more reasoning depth than expected.
- The work is narrower or more mechanical than expected and can be done faster with a lighter model.
- The current model is causing avoidable latency or cost for low-risk work.
- The task shape changed since dispatch.

### Suggestion Format

```
Model Change Suggestion
From: <role name>
Current model: <model>
Suggested model: <model>
Reason: <why the new model is a better fit>
Impact if changed: <speed / quality / cost tradeoff>
Urgency: <now / this-cycle / next-cycle>
```

Rules:
- Subagents do not self-switch models silently.
- Leader approves, rejects, or defers the change and records the decision.
- If the leader keeps the current model, it should briefly explain the tradeoff.
- If the model change materially affects reasoning depth, latency, or expected output quality, leader should refresh the dispatch packet and require a fresh ack before continued execution.

---

## Specialization & Continuity Rules

1. Prefer the agent that already owns the workstream or adjacent context. Reuse beats respawn.
2. Reassign only when the current owner is blocked, overloaded, mismatched for the specialty, or an independent review is required.
3. Leader-owned artifacts are limited to orchestration state: task board, iteration plan, milestone gates, lessons ledger, and final integration decisions.
4. Leader must not absorb specialist tasks just because it sees the whole board.
5. If platform rules force local unblock work, keep it minimal and hand ownership back to the best specialist agent immediately.
6. Every subagent should know the current milestone and a brief team-wide ownership map, but not receive unnecessary full-history context.
7. If a subagent believes another agent is a better owner for part of the work, it raises that recommendation to the leader instead of reassigning work directly.

## Reassignment Suggestion Protocol

Subagents may surface better ownership suggestions when they detect a mismatch in specialization, context, or workload.

### When a Subagent Should Suggest Reassignment

- The task depends heavily on context already owned by another agent.
- The current owner is no longer the best specialist for the work.
- The work has split into a new surface that should become its own owned stream.
- The current assignment creates likely duplication or ownership conflict.

### Suggestion Format

```
Ownership Suggestion
From: <role name>
Current task: <task currently assigned>
Suggested owner: <role name or agent identifier>
Reason: <why the suggested owner is a better fit>
Urgency: <now / this-cycle / next-cycle>
Risk if unchanged: <one-line risk or "low">
```

Rules:
- Subagents do not hand work directly to each other.
- Leader decides whether to keep ownership, split the work, or reassign it.
- If the leader keeps the current owner, it should briefly explain why so the team model stays coherent.
- On reassignment, leader should send a new dispatch packet to the receiving owner, include a continuity handoff artifact from the prior owner, and require a fresh ack before execution resumes.

## Assignment Acknowledgement Protocol

Every delegated task should be acknowledged before meaningful execution starts.

### Acknowledgement Format

```
Assignment Ack
Role: <role name>
Task understood: <one-line restatement>
Milestone understood: <current milestone in one line>
My scope: <what I own in this assignment>
Model understood: <chosen model and why it fits>
Out of scope: <what I will not touch>
Dependencies: <none or short list>
First step: <what I will do first>
Concern: <none or one-line concern>
```

Rules:
- Ack should be brief and confirm that the subagent understood the milestone and ownership boundary.
- If the subagent sees an ownership mismatch, it should ack and include the concern, then use the reassignment suggestion protocol if needed.
- If the ack includes an ownership, scope, or model-fit concern, the task must not enter `in-progress` until the leader resolves that concern.
- Leader should correct misunderstandings immediately instead of waiting for later drift.

---

## Dispatch State Machine

Every delegated task moves through a small explicit lifecycle. Do not treat "message sent" as "work underway."

### Dispatch States

`planned -> dispatched -> acked -> in-progress -> handoff-submitted -> integrated`

Supporting states:
- `blocked`: work cannot proceed without leader intervention or dependency resolution.
- `cancelled`: task was intentionally dropped, merged into another task, or superseded.

### State Meanings

| State | Meaning | Entered by |
|-------|---------|------------|
| `planned` | Leader decided the task should exist but has not dispatched it yet | Leader |
| `dispatched` | Leader sent the dispatch packet | Leader |
| `acked` | Subagent confirmed milestone, scope, model, and first step | Subagent |
| `in-progress` | Subagent started meaningful execution after ack | Subagent |
| `handoff-submitted` | Subagent delivered the requested output for review/integration | Subagent |
| `integrated` | Leader accepted and merged the handoff into the shared result | Leader |
| `blocked` | Work is paused on a blocker | Leader or Subagent |
| `cancelled` | Task is intentionally closed without integration | Leader |

### Transition Rules

1. Leader creates the task in `planned`.
2. After sending the dispatch packet, leader moves it to `dispatched`.
3. Subagent ack moves it to `acked`.
4. The task moves to `in-progress` only when the subagent starts real execution.
5. Delivery of the requested output moves it to `handoff-submitted`.
6. While leader is evaluating the handoff, task status should usually be `in-review`.
7. Leader review and acceptance moves it to `integrated`.
8. If leader requests rework, preserve the same task ID, send explicit feedback, return the dispatch state to `acked` after the owner acknowledges the rework, and then back to `in-progress` when rework starts.
9. Leader may move any non-`integrated` task to `cancelled` if the work is superseded.
10. Any state may move to `blocked` if work cannot continue.
11. `blocked` returns to the last active state when the blocker is cleared.
12. On `task-reassign`, old owner stops, records partial output if any, leader updates ownership, moves the task back to `dispatched` for the new owner, and requires a fresh ack before execution resumes.

### Discipline Rules

- Leader must not mark a task `in-progress` before receiving an ack.
- Leader must not mark a task `integrated` until the handoff is actually reviewed and accepted.
- If a task is still `dispatched` without ack, treat it as unclaimed, not active.
- If a subagent delivers partial output, keep the task `in-progress` unless the requested handoff was actually submitted.
- `in-review` should normally pair with `handoff-submitted`, not with `acked` or `dispatched`.
- If ownership changes, preserve the same task ID when possible and log the transition reason.
- If a scope change or model change invalidates the previous ack, refresh the dispatch packet and require a fresh ack.

---

## Leader Decision Framework

The leader makes decisions using this priority stack:

1. **Unblock** — Is any subagent stuck? Resolve the blocker first.
2. **Correct** — Is any workstream drifting from the goal? Intervene with specific guidance.
3. **Rebalance** — Is one subagent idle while another is overloaded? Redistribute.
4. **Advance** — Push the next highest-priority work item forward.
5. **Refine** — Improve plan quality only when all above are clear.

Leader anti-patterns to avoid:
- Spawning agents without explicit user authorization.
- Spawning a new agent when an existing owner already has the right context.
- Giving vague instructions like "make it better."
- Giving multiple subagents overlapping write ownership.
- Letting the leader take specialist work away from an established owner.
- Treating `dispatched` as equivalent to `in-progress`.
- Marking work `integrated` before reviewing the handoff.
- Changing subagent roles mid-iteration without explicit re-charter.
- Ignoring low-confidence status reports.
- Skipping retrospective so ownership and process lessons are lost.
- Moving to next iteration before current milestone gate passes.
- Reassigning follow-up work to a fresh agent without a concrete reason.

---

## Leader Escalation Policy

Leader should escalate based on explicit signals, not intuition alone.

### Mandatory Probe Triggers

Leader must send a probe when any of these happen:

- No heartbeat arrives within 2x the expected interval.
- A subagent reports `Confidence: low`.
- A dependency needed by another active workstream is unclear.
- A heartbeat suggests drift, hidden blocker, or scope creep.
- A task stays `dispatched` without ack longer than expected for the cycle.

### Mandatory Reassignment Triggers

Leader should consider reassignment and make an explicit keep/split/reassign decision when:

- The current owner is blocked for a full cycle without a credible unblock path.
- Another agent clearly has the missing context or specialty.
- The task split created a new surface that deserves its own owner.
- The current owner/model combination is repeatedly failing the quality bar.
- Silence continues after probe and reasonable wait.

### Mandatory Scope Freeze Triggers

Leader should freeze scope and stop admitting new work when:

- Critical-path work is slipping and iteration budget is tightening.
- Integration gaps are growing faster than the team is closing them.
- More than one active workstream is blocked on unresolved upstream decisions.
- The team is in converge mode.
- The user changed priorities and the board has not yet been reconciled.

### Escalation Ladder

Apply the lightest intervention that can restore control:

1. Clarify: answer a question or remove ambiguity.
2. Probe: request immediate status.
3. Adjust: change priority, scope, or deadline.
4. Reassign: move or split ownership.
5. Freeze scope: stop new work and protect the critical path.
6. Force convergence: close only must-finish items and defer the rest.

Rules:
- Record the reason for every escalation on the task board or iteration notes.
- If you skip a lower rung and jump higher, the trigger should justify it.
- Repeated escalation on the same workstream should produce a process lesson, not just another intervention.

---

## Iteration Review Checklist

Before closing a cycle or moving to the next milestone, leader runs this checklist:

1. Every `dispatched` task either received an ack or was explicitly cancelled.
2. Every `acked` task has a clear next move: start, block, or cancel.
3. Every `handoff-submitted` task was reviewed and either integrated, sent back for rework, or kept open with a clear reason.
4. Every `blocked` task has an owner, blocker description, and concrete next action.
5. Every ownership change has a recorded reason.
6. Every model change has a recorded reason and expected tradeoff.
7. Every active workstream still has exactly one clear owner.
8. The task board and owner map still match reality.
9. The milestone brief for the next cycle reflects new blockers, completions, and critical-path changes.
10. Lessons worth reusing were appended to the lessons ledger.

### Quick Review Output

Leader can summarize the review in this compact form:

```
Iteration Review
Cycle: <iteration number>
Ack gaps: <none or list>
Handoff gaps: <none or list>
Blocked tasks with next action: <yes / no>
Ownership/model changes logged: <yes / no>
Board aligned with reality: <yes / no>
Ready for next cycle: <yes / no>
```

Rules:
- If `Ready for next cycle` is `no`, leader fixes the gaps before advancing.
- Do not skip this review just because the team feels on track.

---

## Owner Map Format

Leader maintains a compact owner map alongside the task board:

```
## Owner Map
| Surface | Owner | Backup | Model | Source of truth |
|---------|-------|--------|-------|-----------------|
| auth service tests | Reviewer | Tester | <model> | T7 |
| migration docs | Writer | none | <model> | T9 |
```

Rules:
- One surface should have one clear primary owner.
- `Surface` should describe a work area, file group, or artifact family, not a vague theme.
- `Source of truth` should point to the controlling task ID or charter.
- Update the owner map immediately after reassignment, split, or close decisions.

---

## Task Board Format

```
| ID | Task | Owner | Status | Dispatch State | Blockers | Next Action |
|----|------|-------|--------|----------------|----------|-------------|
| T1 | ... | Agent-A | not-started | acked | none | start patch |
| T2 | ... | Agent-B | blocked | in-progress | waiting T1 output | resume once API lands |
```

Status values: `not-started`, `in-progress`, `blocked`, `in-review`, `done`.

Dispatch state values: `planned`, `dispatched`, `acked`, `in-progress`, `handoff-submitted`, `integrated`, `blocked`, `cancelled`.

Rules:
- `Status` tracks business/task progress.
- `Dispatch State` tracks delegation lifecycle.
- For delegated work, leader should maintain both. Do not collapse them into one field.
- `in-review` usually means the deliverable has been submitted and is being evaluated, so it should normally pair with `handoff-submitted`.
- `done` should normally be used only after `integrated` or an explicit leader decision to close the task.

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
- On `task-reassign`, the current owner must submit a continuity handoff: current state, partial outputs, known risks, and recommended next step for the new owner.
- If an adjustment materially changes scope, read/write boundaries, deliverable, or model, leader should refresh the dispatch packet and require a fresh ack.

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
| Context churn | Fresh owner is being considered for follow-up work already owned elsewhere | Default back to current owner unless a clear specialty or review reason justifies the switch |

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

Before entering CLOSE, every non-integrated task must be explicitly integrated, cancelled, or rolled into a next-iteration backlog entry with a named owner.

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

## Minimal Working Example

This is a copyable first-cycle example for a small repo task.

**User goal**: "Use subagents to update the skill docs and structured metadata for one feature addition."

### 1. Leader Milestone Brief

```text
Milestone Brief
Cycle: 1
Current milestone: Add one new protocol rule consistently across markdown and JSON
Goal of this cycle: Update the human doc and machine-readable schema without drift
What changed since last cycle: none
Critical path: protocol decision -> markdown update -> JSON alignment -> validation
Team snapshot:
  - Leader owns orchestration, board, owner map, integration, final validation
  - Agent-A owns markdown protocol edits
  - Agent-B owns JSON alignment and schema drift checks
Success signal: SKILL.md and skill.json both reflect the same new rule and repo validation passes
```

### 2. Leader Owner Map

```text
## Owner Map
| Surface | Owner | Backup | Model | Source of truth |
|---------|-------|--------|-------|-----------------|
| protocol markdown | Agent-A | none | balanced coding model | T1 |
| skill.json alignment | Agent-B | none | fast smaller model | T2 |
| integration and validation | Leader | none | strong reasoning model | T3 |
```

### 3. Leader Task Board

```text
| ID | Task | Owner | Status | Dispatch State | Blockers | Next Action |
|----|------|-------|--------|----------------|----------|-------------|
| T1 | Update SKILL.md for new rule | Agent-A | not-started | planned | none | send dispatch |
| T2 | Mirror rule in skill.json and check drift | Agent-B | not-started | planned | none | send dispatch |
| T3 | Integrate outputs and run validation | Leader | not-started | planned | waiting T1,T2 | prepare review |
```

### 4. Dispatch Packet to Agent-A

```text
Role: Markdown Owner
Task: Update SKILL.md to add the new protocol rule in the correct sections
Why now: Markdown is the human source of truth for the new behavior
Milestone brief: Add one protocol rule consistently across markdown and JSON this cycle
Team snapshot: Agent-A owns markdown, Agent-B owns JSON, Leader owns integration
Why this owner: You own the human-readable protocol surface
Model: balanced coding model
Why this model: This is a bounded doc edit with moderate structure sensitivity
Inputs: current SKILL.md and the leader's rule decision
Read scope: SKILL.md
Write scope: SKILL.md
Do not touch: skill.json
Done when: the new rule is present in all relevant markdown sections without contradicting existing workflow
Report back with: concise change summary plus headings touched
Heartbeat interval: every 2 meaningful edits
Deadline signal: report back when done or blocked
```

### 5. Dispatch Packet to Agent-B

```text
Role: JSON Owner
Task: Mirror the new protocol rule in skill.json and flag markdown/json drift
Why now: structured consumers will miss the rule if JSON is stale
Milestone brief: Add one protocol rule consistently across markdown and JSON this cycle
Team snapshot: Agent-A owns markdown, Agent-B owns JSON, Leader owns integration
Why this owner: You own the machine-readable contract
Model: fast smaller model
Why this model: This is a narrow alignment check plus bounded schema update
Inputs: current skill.json and docs/SKILL_SPEC.md
Read scope: skill.json, docs/SKILL_SPEC.md, relevant markdown headings if needed
Write scope: skill.json
Do not touch: SKILL.md
Done when: JSON contains the rule in the right fields and any remaining drift is explicitly reported
Report back with: changed fields plus any drift findings
Heartbeat interval: every 2 meaningful checks
Deadline signal: report back when done or blocked
```

### 6. Expected Assignment Ack

```text
Assignment Ack
Role: Markdown Owner
Task understood: add the new rule to the relevant markdown protocol sections
Milestone understood: keep markdown and JSON aligned for one new rule this cycle
My scope: SKILL.md only
Model understood: balanced coding model because this is a bounded structured doc edit
Out of scope: skill.json
Dependencies: none
First step: locate the governing sections and patch the rule in all affected spots
Concern: none
```

### 7. Leader Integration Step

After both handoffs arrive:

1. Review Agent-A handoff.
2. Review Agent-B handoff.
3. Reconcile any drift findings.
4. Update task board: `T1/T2 -> integrated`, `T3 -> in-progress`.
5. Run `bash scripts/validate-skills.sh`.
6. If validation passes, mark `T3 -> integrated` and close the cycle.

This is the minimum viable pattern: one milestone brief, one owner map, one task board, two dispatches, two acks, then integration and validation.

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

### Example 4: Large Repo Upgrade

**Goal**: Upgrade a shared library across a large repo without stalling the critical path.

**Team**:
- Leader: orchestration, owner map, milestone gates, final integration.
- Agent-A (Test Auditor): identify failing test surfaces and minimal rerun plan.
- Agent-B (Docs Writer): draft migration notes and risky call-site changes.
- Agent-C (Config Checker): review build and runtime config impact.

**Iteration flow**: Leader stays on orchestration only. Sidecar agents gather test, docs, and config evidence in parallel, then the best specialist owner takes each resulting implementation surface. The leader waits only when the next integration decision depends on one of those results.
