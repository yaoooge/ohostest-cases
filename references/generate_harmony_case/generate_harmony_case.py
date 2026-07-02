#!/usr/bin/env python3
"""Generate HarmonyOS SWE-Bench style case artifacts from classified commits.

The script intentionally does not infer whether a commit is a "base" change or
a "test" change. Provide that classification in a JSON config so interleaved
history can still produce clean artifacts.
"""

from __future__ import annotations

import argparse
import json
import ntpath
import os
import posixpath
import shutil
import subprocess
import sys
import tarfile
import tempfile
from io import BytesIO
from pathlib import Path, PurePosixPath, PureWindowsPath
from typing import Any, IO


DERIVE_BASE_MODE = "derive_base"
FROM_BASE_MODE = "from_base"
VALID_MODES = {DERIVE_BASE_MODE, FROM_BASE_MODE}
REMOVAL_COMMITS_KEY = "removal_commits"


class CaseGenError(RuntimeError):
    pass


def ensure_git_available() -> None:
    if shutil.which("git") is None:
        raise CaseGenError(
            "Git executable was not found in PATH. Install Git and make sure the "
            "`git` command is available before running this script."
        )


def run_git(
    repo: Path,
    args: list[str],
    *,
    cwd: Path | None = None,
    stdout: int | IO[bytes] | None = None,
) -> subprocess.CompletedProcess[bytes]:
    command = ["git", *args]
    env = os.environ.copy()
    env.setdefault("GIT_AUTHOR_NAME", "Harmony Case Generator")
    env.setdefault("GIT_AUTHOR_EMAIL", "harmony-case-generator@example.invalid")
    env.setdefault("GIT_COMMITTER_NAME", "Harmony Case Generator")
    env.setdefault("GIT_COMMITTER_EMAIL", "harmony-case-generator@example.invalid")

    try:
        process = subprocess.run(
            command,
            cwd=str(cwd or repo),
            env=env,
            stdout=stdout,
            stderr=subprocess.PIPE,
            check=False,
        )
    except FileNotFoundError as exc:
        raise CaseGenError(
            "Git executable was not found in PATH. Install Git and make sure the "
            "`git` command is available before running this script."
        ) from exc
    if process.returncode != 0:
        stderr = process.stderr.decode("utf-8", errors="replace").strip()
        raise CaseGenError(f"Command failed: {' '.join(command)}\n{stderr}")
    return process


def resolve_commit(repo: Path, revision: str) -> str:
    process = run_git(repo, ["rev-parse", "--verify", f"{revision}^{{commit}}"], stdout=subprocess.PIPE)
    return process.stdout.decode("utf-8").strip()


def read_config(path: Path) -> dict[str, Any]:
    try:
        with path.open("r", encoding="utf-8") as file:
            config = json.load(file)
    except json.JSONDecodeError as exc:
        raise CaseGenError(f"Invalid JSON config {path}: {exc}") from exc

    mode = config.get("mode", DERIVE_BASE_MODE)
    if mode not in VALID_MODES:
        raise CaseGenError(f"mode must be one of: {', '.join(sorted(VALID_MODES))}")
    config["mode"] = mode

    if mode == DERIVE_BASE_MODE:
        required = ["answer_commit", REMOVAL_COMMITS_KEY, "test_commits"]
    else:
        required = ["base_commit", "golden_commits", "test_commits"]

    missing = [key for key in required if key not in config]
    if missing:
        raise CaseGenError(f"Missing required config field(s): {', '.join(missing)}")

    list_keys = ["test_commits"]
    if mode == DERIVE_BASE_MODE:
        list_keys.append(REMOVAL_COMMITS_KEY)
    else:
        list_keys.append("golden_commits")

    for key in list_keys:
        if not isinstance(config[key], list) or not all(isinstance(item, str) for item in config[key]):
            raise CaseGenError(f"{key} must be a list of commit revisions")

    revision_key = "answer_commit" if mode == DERIVE_BASE_MODE else "base_commit"
    if not isinstance(config[revision_key], str):
        raise CaseGenError(f"{revision_key} must be a commit revision string")

    return config


def prepare_output_dir(output_dir: Path, force: bool) -> None:
    if output_dir.exists():
        if not force:
            raise CaseGenError(f"Output directory already exists: {output_dir}\nUse --force to replace it.")
        shutil.rmtree(output_dir)
    output_dir.mkdir(parents=True)


def add_worktree(repo: Path, path: Path, revision: str) -> None:
    run_git(repo, ["worktree", "add", "--detach", str(path), revision])


def remove_worktree(repo: Path, path: Path) -> None:
    if path.exists():
        run_git(repo, ["worktree", "remove", "--force", str(path)])


