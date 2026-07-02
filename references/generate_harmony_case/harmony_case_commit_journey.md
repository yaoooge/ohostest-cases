# HarmonyOS 用例制作的 Commit 旅程

本文聚焦工程侧如何提交 commit、如何从 `git log` 中拿到 commit id、如何构造 `case.json`，以及如何运行 `generate_harmony_case.py`。

脚本文档见：[generate_harmony_case.md](generate_harmony_case.md)。

## 命令约定

本文中的 Git 命令在 Windows、macOS、Linux 上一致。运行 Python 脚本时：

```text
macOS/Linux: python3 generate_harmony_case.py --output-dir case-output ...
Windows:     py -3 generate_harmony_case.py --output-dir case-output ...
```

查看目录时：

```text
macOS/Linux: ls case-output-from-base
Windows:     dir case-output-from-base
```

## 基本约定

预先构造base工程，类似下面的commit先提交：

```text
base工程完善 commit：辅助单元测试、业务能力补充
```

每个 commit 尽量只表达一种语义：

```text
答案 commit：只改答案相关的实现
测试 commit：只加或改测试
```

查看提交历史：

```bash
git log --oneline --decorate --graph
```

短 hash 用来写进 `case.json`。

## 场景一：原始工程就是题目工程(from_base)

在原始工程上，补充答案和单元测试。

### 工程提交旅程

先确认当前题目工程是一个干净 commit：

```bash
git status
git rev-parse HEAD
```

假设当前 commit 是：

```text
07ad4be base: original problem project
```

然后提交答案实现：

```bash
# 修改业务代码，补回一多适配能力
git add .
git commit -m "answer: restore breakpoint model"
```

继续提交测试：

```bash
# 新增或修改 UT
git add .
git commit -m "test: cover breakpoint model"
```

如果后续答案还要补充，继续提交答案 commit：

```bash
# 修改业务代码，补回一多适配能力
git add .
git commit -m "answer: restore layout adaptation"
```

如果测试也要调整，继续提交测试 commit：

```bash
# 新增或修改 UT
git add .
git commit -m "test: cover expanded layout"
```

### 从 git log 获取 commit

运行：

```bash
git log --oneline --decorate --graph
```

示例输出：

```text
* a8c31d2 (HEAD) test: cover expanded layout
* 6e29f44 answer: restore layout adaptation
* 4f92b10 test: cover breakpoint model
* 7d91c65 answer: restore breakpoint model
* 07ad4be base: original problem project
```

按语义分类：

```text
base_commit     = 07ad4be
golden_commits  = 7d91c65, 6e29f44
test_commits    = 4f92b10, a8c31d2
```

注意 `golden_commits` 和 `test_commits` 都按依赖顺序填写。

### 构造 case.json

```json
{
  "case_id": "covernews-from-base-example",
  "mode": "from_base",
  "base_commit": "07ad4be",
  "golden_commits": [
    "7d91c65",
    "6e29f44"
  ],
  "test_commits": [
    "4f92b10",
    "a8c31d2"
  ],
  "fail_to_pass": [
    "BreakpointModelTest should resolve compact layout",
    "NewsDetailPageVMTest should expose expanded layout state"
  ],
  "pass_to_pass": []
}
```

### 运行脚本

macOS/Linux：

```bash
python3 generate_harmony_case.py --output-dir case-output-from-base case-from-base.json
```

Windows：

```powershell
py -3 generate_harmony_case.py --output-dir case-output-from-base case-from-base.json
```

如果输出目录已存在：

macOS/Linux：

```bash
python3 generate_harmony_case.py --output-dir case-output-from-base --force case-from-base.json
```

Windows：

```powershell
py -3 generate_harmony_case.py --output-dir case-output-from-base --force case-from-base.json
```

生成后检查：

```bash
ls case-output-from-base
```

预期看到：

```text
base
golden_patch.patch
metadata.json
test_patch.patch
```

### 后续修正

如果又新增了答案修正：

```bash
git add .
git commit -m "answer: fix orientation adaptation"
```

假设新 commit 是：

```text
b31f0c8 answer: fix orientation adaptation
```

把它追加到 `golden_commits`：

```json
"golden_commits": [
  "7d91c65",
  "6e29f44",
  "b31f0c8"
]
```

如果新增测试修正，也同样追加到 `test_commits`。修改 `case.json` 后重新运行脚本即可。

