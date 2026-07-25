# Metadata Test Inventory Design

## Goal

Update `ComprehensiveMallTemplate/CaseUI/metadata.json` so its test inventories
exactly match the latest four HarmonyOS UI test suites.

## Classification

- `pass_to_pass` contains every test from `CommonPassToPass.test.ets`, followed
  by every test from `SmPassToPass.test.ets`.
- `fail_to_pass` contains every test from `MdFailToPass.test.ets`, followed by
  every test from `LgFailToPass.test.ets`.
- Tests retain their source-file order.
- `device_test_suites` remains unchanged because its suite-to-device mapping is
  already current.

The resulting inventory contains 21 pass-to-pass tests and 38 fail-to-pass
tests, for 59 unique tests in total.

## Validation

Validation will parse `metadata.json` and extract each `it(...)` name from the
four source suites. It must prove:

- the JSON is valid;
- each metadata array exactly equals its expected ordered source list;
- all 59 names are present exactly once across the two arrays;
- no test appears in both classifications;
- `device_test_suites` still references the four existing suite files.