def cherry_pick_sequence(repo: Path, worktree: Path, commits: list[str], label: str) -> None:
    for index, commit in enumerate(commits, start=1):
        try:
            run_git(repo, ["cherry-pick", commit], cwd=worktree)
        except CaseGenError as exc:
            raise CaseGenError(
                f"Failed to apply {label} commit {index}/{len(commits)}: {commit}\n"
                "Resolve the commit classification or conflicts manually, then rerun.\n"
                f"{exc}"
            ) from exc


def write_diff(repo: Path, left: str, right: str, output_file: Path) -> None:
    with output_file.open("wb") as file:
        run_git(repo, ["diff", "--binary", left, right], stdout=file)


def validate_archive_member(member: tarfile.TarInfo, output_dir: Path) -> None:
    name = member.name
    if not name:
        raise CaseGenError("Unsafe empty path in git archive.")
    if "\\" in name:
        raise CaseGenError(f"Backslash path is not supported in git archive: {name}")
    if posixpath.isabs(name) or ntpath.isabs(name) or PureWindowsPath(name).drive:
        raise CaseGenError(f"Absolute path is not allowed in git archive: {name}")

    posix_parts = PurePosixPath(name).parts
    windows_parts = PureWindowsPath(name).parts
    if any(part in {"", ".", ".."} for part in (*posix_parts, *windows_parts)):
        raise CaseGenError(f"Unsafe path in git archive: {name}")

    if member.issym() or member.islnk():
        raise CaseGenError(f"Links are not supported in cross-platform archive export: {name}")
    if not (member.isfile() or member.isdir()):
        raise CaseGenError(f"Unsupported archive entry type for cross-platform export: {name}")

    member_path = output_dir.joinpath(*posix_parts)
    try:
        member_path.resolve().relative_to(output_dir.resolve())
    except ValueError as exc:
        raise CaseGenError(f"Unsafe path in git archive: {name}") from exc


