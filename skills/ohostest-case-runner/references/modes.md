# OhosTest Runner Modes

## Contents

- [Runner](#runner)
- [Matrix mode](#matrix-mode)
- [Case mode](#case-mode)
- [Result inspection](#result-inspection)
- [Diagnostics](#diagnostics)

## Runner

Use:

```text
/Users/guoyutong/codeRepo/01-mine/harmonyos-ohostest/harmonyos-ohostest-runner
```

Run all commands with that directory as the working directory.

Authoritative local documentation:

```text
docs/usage/matrix.md
docs/usage/case.md
docs/usage/troubleshooting.md
config/machine.json
```

Read the authoritative document when a requested option is not listed here or
when the local runner may have changed.

## Matrix Mode

### Use matrix mode for

- a direct `answer`, `swe`, or other already materialized project;
- development-time verification before patch generation;
- one or more devices without case composition;
- a focused suite selected with `--test-class`;
- rerunning a project after changing UI tests or application code.

### Command

```bash
npm run ohostest:matrix -- \
  --project /absolute/path/to/project
```

Common filters:

```bash
npm run ohostest:matrix -- \
  --project /absolute/path/to/project \
  --device phone \
  --device tablet

npm run ohostest:matrix -- \
  --project /absolute/path/to/project \
  --device tablet \
  --test-class LgFailToPassTest
```

Supported options:

```text
--project <path>               required project root
--device <id>                  repeatable device filter
--test-class <className>       run one suite class
--machine-config <path>        alternate machine configuration
--out <path>                   explicit result output
--skip-build true|false        reuse an existing build only when safe
--keep-emulators true|false    retain runner-started emulators
```

Without `--device`, run all devices selected from `machine.json`. Without
`--test-class`, use each device's configured `testSuites`; if no suites are
configured, run the complete test module.

Prefer a real build after source changes. Use `--skip-build true` only when the
current HAPs definitely contain the code under test.

Default artifacts:

```text
<project>/.ohostest-runs/<timestamp>/
├── result.json
├── summary.md
├── commands.log
└── devices/
```

Matrix mode does not apply patches and does not evaluate pass-to-pass or
fail-to-pass classification.

## Case Mode

### Use case mode for

- a directory containing `metadata.json` and patch files;
- reconstructing `base_project + test_patch` as SWE;
- reconstructing `base_project + test_patch + golden_patch` as Answer;
- checking metadata device-to-suite selection;
- validating pass-to-pass and fail-to-pass expectations;
- final SWE, Answer, or two-sided case validation.

### Required layout

```text
<case>/
├── metadata.json
├── test_patch.patch
├── golden_patch.patch
└── <base-project or resolvable sibling base project>
```

`metadata.json` names the base project and patch files. The runner resolves the
base project from the case directory and then its parent.

### Commands

Answer only:

```bash
npm run ohostest:case -- \
  --case /absolute/path/to/case \
  --run answer
```

SWE only:

```bash
npm run ohostest:case -- \
  --case /absolute/path/to/case \
  --run swe
```

Both:

```bash
npm run ohostest:case -- \
  --case /absolute/path/to/case \
  --run all
```

Filter devices by repeating `--device`:

```bash
npm run ohostest:case -- \
  --case /absolute/path/to/case \
  --run answer \
  --device phone \
  --device tablet
```

Supported options:

```text
--case <path>                  required case directory
--run answer|swe|all           default: answer
--device <id>                  repeatable configured-device filter
--machine-config <path>        alternate machine configuration
--out <path>                   explicit case output directory
--skip-build true|false        skip build only with valid composed artifacts
--keep-emulators true|false    retain runner-started emulators
--keep-workdir true|false      retain the composed working project
```

Do not pass `--test-class`.

Suite selection priority:

1. `metadata.device_test_suites`;
2. `metadata.enabled_devices`, with the complete test module per device;
3. all `machine.json` devices, with the complete test module.

Case mode intentionally does not inherit `machine.json.devices[].testSuites`
when metadata has no `device_test_suites`.

Default artifacts:

```text
<case>/.ohostest-runs/<timestamp>/
├── result.json
├── summary.md
├── commands.log
├── swe/
│   ├── summary.md
│   ├── commands.log
│   └── devices/
├── answer/
│   ├── summary.md
│   ├── commands.log
│   └── devices/
└── work/
```

Only requested sides are present. `work/` is removed unless
`--keep-workdir true`.

## Result Inspection

Identify the output created by the current invocation. Prefer the path printed
by the runner. When using the default output, list reports by modification time
under the target's `.ohostest-runs/` and confirm the timestamp is newer than the
command start.

Read `summary.md` first.

For matrix mode, require:

- every requested device status is `passed`;
- every requested suite has zero failures and errors;
- expected test counts are nonzero;
- each requested test is passed or intentionally ignored.

For case mode, require:

- every requested run side exists;
- Answer tests expected to pass actually pass;
- SWE outcomes match `pass_to_pass` and `fail_to_pass`;
- no test is unclassified;
- device and suite selection matches metadata;
- no requested device is blocked.

Treat `Status: completed` only as orchestration completion. It is not proof that
tests passed.

## Diagnostics

Use the narrowest artifact that explains the failure:

| Failure | Read |
| --- | --- |
| Patch application or case composition | case-level `commands.log` |
| Hvigor build or artifact discovery | run-side `commands.log` |
| Emulator start, HDC, install, or blocked device | `commands.log`, then device log |
| Failed test assertion or timeout | `devices/<device>.log` |
| Wrong suite/device selection | `metadata.json`, summary Device Suites, machine config |
| Classification mismatch | case `summary.md` and metadata pass/fail lists |

If a retained emulator causes a later `emulator_start_failed`, confirm the exact
profile and port before stopping only that instance. Do not kill unrelated
emulators or broad process groups.

If the runner returns exit code zero but the report contains failures, report
the report result as authoritative.
