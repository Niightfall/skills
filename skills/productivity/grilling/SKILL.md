---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

## Interactive relay

This is an interactive workflow. Keep the grilling conversation alive across
rounds: ask one frontier round, wait for the user's answers, then recompute
the frontier and continue. Do not complete the exercise from the initial
prompt alone.

When a controller delegates this skill to the planning agent, use
`scripts/run-agent.sh start` for the first round. The script returns a
`GRILLING_SESSION_ID` and the agent's question round. Show that round in the
chat. After the user answers, call `scripts/run-agent.sh resume <session-id>`
with the answer as the prompt and show the returned round. Repeat until the
agent reports that the frontier is empty and the user confirms the shared
understanding.

The session ID is state, not user content: preserve it between turns and
resume the same session rather than starting a new grilling agent. Treat the
agent's response as the chat response; do not paraphrase its questions or
answer them for the user. If delegation is unavailable, run the same protocol
inline in the current conversation and say that it is inline.

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
