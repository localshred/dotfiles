---
name: model-selector
description: Select an available OpenCode model for a new task. Use when the user asks which model to use, requests a model recommendation, says choose a model, or starts a task and explicitly asks for the appropriate model.
---

# Model Selector

Use this skill before beginning a task when model selection is requested.

Run the local selector with the complete task description:

```sh
bb ~/.config/opencode/skills/model-selector/scripts/select_model.clj "$ARGUMENTS"
```

If the task includes important context not in `$ARGUMENTS`, include it in the
argument. Do not invent model properties beyond the script's recommendation.

Present the recommendation before starting work:

```text
Model: <primary model>
Fallback: <fallback model>
Confidence: <high|medium|low>
Why: <rationale>
```

Selection rules:

- Use the recommended primary model unless the user specifies another model.
- If the user explicitly prioritizes speed or cost, choose the fallback when it
  is marked suitable for the task.
- Treat security, production incidents, migrations, broad refactors, and
  ambiguous failures as high-risk work. Do not downgrade them for speed.
- For a decision rated `low` confidence, ask one short scoping question before
  starting if the model choice would materially affect execution.
- The selector is advisory; it does not change the current session model.
  Start a new session with `opencode -m <model>` to use its recommendation.

The model inventory is intentionally local and explicit. Update
`scripts/select_model.clj` when the output of `opencode models` changes.