## 场景二：原始工程已经包含答案(derive_base)

原始工程已经包含答案，需要剥离答案，补充单元测试。

### 工程提交旅程

先确认当前完整答案工程是一个干净 commit：

```bash
git status
git rev-parse HEAD
```

假设当前 commit 是：

```text
e21a39e answer: complete multi-device implementation
```

然后提交题目化剥离：

```bash
# 删除或弱化一多适配相关实现
git add .
git commit -m "remove: breakpoint adaptation"
```

再提交测试：

```bash
# 新增 UT，用来验证被删除能力应被恢复
git add .
git commit -m "test: cover breakpoint adaptation"
```

如果发现题目工程还残留答案能力，继续提交题目修正：

```bash
git add .
git commit -m "remove: remaining expanded layout logic"
```

如果测试需要跟随调整，继续提交测试修正：

```bash
git add .
git commit -m "test: align layout adaptation assertions"
```

### 从 git log 获取 commit

运行：

```bash
git log --oneline --decorate --graph
```

示例输出：

```text
* c0a8f37 (HEAD) test: align layout adaptation assertions
* 89db2c1 remove: remaining expanded layout logic
* 52f2e11 test: cover breakpoint adaptation
* 0a71b6d remove: breakpoint adaptation
* e21a39e answer: complete multi-device implementation
```

按语义分类：

```text
answer_commit = e21a39e
removal_commits = 0a71b6d, 89db2c1
test_commits  = 52f2e11, c0a8f37
```

同样要按依赖顺序填写。

### 构造 case.json

```json
{
  "case_id": "covernews-derive-base-example",
  "mode": "derive_base",
  "answer_commit": "e21a39e",
  "removal_commits": [
    "0a71b6d",
    "89db2c1"
  ],
  "test_commits": [
    "52f2e11",
    "c0a8f37"
  ],
  "fail_to_pass": [
    "BreakpointUtilsTest should restore breakpoint calculation",
    "MineLikePageUITest should adapt orientation layout"
  ],
  "pass_to_pass": []
}
```

`derive_base` 是默认模式，`mode` 可以省略。建议保留，便于阅读。

### 运行脚本

macOS/Linux：

```bash
python3 generate_harmony_case.py --output-dir case-output-derive-base case-derive-base.json
```

Windows：

```powershell
py -3 generate_harmony_case.py --output-dir case-output-derive-base case-derive-base.json
```

如果需要指定仓库路径：

macOS/Linux：

```bash
python3 generate_harmony_case.py --repo /path/to/CoverNews1.0.0 --output-dir case-output-derive-base case-derive-base.json
```

Windows：

```powershell
py -3 generate_harmony_case.py --repo C:\path\to\CoverNews1.0.0 --output-dir case-output-derive-base case-derive-base.json
```

生成后检查：

```bash
ls case-output-derive-base
```

预期看到：

```text
base
golden_patch.patch
metadata.json
test_patch.patch
```

### 后续修正

如果继续发现题目剥离不完整：

```bash
git add .
git commit -m "remove: tablet-only branch"
```

假设新 commit 是：

```text
d34a901 remove: tablet-only branch
```

把它追加到 `removal_commits`：

```json
"removal_commits": [
  "0a71b6d",
  "89db2c1",
  "d34a901"
]
```

如果新增测试修正，就追加到 `test_commits`。修改 `case.json` 后重新运行脚本即可。

## 交付件检查

检查输出目录：

```bash
ls case-output-from-base
```

检查 patch 能否应用：

```bash
cd case-output-from-base/base
git init
git apply --check ../golden_patch.patch
git apply --check ../test_patch.patch
```

应用 test patch：

```bash
git apply ../test_patch.patch
```

执行UT用例：
```bash
# 预期结果: fail_to_pass全部失败、pass_to_pass全部成功
hdc shell aa test -b com.atomicservice.6917599741314220558 -m phone_test -s unittest OpenHarmonyTestRunner -s timeout 15000
```

应用 golden patch：

```bash
git apply ../golden_patch.patch
```

执行UT用例：
```bash
# 预期结果: fail_to_pass全部成功、pass_to_pass全部成功
hdc shell aa test -b com.atomicservice.6917599741314220558 -m phone_test -s unittest OpenHarmonyTestRunner -s timeout 15000
```
