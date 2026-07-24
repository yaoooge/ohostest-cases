import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const projectRoot = dirname(dirname(fileURLToPath(import.meta.url)));
const read = (path) => readFileSync(join(projectRoot, path), 'utf8');

test('privacy, scan, advertisement, and Push implementations are removed', () => {
  for (const path of [
    'components/module_privacy_agreement',
    'components/module_product_scan',
    'components/module_advertisement',
    'commons/lib_foundation/src/main/ets/push',
    'products/entry/src/main/ets/views/SafePage.ets',
    'products/entry/src/main/ets/views/SplashPage.ets',
  ]) {
    assert.equal(existsSync(join(projectRoot, path)), false, path);
  }
});

test('normal startup enters MainEntry while split behavior is absent and deep links remain', () => {
  const index = read('products/entry/src/main/ets/views/Index.ets');
  const setup = read('products/entry/src/main/ets/utils/SetupUtil.ets');
  assert.match(index, /name:\s*RouterMap\.MAIN_ENTRY/);
  assert.doesNotMatch(index, /SAFE_PAGE|SPLASH_PAGE/);
  assert.doesNotMatch(index, /SecondAbility|splitNavStore|multiContext|doubleStack/);
  assert.match(setup, /RouterMap\.PRODUCT_INFO/);
  assert.match(setup, /productId/);
  assert.match(setup, /OrderPage/);
});

test('Push and notification permission behavior are detached', () => {
  const ability = read('products/entry/src/main/ets/entryability/EntryAbility.ets');
  const home = read('products/entry/src/main/ets/viewmodels/HomePageVM.ets');
  const permission = read('commons/lib_foundation/src/main/ets/utils/PermissionUtil.ets');
  const foundation = read('commons/lib_foundation/Index.ets');
  for (const source of [ability, home, permission, foundation]) {
    assert.doesNotMatch(source, /PushUtil|requestNotificationPermission|NotificationKit/);
  }
  assert.match(permission, /requestPermissions\(/);
});

test('scan entry is removed while order shortcut remains', () => {
  const homePage = read('products/entry/src/main/ets/tabviews/HomePage.ets');
  const homeVm = read('products/entry/src/main/ets/viewmodels/HomePageVM.ets');
  const setup = read('products/entry/src/main/ets/utils/SetupUtil.ets');
  const shortcuts = read('products/entry/src/main/resources/base/profile/shortcuts_config.json');
  assert.doesNotMatch(homePage, /jumpToScanPage|line_viewfinder/);
  assert.doesNotMatch(homeVm, /module_product_scan|subjectSegmentation|CoreVisionKit/);
  assert.doesNotMatch(setup, /ScanPage|ScanRouterMap/);
  assert.doesNotMatch(shortcuts, /shortcuts_scan|ScanPage/);
  assert.match(shortcuts, /shortcuts_orders|OrderPage/);
});

test('build and package configuration no longer reference deleted modules', () => {
  const sources = [
    read('build-profile.json5'),
    read('products/entry/oh-package.json5'),
    read('products/entry/src/main/resources/base/profile/route_map.json'),
  ];
  for (const source of sources) {
    assert.doesNotMatch(
      source,
      /module_privacy_agreement|module_product_scan|module_advertisement|SafePage|SplashPage/,
    );
  }
});
