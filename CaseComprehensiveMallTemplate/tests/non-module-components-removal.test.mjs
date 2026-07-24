import assert from 'node:assert/strict';
import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { dirname, join } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const projectRoot = dirname(dirname(fileURLToPath(import.meta.url)));
const removed = [
  'address_management',
  'aggregated_login',
  'aggregated_payment',
  'aggregated_share',
  'app_setting',
  'collect_personal_info',
  'coupons',
  'feedback',
  'image_preview',
  'membership',
];

function sourceFiles(root) {
  if (!existsSync(root)) return [];
  return readdirSync(root).flatMap((name) => {
    const path = join(root, name);
    if (path.includes(`${join('components', 'module_')}`)) {
      return statSync(path).isDirectory() ? sourceFiles(path) : [path];
    }
    if (statSync(path).isDirectory()) return sourceFiles(path);
    return /\.(ets|ts|json5|json)$/.test(path) ? [path] : [];
  });
}

test('all non-module component directories are deleted', () => {
  for (const name of removed) {
    assert.equal(existsSync(join(projectRoot, 'components', name)), false, name);
  }
});

test('build and source files do not reference removed component packages', () => {
  const files = [
    join(projectRoot, 'build-profile.json5'),
    ...sourceFiles(join(projectRoot, 'products')),
    ...sourceFiles(join(projectRoot, 'features')),
    ...sourceFiles(join(projectRoot, 'commons')),
    ...sourceFiles(join(projectRoot, 'components')),
  ];
  for (const file of files) {
    const content = readFileSync(file, 'utf8');
    for (const name of removed) {
      const patterns = [
        new RegExp(`from\\s+['"]${name}['"]`),
        new RegExp(`["']${name}["']\\s*:\\s*["']file:`),
        new RegExp(`["']name["']\\s*:\\s*["']${name}["']`),
      ];
      for (const pattern of patterns) {
        assert.doesNotMatch(content, pattern, `${file} references ${name}`);
      }
    }
  }
});

test('main-flow fallbacks remain explicit', () => {
  const state = readFileSync(
    join(projectRoot, 'commons/lib_foundation/src/main/ets/utils/IData.ets'),
    'utf8',
  );
  const order = readFileSync(
    join(projectRoot, 'features/order/src/main/ets/utils/OrderUtil.ets'),
    'utf8',
  );
  const submit = readFileSync(
    join(projectRoot, 'features/order/src/main/ets/viewmodels/OrderSubmitVM.ets'),
    'utf8',
  );
  assert.match(state, /ensureDefaultUserState/);
  assert.match(state, /12345678900/);
  assert.match(order, /订单支付成功/);
  assert.doesNotMatch(order, /CashierPicker|PaymentType/);
  assert.match(submit, /12300000000/);
});
