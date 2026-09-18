"""Run with python3 tests/test_pre_commit.py; only a temporary Git index is staged."""
from pathlib import Path
import subprocess
import tempfile


hook_dir = Path(__file__).resolve().parents[1] / ".githooks"
with tempfile.TemporaryDirectory(prefix="gcp-hook-test-") as directory:
    repo = Path(directory)

    def git(*args):
        return subprocess.run(
            ["git", "-C", str(repo), *args], capture_output=True, text=True
        )

    assert git("init", "--quiet").returncode == 0
    assert git("config", "core.hooksPath", str(hook_dir)).returncode == 0
    for filename, blocked in [
        ("README.md", False),
        (".env.example", False),
        ("nested/.env.example", False),
        (".env", True),
        ("nested/.env.production", True),
        ("nested/app.env", True),
    ]:
        assert git("read-tree", "--empty").returncode == 0
        path = repo / filename
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("test placeholder\n", encoding="utf-8")
        assert git("add", "--", filename).returncode == 0
        result = git("hook", "run", "pre-commit")
        assert result.returncode == (1 if blocked else 0), (filename, result.stderr)
        if blocked:
            assert filename in result.stderr, result.stderr
    assert git("read-tree", "--empty").returncode == 0
    assert git("hook", "run", "pre-commit").returncode == 0
print("PASS: 7 pre-commit cases (temporary repository only)")
