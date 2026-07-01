---
name: harmonyos-ux-debug-workflow
description: Use when diagnosing HarmonyOS app UX/layout issues on emulator or device, especially when the user asks to compile, install, screenshot, inspect, compare, or verify a page visually.
---

# HarmonyOS UX Debug Workflow

## Goal

Use this skill to turn “界面很怪 / 布局异常 / 截图看效果” into a repeatable evidence loop:

1. compile the target project
2. connect or start the emulator
3. install and launch the app
4. capture screenshot and layout dump
5. inspect root cause
6. patch, rebuild, reinstall, rescreenshot

For visual issues, capture a screenshot before changing code.

## Required Inputs

Identify these before running commands:

| Item | How to find it |
| --- | --- |
| Project root | Usually the app case directory, for example `ResponsiveWaterFlowLayout/answer` |
| Main HAP path | `find <project> -path '*outputs*' -type f -name '*.hap'` |
| Bundle name | `AppScope/app.json5` → `app.bundleName` |
| Ability name | `products/entry/src/main/module.json5` → `abilities[0].name`, often `EntryAbility` |
| HDC target | `<hdc> list targets -v` |
| Emulator instance and image root | `Emulator -list -details -instancePath <dir>` |

Use paths discovered from the repository and local tool output.

## Tool Paths

Use the local OpenHarmony command line tools when present:

```bash
HDC=/Users/guoyutong/command-line-tools/sdk/default/openharmony/toolchains/hdc
EMULATOR=/Applications/DevEco-Studio.app/Contents/tools/emulator/Emulator
```

When sandboxed HDC shows a connected target and `shell` hangs, rerun HDC commands with escalated permissions.

## Workflow

### 1. Build

From the HarmonyOS project root:

```bash
hvigorw --mode project -p product=default assembleApp --analyze=normal --parallel --incremental --no-daemon
```

Expected: exit code `0` and `BUILD SUCCESSFUL`.

For local emulator inspection, continue when the build produces an unsigned HAP and the build warnings mention missing signing configs.

### 2. Find Artifacts

```bash
find . -path '*outputs*' -type f \( -name '*.hap' -o -name '*.app' \) | sort
```

Choose the main entry HAP, commonly:

```text
products/entry/build/default/outputs/default/entry-default-unsigned.hap
```

### 3. Check Emulator

```bash
$HDC list targets -v
$HDC -t <target> shell param get const.product.model
```

Confirm the target responds to `shell`. When `list targets` shows the target and `shell` hangs, restart HDC and retry escalated:

```bash
$HDC kill
$HDC start -r
$HDC list targets -v
```

When zero targets are `Connected`, start an emulator before installing.

First list deployed instances:

```bash
$EMULATOR -list -details -instancePath /Users/guoyutong/.Huawei/Emulator/deployed
```

Use the returned `name`, `instancePath`, and `imageRoot`. On this machine, verified values include:

```text
instancePath: /Users/guoyutong/.Huawei/Emulator/deployed
imageRoot: /Users/guoyutong/Library/Huawei/Sdk
names: Mate 80 Pro, Mate X7, MatePad Pro 13
```

Start one instance on an unused HDC port:

```bash
$EMULATOR -start "Mate 80 Pro" \
  -instancePath /Users/guoyutong/.Huawei/Emulator/deployed \
  -imageRoot /Users/guoyutong/Library/Huawei/Sdk \
  -hdcPort 15001
```

Notes:

- The option is `-hdcPort` with capital `P`.
- `Hot boot is not enable ... start with cold boot` means the emulator is using cold boot.
- Startup may keep the command attached while the emulator runs. In another shell, wait until HDC reports `Connected`:

```bash
$HDC list targets -v
$HDC -t 127.0.0.1:15001 shell param get const.product.model
```

Use `127.0.0.1:<hdcPort>` as `<target>` for install, launch, screenshots, and layout dumps.

### 4. Install

```bash
$HDC -t <target> install -r <absolute-main-hap-path>
```

Expected output includes:

```text
install bundle successfully
```

### 5. Launch

```bash
$HDC -t <target> shell aa start -b <bundle-name> -a <ability-name>
```

Expected:

```text
start ability successfully
```

If a stale panel or lock screen blocks the app, prepare the device:

```bash
$HDC -t <target> shell uitest uiInput keyEvent Home
$HDC -t <target> shell uitest uiInput keyEvent Back
```

After pressing Back, launch the app again before taking screenshots.

### 6. Capture Screenshot

On device:

```bash
$HDC -t <target> shell snapshot_display -f /data/local/tmp/<case-name>.jpeg
```

Pull locally:

```bash
$HDC -t <target> file recv /data/local/tmp/<case-name>.jpeg /private/tmp/<case-name>.jpeg
```

Then inspect the local image with the image viewer tool. Include the screenshot path in the final report when useful.

### 7. Capture Layout Dump

```bash
$HDC -t <target> shell uitest dumpLayout
```

The command prints a path such as:

```text
DumpLayout saved to:/data/local/tmp/layout_123456.json
```

Pull it:

```bash
$HDC -t <target> file recv /data/local/tmp/layout_123456.json /private/tmp/<case-name>-layout.json
```

Search for stable ids, text, bounds, clipping, and scrollability:

```bash
rg -n '"id":"<component-id>"|"text":"<visible-text>"|bounds|clip|scrollable' /private/tmp/<case-name>-layout.json
```

## Analysis Checklist

Use screenshot and layout dump together.

- **Oversized item**: Compare parent and child `bounds`. If child width exceeds lane/container width, look for misplaced `.width('100%')`, fixed width, or unconstrained builder root.
- **Clipped content**: Check `clip`, `origBounds`, and visible `bounds`. A larger `origBounds` than `bounds` means content is being clipped.
- **Wrong columns**: Check `WaterFlow.columnsTemplate`, `List.lanes`, `Grid.columnsTemplate`, and runtime breakpoint values.
- **Image distortion**: Check `objectFit`; catalog product images usually use `ImageFit.Contain`; fixed visual crops usually use `ImageFit.Cover`.
- **Header/status overlap**: Check top bounds against status bar bounds. Add safe-area handling if content starts under system UI.
- **App visibility**: Confirm install succeeded, bundle name is correct, ability launched, and screenshot was taken after launch.
- **Sandboxed HDC access**: If `list targets` works and shell/install hangs or returns suspicious output, rerun HDC commands escalated.

## Patch Loop

After identifying a root cause:

1. Make the smallest code change that addresses the observed bounds or rendering issue.
2. Rebuild with the same `hvigorw` command.
3. Reinstall the HAP.
4. Relaunch the app.
5. Capture a new screenshot.
6. Compare before/after screenshots and, when needed, layout dumps.

Report the issue as fixed after the new screenshot or layout dump shows the expected result.

## Report Format

Keep the final report short:

```markdown
Checked on `<target>`.

Root cause: <specific layout/rendering cause backed by screenshot or layout bounds>.
Fix: <files/behavior changed>.
Verification: build passed; installed; screenshot captured at `<local-path>`.
```

Mention emulator/profile/device types that were unavailable.
