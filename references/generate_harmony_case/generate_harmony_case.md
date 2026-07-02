# generate_harmony_case.py 使用说明

`generate_harmony_case.py` 用于把已经分类好的 Git commit 汇总成一条 HarmonyOS 开发用例交付件。

输出目录结构：

```text
case-output/
  base/                 # 题目工程，不包含 .git
  golden_patch.patch    # 答案 patch
  test_patch.patch      # 测试 patch
  metadata.json         # 生成过程和用例元信息
```

脚本不负责判断某个 commit 属于答案、题目还是测试。你需要在 `case.json` 中显式声明 commit 分类。

## 平台支持

脚本明确支持 Windows、macOS、Linux。

运行要求：

```text
Python 3.10+
Git CLI
git 命令已加入 PATH
```

脚本只依赖 Python 标准库和 Git CLI，不依赖 Bash、zsh、PowerShell 专属语法。脚本导出的 `base/` 面向普通 Git 工程文件；如果 Git 归档中包含 symlink、hardlink 或其他特殊文件类型，脚本会直接停止并提示该条目不适合跨平台导出。

## 基本用法

macOS/Linux：

```bash
python3 generate_harmony_case.py --output-dir case-output case.json
```

Windows：

```powershell
py -3 generate_harmony_case.py --output-dir case-output case.json
```

指定仓库目录：

macOS/Linux：

```bash
python3 generate_harmony_case.py --repo /path/to/repo --output-dir case-output case.json
```

Windows：

```powershell
py -3 generate_harmony_case.py --repo C:\path\to\repo --output-dir case-output case.json
```

如果不指定 `--output-dir`，默认输出到仓库根目录下的 `case-output`。旧版 `case.json` 中的 `output_dir` 字段仍兼容，但新用例建议使用命令行参数指定输出目录。

覆盖已有输出目录：

```bash
python3 generate_harmony_case.py --output-dir case-output --force case.json
```

保留临时 worktree 以便排查冲突：

```bash
python3 generate_harmony_case.py --output-dir case-output --keep-temp case.json
```

## 执行原则

脚本会创建临时 detached worktree 来合成目标状态，不会在当前工作区执行 `reset`、`checkout`，也不会修改当前未提交内容。

脚本支持两种模式：

```text
from_base
  原始工程就是题目工程。
  从 base_commit 出发，分别叠加答案 commit 和测试 commit。

derive_base
  原始工程包含答案。
  从 answer_commit 出发，先叠加 removal_commits 形成题目工程，再叠加 test_commits 形成测试工程。
```

脚本只处理“commit 顺序交错，但 commit 内容可分类”的情况。不处理“同一个 commit 同时混入答案实现和测试代码”的情况。

## from_base 模式

适用场景：原始工程已经是题目工程，后续提交答案实现和测试。

配置模板：

```json
{
  "case_id": "covernews-from-base-example",
  "mode": "from_base",
  "base_commit": "题目工程commit",
  "golden_commits": [
    "答案commit1",
    "答案commit2"
  ],
  "test_commits": [
    "测试commit1",
    "测试commit2"
  ],
  "fail_to_pass": [],
  "pass_to_pass": []
}
```

内部合成逻辑：

```text
base   = base_commit
answer = base_commit + golden_commits
test   = base_commit + test_commits
```

生成结果：

```text
base/                 来自 base
golden_patch.patch    base 到 answer 的差异
test_patch.patch      base 到 test 的差异
metadata.json         记录输入 commit 和合成 commit
```

## derive_base 模式

适用场景：原始工程包含答案，需要先剥离能力形成题目工程。

配置模板：

```json
{
  "case_id": "covernews-derive-base-example",
  "mode": "derive_base",
  "answer_commit": "原始含答案工程commit",
  "removal_commits": [
    "剥离答案commit1",
    "剥离答案commit2"
  ],
  "test_commits": [
    "测试commit1",
    "测试commit2"
  ],
  "fail_to_pass": [],
  "pass_to_pass": []
}
```

`mode` 可以省略，默认值是 `derive_base`。

内部合成逻辑：

```text
base   = answer_commit + removal_commits
answer = answer_commit
test   = base + test_commits
```

生成结果：

```text
base/                 来自 base
golden_patch.patch    base 到 answer 的差异
test_patch.patch      base 到 test 的差异
metadata.json         记录输入 commit 和合成 commit
```

## metadata.json 字段

`metadata.json` 会记录以下信息：

```text
case_id
mode
source_base_commit
source_answer_commit
removal_commits
golden_commits
test_commits
generated_base_commit
generated_answer_commit
generated_test_commit
golden_patch
test_patch
base_project
fail_to_pass
pass_to_pass
```

字段含义：

```text
source_base_commit       from_base 模式中的原始题目 commit
source_answer_commit     derive_base 模式中的原始答案 commit
generated_base_commit    脚本合成出的最终题目状态
generated_answer_commit  脚本合成出的最终答案状态
generated_test_commit    脚本合成出的最终测试状态
```

## 输出目录处理

如果 `output_dir` 已存在，脚本会直接停止：

```text
error: Output directory already exists
```

确认可以覆盖时使用：

```bash
python3 generate_harmony_case.py --output-dir case-output --force case.json
```

## 冲突处理

如果 cherry-pick 冲突，脚本会停止并打印临时 worktree 路径。

常见原因：

```text
commit 分类错误
commit 顺序缺少依赖
某个 commit 同时包含答案和测试改动
```

处理建议：

```text
1. 检查 case.json 中的分类字段。
2. 检查同一类 commit 的顺序。
3. 必要时拆分混合 commit。
4. 修正后重新运行脚本。
```

## 快速检查

检查脚本参数：

macOS/Linux：

```bash
python3 generate_harmony_case.py --help
```

Windows：

```powershell
py -3 generate_harmony_case.py --help
```

检查 patch 能否应用：

```bash
cd case-output/base
git init
git apply --check ../golden_patch.patch
git apply --check ../test_patch.patch
```

查看 patch 涉及文件：

```bash
git apply --numstat case-output/golden_patch.patch
git apply --numstat case-output/test_patch.patch
```

## 跨平台测试

测试只依赖 Python 标准库 `unittest` 和 Git CLI。

macOS/Linux：

```bash
python3 -m unittest discover -s tests
```

Windows：

```powershell
py -3 -m unittest discover -s tests
```
