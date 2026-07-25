# Skeleton Observation Design

## Goal

Make the search-result skeleton layout tests reliable while keeping the global
mock response delay at 2000 milliseconds.

## Design

The skeleton helper will navigate directly to `PRODUCT_SEARCH_RESULTS` instead
of using the result-page helper that waits for controls needed by non-transient
tests.

For grid mode, it waits for the horizontal skeleton and immediately captures
the first-row count. For list mode, it clicks the display-mode toggle as soon as
the control appears, waits for the vertical skeleton, and immediately captures
the first-row count.

The capture operation is specialized for transient components. It reads bounds
in List order and returns as soon as the first component from the second row is
encountered. It does not read every skeleton card, avoiding enough TestKit
round-trips for the 2000-millisecond loading state to disappear.

`openSearchSkeleton` returns the captured first-row count. SM, MD, and LG tests
assert that returned value without performing another component query.

## Scope

- Keep `MockAdapter.delayResponse` at 2000 milliseconds.
- Do not add application-side test switches.
- Do not change the generic geometry helper used by persistent lists.
- Change only the shared UI-test helper and the six skeleton assertions.

## Verification

Run the breakpoint suites independently:

- Phone: `SmPassToPassTest`
- Foldable: `MdFailToPassTest`
- Tablet: `LgFailToPassTest`

The expected skeleton first-row counts remain:

- SM: horizontal 2, vertical 1
- MD: horizontal 3, vertical 1
- LG: horizontal 4, vertical 2
