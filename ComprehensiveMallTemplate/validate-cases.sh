#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "$0")" && pwd)"
ui_swe="$root_dir/CaseUI/swe"
ui_answer="$root_dir/CaseUI/answer"
split_swe="$root_dir/CaseSplitWindow/swe"
split_answer="$root_dir/CaseSplitWindow/answer"

for project in "$ui_swe" "$ui_answer" "$split_swe" "$split_answer"; do
  test -f "$project/build-profile.json5"
  test -f "$project/products/entry/src/main/module.json5"
  if find "$project" \
    \( -type d \( -name .hvigor -o -name build -o -name oh_modules \) \
    -o -type f \( -name BuildProfile.ets -o -name oh-package-lock.json5 \) \) \
    -print -quit | grep -q .; then
    echo "generated build artifact found in $project" >&2
    exit 1
  fi
done

ui_manifest="$(mktemp)"
split_manifest="$(mktemp)"
trap 'rm -f "$ui_manifest" "$split_manifest"' EXIT

tree_manifest() {
  local project_dir="$1"
  local output_file="$2"
  (
    cd "$project_dir"
    find . \
      -type d \( -name .hvigor -o -name .idea -o -name .ohostest-runs -o -name build -o -name oh_modules \) -prune \
      -o -type f ! -name BuildProfile.ets -print |
      LC_ALL=C sort |
      while IFS= read -r file; do
      shasum -a 256 "$file"
    done
  ) > "$output_file"
}

tree_manifest "$ui_swe" "$ui_manifest"
tree_manifest "$split_swe" "$split_manifest"
cmp -s "$ui_manifest" "$split_manifest"

for project in "$ui_swe" "$ui_answer" "$split_swe" "$split_answer"; do
  test ! -e "$project/products/entry/src/main/resources/tablet/media/mock_homepage_banner1.png"
done

if rg -n \
  'SecondAbility|WINDOW_MODE_SPLIT|isSplitActive|cloneStackTo|migrateStack|startSplitScreen|mergeSplitScreen' \
  "$ui_swe" "$split_swe" "$ui_answer" \
  --glob '*.{ets,json5,json}' \
  --glob '!**/build/**' \
  --glob '!**/oh_modules/**'; then
  echo "unexpected split-window capability outside split answer" >&2
  exit 1
fi

if rg -n \
  'BreakpointSystem|BreakpointTypeEnum|BreakpointStorage|GridRow|GridCol|WaterFlowScaleUtil' \
  "$ui_swe" "$split_swe" "$split_answer" \
  --glob '*.ets' \
  --glob '!**/build/**' \
  --glob '!**/oh_modules/**'; then
  echo "unexpected responsive UI capability outside UI answer" >&2
  exit 1
fi

rg -q 'BreakpointSystem' "$ui_answer/commons/lib_foundation/src/main/ets/utils/BreakpointSystem.ets"
rg -q '2.5' "$ui_answer/products/entry/src/main/ets/components/HomePageContent.ets"
rg -q 'return 5' "$ui_answer/products/entry/src/main/ets/components/HomePageContent.ets"

rg -q 'SecondAbility' "$split_answer/products/entry/src/main/module.json5"
rg -q 'WINDOW_MODE_SPLIT_SECONDARY' \
  "$split_answer/features/product/src/main/ets/viewmodels/ProductInfoVM.ets"
rg -q 'cloneStackTo' "$split_answer/commons/lib_foundation/src/main/ets/utils/RouterUtil.ets"
rg -q 'migrateStack' "$split_answer/commons/lib_foundation/src/main/ets/utils/RouterUtil.ets"

echo "ComprehensiveMallTemplate case validation passed."
