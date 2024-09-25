import os
from pathlib import Path
import pytest
import re
from datetime import timedelta
from functools import partial
from subprocess import run

from flytekit import WorkflowExecutionPhase
from flytekit.remote import FlyteRemote
from flytekit.configuration import Config


_run = partial(run, check=True, capture_output=True)


@pytest.fixture(scope="module")
def workflows_dir() -> Path:
    return Path(__file__).parent / "workflows"


@pytest.fixture(scope="session")
def config_path() -> str:
    sandbox_path = Path(__file__).parent / "sandbox-yaml.yaml"
    return os.fspath(sandbox_path.resolve())


@pytest.fixture(scope="session")
def remote() -> FlyteRemote:
    return FlyteRemote(
        Config.for_sandbox(),
        default_project="flytesnacks",
        default_domain="development",
    )


def test_hello_world(workflows_dir, config_path, remote):
    result = _run(
        [
            "union",
            "--config",
            os.fspath(config_path),
            "run",
            "--remote",
            "hello_world.py",
            "main",
            "--i",
            "10",
        ],
        cwd=workflows_dir,
        text=True,
    )
    match = re.search(r"executions/(\w+)", result.stdout)

    execution_id = match.group(1)
    ex1 = remote.fetch_execution(name=execution_id)
    ex1 = remote.wait(ex1, poll_interval=timedelta(seconds=1))
    assert ex1.closure.phase == WorkflowExecutionPhase.SUCCEEDED
    assert ex1.outputs["o0"] == 11
