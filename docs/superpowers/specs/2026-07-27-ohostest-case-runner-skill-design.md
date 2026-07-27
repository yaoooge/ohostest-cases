# OhosTest Case Runner Skill Design

## Goal

Add a project-level Codex skill that selects and runs the local HarmonyOS
ohosTest runner in either matrix mode or case mode according to the user's
validation goal.

## Location

Create the skill at:

```text
skills/ohostest-case-runner/
├── SKILL.md
├── agents/openai.yaml
└── references/
    └── modes.md
```

Use the verified runner checkout:

```text
/Users/guoyutong/codeRepo/01-mine/harmonyos-ohostest/harmonyos-ohostest-runner
```

## Mode Selection

Use matrix mode when validating an already materialized HarmonyOS project,
especially during iterative Answer development, per-device checks, or focused
suite execution with `--test-class`.

Use case mode when validating a case directory that contains metadata and patch
artifacts, or when the user requests Answer/SWE composition, classification, or
`answer`, `swe`, or `all` execution.

Explicit user mode selection takes priority. Otherwise inspect the supplied
path and goal:

- `metadata.json` plus `test_patch.patch` indicates case mode.
- A directly buildable project plus a focused device or suite request indicates
  matrix mode.
- Patch composition or SWE/Answer classification always indicates case mode.

Ask for clarification only when the path and requested outcome disagree and
choosing a mode would materially change what is tested.

## Workflow

Before running:

1. Resolve the target path to an absolute path.
2. Confirm the runner checkout and target exist.
3. Select only the devices requested by the user.
4. Let the runner manage emulator lifecycle unless the user requests otherwise.

For matrix mode, run `npm run ohostest:matrix` from the runner root with
`--project`. Allow `--device` and `--test-class`. Do not use matrix mode for
patch composition or SWE/Answer classification.

For case mode, run `npm run ohostest:case` from the runner root with `--case`.
Allow `--run answer|swe|all` and `--device`. Do not pass `--test-class`; suite
selection comes from `metadata.json`.

After either mode completes:

1. Locate the generated `summary.md`.
2. Read its device, suite, test, failure, and error counts.
3. Read the affected device log for every failure or blocked device.
4. Report the exact command, report path, and actual status.

Do not infer success from process exit code or a top-level `status: completed`
message alone.

## Skill Contents

Keep `SKILL.md` concise: triggers, decision rules, common workflow, validation
integrity, and reporting requirements.

Put the detailed option tables, command templates, case metadata behavior, and
diagnostic routing in `references/modes.md`. Instruct the consuming agent to
read only the selected mode's section.

Generate `agents/openai.yaml` through the skill-creator scripts with:

- Display name: `OhosTest Case Runner`
- Short description: `Run HarmonyOS UI tests in case or matrix mode`
- Default prompt that asks the skill to select the correct mode, run the
  requested validation, and inspect the generated report.

## Validation

Initialize the skill with the official `init_skill.py` script and validate the
finished directory with `quick_validate.py`.

Also inspect the generated `agents/openai.yaml` and scan the skill for template
placeholders. Do not run an emulator test merely to validate skill structure.
