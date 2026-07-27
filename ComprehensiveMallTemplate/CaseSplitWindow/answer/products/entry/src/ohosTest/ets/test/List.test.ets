import commonPassToPassTest from './CommonPassToPass.test';
import smPassToPassTest from './SmPassToPass.test';
import splitFailToPassTest from './SplitFailToPass.test';

export default function testsuite() {
  commonPassToPassTest();
  smPassToPassTest();
  splitFailToPassTest();
}
