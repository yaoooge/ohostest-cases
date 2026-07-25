# ReturnToHome Navigation Design

## Goal

Make `TestHelper.returnToHome` return to a newly created mall home entry through
the application's `NavPathStack`, without clicking tabs, clicking back buttons,
or sending back key events.

## Design

`returnToHome` will call:

```ts
routerStack.replacePath({
  name: RouterMap.MAIN_ENTRY,
}, false);
```

`RouterMap.MAIN_ENTRY` creates a new `MainEntry`. Its view model initializes
`curIndex` to `0`, so the displayed tab is the home tab.

The `driver` parameter remains in use only for synchronization. After replacing
the route, the helper waits for:

- `mall-home-page`
- `mall-home-content`
- `mall-product-item`

No component lookup is used to decide how to navigate, and no UI component is
clicked by `returnToHome`.

## Error Handling

The existing component wait helpers remain responsible for producing a clear
test failure if the replacement route does not render the home page.

## Verification

The previously failing LG seckill flow is the regression test: after collection
and history navigation, `openSeckill` calls `prepareHome`, which must replace the
current destination with `MainEntry` and make the seckill entry available.

After that focused test passes, the Answer breakpoint suites will be rerun
through `ohostest:matrix`.