def safe_extract_git_archive(archive_bytes: bytes, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    with tarfile.open(fileobj=BytesIO(archive_bytes), mode="r:") as archive:
        for member in archive.getmembers():
            validate_archive_member(member, output_dir)
        archive.extractall(output_dir)


def export_base_project(repo: Path, commit: str, output_dir: Path) -> None:
    process = run_git(repo, ["archive", "--format=tar", commit], stdout=subprocess.PIPE)
    safe_extract_git_archive(process.stdout, output_dir)


def write_metadata(
    output_dir: Path,
    config: dict[str, Any],
    resolved: dict[str, Any],
) -> None:
    metadata = {
        "case_id": config.get("case_id"),
        "mode": resolved["mode"],
        "source_base_commit": resolved.get("source_base_commit"),
        "source_answer_commit": resolved.get("source_answer_commit"),
        "removal_commits": resolved.get("removal_commits", []),
        "golden_commits": resolved.get("golden_commits", []),
        "test_commits": resolved.get("test_commits", []),
        "generated_base_commit": resolved["generated_base_commit"],
        "generated_answer_commit": resolved["generated_answer_commit"],
        "generated_test_commit": resolved["generated_test_commit"],
        "golden_patch": "golden_patch.patch",
        "test_patch": "test_patch.patch",
        "base_project": "base",
    }
    for optional_key in ["fail_to_pass", "pass_to_pass", "notes"]:
        if optional_key in config:
            metadata[optional_key] = config[optional_key]

    with (output_dir / "metadata.json").open("w", encoding="utf-8") as file:
        json.dump(metadata, file, ensure_ascii=False, indent=2)
        file.write("\n")


def build_derive_base_case(
    repo_root: Path,
    config: dict[str, Any],
    temp_root: Path,
    output_dir: Path,
) -> dict[str, Any]:
    source_answer_commit = resolve_commit(repo_root, config["answer_commit"])
    removal_commits = [resolve_commit(repo_root, commit) for commit in config[REMOVAL_COMMITS_KEY]]
    test_commits = [resolve_commit(repo_root, commit) for commit in config["test_commits"]]

    base_worktree = temp_root / "base-worktree"
    test_worktree = temp_root / "test-worktree"

    add_worktree(repo_root, base_worktree, source_answer_commit)
    cherry_pick_sequence(repo_root, base_worktree, removal_commits, "removal")
    generated_base_commit = resolve_commit(base_worktree, "HEAD")

    add_worktree(repo_root, test_worktree, generated_base_commit)
    cherry_pick_sequence(repo_root, test_worktree, test_commits, "test")
    generated_test_commit = resolve_commit(test_worktree, "HEAD")

    export_base_project(repo_root, generated_base_commit, output_dir / "base")
    write_diff(repo_root, generated_base_commit, source_answer_commit, output_dir / "golden_patch.patch")
    write_diff(repo_root, generated_base_commit, generated_test_commit, output_dir / "test_patch.patch")

    return {
        "worktrees": [test_worktree, base_worktree],
        "metadata": {
            "mode": DERIVE_BASE_MODE,
            "source_answer_commit": source_answer_commit,
            "source_base_commit": None,
            "removal_commits": removal_commits,
            "golden_commits": [],
            "test_commits": test_commits,
            "generated_base_commit": generated_base_commit,
            "generated_answer_commit": source_answer_commit,
            "generated_test_commit": generated_test_commit,
        },
    }


def build_from_base_case(
    repo_root: Path,
    config: dict[str, Any],
    temp_root: Path,
    output_dir: Path,
) -> dict[str, Any]:
    source_base_commit = resolve_commit(repo_root, config["base_commit"])
    golden_commits = [resolve_commit(repo_root, commit) for commit in config["golden_commits"]]
    test_commits = [resolve_commit(repo_root, commit) for commit in config["test_commits"]]

    answer_worktree = temp_root / "answer-worktree"
    test_worktree = temp_root / "test-worktree"

    add_worktree(repo_root, answer_worktree, source_base_commit)
    cherry_pick_sequence(repo_root, answer_worktree, golden_commits, "golden")
    generated_answer_commit = resolve_commit(answer_worktree, "HEAD")

    add_worktree(repo_root, test_worktree, source_base_commit)
    cherry_pick_sequence(repo_root, test_worktree, test_commits, "test")
    generated_test_commit = resolve_commit(test_worktree, "HEAD")

    export_base_project(repo_root, source_base_commit, output_dir / "base")
    write_diff(repo_root, source_base_commit, generated_answer_commit, output_dir / "golden_patch.patch")
    write_diff(repo_root, source_base_commit, generated_test_commit, output_dir / "test_patch.patch")

    return {
        "worktrees": [test_worktree, answer_worktree],
        "metadata": {
            "mode": FROM_BASE_MODE,
            "source_base_commit": source_base_commit,
            "source_answer_commit": None,
            "removal_commits": [],
            "golden_commits": golden_commits,
            "test_commits": test_commits,
            "generated_base_commit": source_base_commit,
            "generated_answer_commit": generated_answer_commit,
            "generated_test_commit": generated_test_commit,
        },
    }


def resolve_output_dir(repo_root: Path, config: dict[str, Any], output_dir: Path | None) -> Path:
    resolved_output_dir = output_dir or Path(config.get("output_dir", "case-output"))
    if not resolved_output_dir.is_absolute():
        resolved_output_dir = repo_root / resolved_output_dir
    return resolved_output_dir


def generate_case(
    repo: Path,
    config_path: Path,
    force: bool,
    keep_temp: bool,
    output_dir: Path | None = None,
) -> Path:
    ensure_git_available()
    config = read_config(config_path)
    repo_root = Path(
        run_git(repo, ["rev-parse", "--show-toplevel"], stdout=subprocess.PIPE)
        .stdout.decode("utf-8")
        .strip()
    )

    output_dir = resolve_output_dir(repo_root, config, output_dir)
    prepare_output_dir(output_dir, force)

    temp_root = Path(tempfile.mkdtemp(prefix="harmony-casegen-"))
    worktrees: list[Path] = []

    try:
        if config["mode"] == FROM_BASE_MODE:
            result = build_from_base_case(repo_root, config, temp_root, output_dir)
        else:
            result = build_derive_base_case(repo_root, config, temp_root, output_dir)

        worktrees = result["worktrees"]
        write_metadata(output_dir, config, result["metadata"])
    except Exception:
        print(f"Temporary worktrees kept for debugging: {temp_root}", file=sys.stderr)
        raise
    else:
        if keep_temp:
            print(f"Temporary worktrees kept: {temp_root}")
        else:
            for worktree in worktrees:
                remove_worktree(repo_root, worktree)
            shutil.rmtree(temp_root, ignore_errors=True)

    return output_dir


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate HarmonyOS case artifacts from answer/base/test commits.",
    )
    parser.add_argument("config", type=Path, help="Path to case JSON config.")
    parser.add_argument(
        "--repo",
        type=Path,
        default=Path.cwd(),
        help="Repository path. Defaults to the current working directory.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Replace the output directory if it already exists.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        help=(
            "Output directory for generated artifacts. Overrides output_dir in "
            "the config file. Defaults to case-output."
        ),
    )
    parser.add_argument(
        "--keep-temp",
        action="store_true",
        help="Keep temporary worktrees after a successful run.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        output_dir = generate_case(
            args.repo.resolve(),
            args.config.resolve(),
            args.force,
            args.keep_temp,
            args.output_dir,
        )
    except CaseGenError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    print(f"Generated HarmonyOS case artifacts in {output_dir}")
    print(f"- {output_dir / 'base'}")
    print(f"- {output_dir / 'golden_patch.patch'}")
    print(f"- {output_dir / 'test_patch.patch'}")
    print(f"- {output_dir / 'metadata.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
