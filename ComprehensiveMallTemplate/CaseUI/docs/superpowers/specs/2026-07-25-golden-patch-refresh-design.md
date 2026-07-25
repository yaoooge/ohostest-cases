# Golden Patch Refresh Design

## Goal

Regenerate `ComprehensiveMallTemplate/CaseUI/golden_patch.patch` so applying it
to the current `swe` produces the current verified `answer`, without embedding
the entry UI test payload or generated project artifacts.

## Inputs

The current working-tree versions of `swe` and `answer` are the source of
truth. This intentionally includes the newly synchronized test observability
support in both trees, so those shared changes disappear from the regenerated
golden patch while responsive answer differences remain.

## Filtering

Create disposable copies of both projects and exclude:

- `.DS_Store`;
- `.hvigor`, `.idea`, `.ohostest-runs`, `.test`, `build`, and `oh_modules`;
- generated `BuildProfile.ets` files;
- generated `oh-package-lock.json5`;
- `products/entry/src/ohosTest`, which is owned by `test_patch.patch`.

All remaining differences stay in scope, including source, resources, module
configuration, non-entry module test configuration, and the existing removal
of the SWE-only `tests/capability-removal.test.mjs`.

## Patch Generation

Generate a binary-capable `git diff --no-index` from the filtered SWE copy to
the filtered answer copy. Normalize every patch path to be relative to the SWE
project root:

```text
a/<project-relative-path>
b/<project-relative-path>
```

The resulting artifact replaces `golden_patch.patch`.

## Validation

Validation uses a fresh copy of the current SWE:

1. `git apply --check` must succeed.
2. Applying the patch must succeed.
3. After applying the same artifact exclusions, the patched tree must be
   byte-identical to the filtered answer tree.
4. No golden patch entry may reference entry `ohosTest` or excluded generated
   paths.
5. `git diff --check` must report no whitespace errors.
6. The patched project must pass its Node static tests and full Hvigor
   `assembleApp` compile check.

