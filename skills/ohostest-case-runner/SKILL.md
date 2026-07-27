---
name: ohostest-case-runner
description: Run and diagnose HarmonyOS ohosTest validation with the local harmonyos-ohostest-runner, selecting matrix mode for direct project and focused suite validation or case mode for metadata, test_patch/golden_patch, Answer/SWE, and final case classification workflows. Use when the user asks to run case-runner, ohostest:matrix, ohostest:case, validate answer or swe, test specific devices or suites, inspect runner reports, or diagnose runner failures.
---

# OhosTest Case Runner

Use the verified runner checkout:

```text
/Users/guoyutong/codeRepo/01-mine/harmonyos-ohostest/harmonyos-ohostest-runner
```

Run npm commands from that directory. Pass absolute target paths.

## Select the Mode

Honor an explicitly requested mode. Otherwise use:

| Need | Mode |
| --- | --- |
| Validate an already materialized HarmonyOS project | matrix |
| Iterate on `answer` before generating patches | matrix |
| Run one device or one suite with `--test-class` | matrix |
| Apply `test_patch.patch` or `golden_patch.patch` | case |
| Validate `answer`, `swe`, or both from a case directory | case |
| Check metadata classification and SWE/Answer expectations | case |

Treat a directory containing `metadata.json` and `test_patch.patch` as a case.
Treat a directly buildable project containing `build-profile.json5` as a matrix
target.

Ask one concise question only when the supplied path and requested outcome
contradict each other and selecting a mode would test different artifacts.

Read the selected mode section in [references/modes.md](references/modes.md)
before constructing the command.

## Preflight

1. Resolve the runner and target to absolute paths.
2. Confirm the target exists.
3. For matrix mode, confirm `build-profile.json5` exists.
4. For case mode, confirm `metadata.json`, `test_patch.patch`, and the declared
   base project exist. Require `golden_patch.patch` when running Answer.
5. Select only user-requested devices. Otherwise keep the mode's configured
   device selection.
6. Let the runner build, install, start, and stop emulators by default.

Do not run `npm install` unless dependencies are missing and the user authorizes
installation. Do not manually start an emulator before a normal runner command.
Use `--keep-emulators true` only when continued manual inspection is requested.

## Run Matrix Mode

Use matrix mode for direct projects:

```bash
npm run ohostest:matrix -- \
  --project <absolute-project-path>
```

Add repeatable `--device <id>` filters or one `--test-class <className>` when
requested. Do not use matrix mode to compose patches or judge pass-to-pass and
fail-to-pass classification.

## Run Case Mode

Use case mode for case artifacts:

```bash
npm run ohostest:case -- \
  --case <absolute-case-path> \
  --run <answer|swe|all>
```

Default to `answer` only when the user asks to validate the completed Answer or
does not specify a side. Use `swe` for the test-patch-only project. Use `all`
for a direct SWE/Answer comparison.

Never pass `--test-class` in case mode. Suite selection comes from
`metadata.json`.

## Verify the Result

Never infer test success from process exit code or a top-level
`status: completed` message. `completed` can mean that execution finished while
individual devices, suites, or tests failed.

After every run:

1. Locate the `summary.md` produced by that exact invocation.
2. Read device, suite, test, failure, error, pass, and ignored counts.
3. For case mode, also inspect classification verdicts and both requested run
   sides.
4. Open `commands.log` for build, patch, install, or orchestration failures.
5. Open the affected `devices/<device>.log` for each failed or blocked device.
6. Claim success only when every requested device and suite satisfies the
   requested expectation.

Do not edit the runner, metadata, patches, or tested project when the user asks
only to run, inspect, diagnose, or report. Implement fixes only when explicitly
requested.

## Report

Report:

- selected mode and why;
- exact target, devices, suites, and run side;
- actual pass/failure/error counts;
- clickable absolute `summary.md` path;
- first actionable failure and its supporting log path.

State partial success precisely. For example, report that skeleton tests passed
while another suite timed out instead of saying the whole matrix passed.
